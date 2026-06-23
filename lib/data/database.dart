import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// Table for Spaces
class Spaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// Table for Accounts
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().customConstraint('REFERENCES spaces(id) ON DELETE CASCADE')();
  TextColumn get accountName => text().withLength(min: 1, max: 100)();
  TextColumn get username => text()();
  TextColumn get encryptedPassword => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get recoveryEmail => text().nullable()();
  TextColumn get recoveryPhoneNumber => text().nullable()();
  TextColumn get websiteUrl => text().nullable()();
  TextColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastAccessedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Spaces, Accounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ---------------- SPACERS QUERIES ----------------

  Stream<List<Space>> watchAllSpaces() => select(spaces).watch();

  Future<List<Space>> getAllSpaces() => select(spaces).get();

  Future<int> insertSpace(SpacesCompanion entity) => into(spaces).insert(entity);

  Future<bool> updateSpace(Space entity) => update(spaces).replace(entity);

  Future<int> deleteSpace(String spaceId) =>
      (delete(spaces)..where((tbl) => tbl.id.equals(spaceId))).go();

  // Watch count of accounts in a space
  Stream<int> watchAccountCount(String spaceId) {
    final query = select(accounts)..where((tbl) => tbl.spaceId.equals(spaceId));
    return query.watch().map((list) => list.length);
  }

  // Get count of accounts in a space
  Future<int> getAccountCount(String spaceId) async {
    final list = await (select(accounts)..where((tbl) => tbl.spaceId.equals(spaceId))).get();
    return list.length;
  }

  // ---------------- ACCOUNTS QUERIES ----------------

  // Watch all accounts in a specific space, ordered by isFavorite DESC, accountName ASC
  Stream<List<Account>> watchAccountsInSpace(String spaceId) {
    return (select(accounts)
          ..where((tbl) => tbl.spaceId.equals(spaceId))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.isFavorite, mode: OrderingMode.desc),
            (tbl) => OrderingTerm(expression: tbl.accountName, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  // Get favorite accounts across all spaces
  Stream<List<Account>> watchFavoriteAccounts() {
    return (select(accounts)
          ..where((tbl) => tbl.isFavorite.equals(true))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.accountName, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  // Get recently accessed accounts across all spaces
  Stream<List<Account>> watchRecentAccounts({int limit = 5}) {
    return (select(accounts)
          ..where((tbl) => tbl.lastAccessedAt.isNotNull())
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.lastAccessedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  // Real-time search inside a space (Prefix & Partial Matching, Case-Insensitive)
  Stream<List<Account>> searchAccounts(String spaceId, String queryText) {
    if (queryText.isEmpty) {
      return watchAccountsInSpace(spaceId);
    }
    final lowerQuery = '%${queryText.toLowerCase()}%';
    return (select(accounts)
          ..where((tbl) =>
              tbl.spaceId.equals(spaceId) &
              (tbl.accountName.lower().like(lowerQuery) |
               tbl.username.lower().like(lowerQuery) |
               tbl.notes.lower().like(lowerQuery)))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.isFavorite, mode: OrderingMode.desc),
            (tbl) => OrderingTerm(expression: tbl.accountName, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<Account?> getAccountById(String id) =>
      (select(accounts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertAccount(AccountsCompanion entity) => into(accounts).insert(entity);

  Future<bool> updateAccount(Account entity) => update(accounts).replace(entity);

  Future<int> deleteAccount(String accountId) =>
      (delete(accounts)..where((tbl) => tbl.id.equals(accountId))).go();

  Future<void> updateLastAccessed(String accountId) async {
    final account = await getAccountById(accountId);
    if (account != null) {
      await updateAccount(account.copyWith(
        lastAccessedAt: Value(DateTime.now()),
      ));
    }
  }

  // Clear entire database
  Future<void> clearDatabase() async {
    await delete(accounts).go();
    await delete(spaces).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      return WebDatabase('passec_db', logStatements: kDebugMode);
    }
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'passec.db'));
    return NativeDatabase(file);
  });
}
