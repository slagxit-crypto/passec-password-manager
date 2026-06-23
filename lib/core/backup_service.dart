import 'dart:convert';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'database.dart';
import 'security.dart';

class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  /// Export selected spaces and their accounts into an encrypted JSON string.
  Future<String> exportBackup({
    required List<String> spaceIds,
    required String password,
    required AppDatabase db,
  }) async {
    final security = SecurityService.instance;

    // 1. Retrieve all spaces matching spaceIds
    final allSpaces = await db.getAllSpaces();
    final selectedSpaces = allSpaces.where((s) => spaceIds.contains(s.id)).toList();

    // 2. Retrieve all accounts for these spaces
    final allAccounts = <Account>[];
    for (final spaceId in spaceIds) {
      final spaceAccounts = await (db.select(db.accounts)
            ..where((tbl) => tbl.spaceId.equals(spaceId)))
          .get();
      allAccounts.addAll(spaceAccounts);
    }

    // 3. Serialize to JSON map
    final dataMap = {
      'spaces': selectedSpaces.map((s) => {
        'id': s.id,
        'name': s.name,
        'created_at': s.createdAt.toIso8601String(),
      }).toList(),
      'accounts': allAccounts.map((a) => {
        'id': a.id,
        'space_id': a.spaceId,
        'account_name': a.accountName,
        'username': a.username,
        'encrypted_password': a.encryptedPassword,
        'notes': a.notes,
        'recovery_email': a.recoveryEmail,
        'recovery_phone_number': a.recoveryPhoneNumber,
        'website_url': a.websiteUrl,
        'is_favorite': a.isFavorite,
        'last_accessed_at': a.lastAccessedAt?.toIso8601String(),
        'created_at': a.createdAt.toIso8601String(),
        'updated_at': a.updatedAt.toIso8601String(),
      }).toList(),
    };

    final plainJson = jsonEncode(dataMap);

    // 4. Encrypt the JSON payload
    final salt = security.generateRandomBytes(16);
    final derivedKey = security.deriveKeyFromPin(password, salt);
    final iv = security.generateRandomBytes(16);

    final plainBytes = utf8.encode(plainJson);
    final cipherBytes = security.encryptAES(Uint8List.fromList(plainBytes), derivedKey, iv);

    // 5. Package into export format
    final exportMap = {
      'version': 1,
      'salt': base64Encode(salt),
      'iv': base64Encode(iv),
      'ciphertext': base64Encode(cipherBytes),
    };

    return jsonEncode(exportMap);
  }

  /// Decrypt and import spaces and accounts from backup content.
  Future<bool> importBackup({
    required String backupContent,
    required String password,
    required AppDatabase db,
  }) async {
    final security = SecurityService.instance;

    try {
      // 1. Decode container file JSON
      final exportMap = jsonDecode(backupContent);
      if (exportMap['version'] != 1) return false;

      final salt = base64Decode(exportMap['salt'] as String);
      final iv = base64Decode(exportMap['iv'] as String);
      final ciphertext = base64Decode(exportMap['ciphertext'] as String);

      // 2. Derive key and decrypt payload
      final derivedKey = security.deriveKeyFromPin(password, salt);
      final plainBytes = security.decryptAES(ciphertext, derivedKey, iv);
      if (plainBytes == null) return false; // Wrong password or corrupted data

      final plainJson = utf8.decode(plainBytes);
      final dataMap = jsonDecode(plainJson);

      final spacesList = dataMap['spaces'] as List;
      final accountsList = dataMap['accounts'] as List;

      // 3. Write data transactionally to SQLite
      await db.transaction(() async {
        for (final s in spacesList) {
          final spaceId = s['id'] as String;
          // Check if space already exists to avoid conflict
          final existing = await (db.select(db.spaces)..where((t) => t.id.equals(spaceId))).getSingleOrNull();
          if (existing == null) {
            await db.into(db.spaces).insert(
              SpacesCompanion.insert(
                id: spaceId,
                name: s['name'] as String,
                createdAt: Value(DateTime.parse(s['created_at'] as String)),
              ),
            );
          }
        }

        for (final a in accountsList) {
          final accountId = a['id'] as String;
          final existing = await (db.select(db.accounts)..where((t) => t.id.equals(accountId))).getSingleOrNull();
          
          final companion = AccountsCompanion.insert(
            id: accountId,
            spaceId: a['space_id'] as String,
            accountName: a['account_name'] as String,
            username: a['username'] as String,
            encryptedPassword: a['encrypted_password'] as String,
            notes: Value(a['notes'] as String?),
            recoveryEmail: Value(a['recovery_email'] as String?),
            recoveryPhoneNumber: Value(a['recovery_phone_number'] as String?),
            websiteUrl: Value(a['website_url'] as String?),
            isFavorite: Value(a['is_favorite'] as bool),
            lastAccessedAt: Value(a['last_accessed_at'] != null ? DateTime.parse(a['last_accessed_at'] as String) : null),
            createdAt: Value(DateTime.parse(a['created_at'] as String)),
            updatedAt: Value(DateTime.parse(a['updated_at'] as String)),
          );

          if (existing == null) {
            await db.into(db.accounts).insert(companion);
          } else {
            // Overwrite existing accounts with imported data
            await db.update(db.accounts).replace(
              Account(
                id: accountId,
                spaceId: companion.spaceId.value,
                accountName: companion.accountName.value,
                username: companion.username.value,
                encryptedPassword: companion.encryptedPassword.value,
                notes: companion.notes.value,
                recoveryEmail: companion.recoveryEmail.value,
                recoveryPhoneNumber: companion.recoveryPhoneNumber.value,
                websiteUrl: companion.websiteUrl.value,
                isFavorite: companion.isFavorite.value,
                lastAccessedAt: companion.lastAccessedAt.value,
                createdAt: companion.createdAt.value,
                updatedAt: companion.updatedAt.value,
              ),
            );
          }
        }
      });

      return true;
    } catch (_) {
      return false;
    }
  }
}
