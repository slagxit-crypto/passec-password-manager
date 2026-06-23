// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SpacesTable extends Spaces with TableInfo<$SpacesTable, Space> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(Insertable<Space> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Space map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Space(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SpacesTable createAlias(String alias) {
    return $SpacesTable(attachedDatabase, alias);
  }
}

class Space extends DataClass implements Insertable<Space> {
  final String id;
  final String name;
  final DateTime createdAt;
  const Space({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SpacesCompanion toCompanion(bool nullToAbsent) {
    return SpacesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Space.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Space(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Space copyWith({String? id, String? name, DateTime? createdAt}) => Space(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  Space copyWithCompanion(SpacesCompanion data) {
    return Space(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Space(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Space &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class SpacesCompanion extends UpdateCompanion<Space> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SpacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpacesCompanion.insert({
    required String id,
    required String name,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Space> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpacesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SpacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _spaceIdMeta =
      const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
      'space_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES spaces(id) ON DELETE CASCADE');
  static const VerificationMeta _accountNameMeta =
      const VerificationMeta('accountName');
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
      'account_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _encryptedPasswordMeta =
      const VerificationMeta('encryptedPassword');
  @override
  late final GeneratedColumn<String> encryptedPassword =
      GeneratedColumn<String>('encrypted_password', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recoveryEmailMeta =
      const VerificationMeta('recoveryEmail');
  @override
  late final GeneratedColumn<String> recoveryEmail = GeneratedColumn<String>(
      'recovery_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recoveryPhoneNumberMeta =
      const VerificationMeta('recoveryPhoneNumber');
  @override
  late final GeneratedColumn<String> recoveryPhoneNumber =
      GeneratedColumn<String>('recovery_phone_number', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _websiteUrlMeta =
      const VerificationMeta('websiteUrl');
  @override
  late final GeneratedColumn<String> websiteUrl = GeneratedColumn<String>(
      'website_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastAccessedAtMeta =
      const VerificationMeta('lastAccessedAt');
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>('last_accessed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        spaceId,
        accountName,
        username,
        encryptedPassword,
        notes,
        recoveryEmail,
        recoveryPhoneNumber,
        websiteUrl,
        isFavorite,
        lastAccessedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta,
          spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('account_name')) {
      context.handle(
          _accountNameMeta,
          accountName.isAcceptableOrUnknown(
              data['account_name']!, _accountNameMeta));
    } else if (isInserting) {
      context.missing(_accountNameMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('encrypted_password')) {
      context.handle(
          _encryptedPasswordMeta,
          encryptedPassword.isAcceptableOrUnknown(
              data['encrypted_password']!, _encryptedPasswordMeta));
    } else if (isInserting) {
      context.missing(_encryptedPasswordMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('recovery_email')) {
      context.handle(
          _recoveryEmailMeta,
          recoveryEmail.isAcceptableOrUnknown(
              data['recovery_email']!, _recoveryEmailMeta));
    }
    if (data.containsKey('recovery_phone_number')) {
      context.handle(
          _recoveryPhoneNumberMeta,
          recoveryPhoneNumber.isAcceptableOrUnknown(
              data['recovery_phone_number']!, _recoveryPhoneNumberMeta));
    }
    if (data.containsKey('website_url')) {
      context.handle(
          _websiteUrlMeta,
          websiteUrl.isAcceptableOrUnknown(
              data['website_url']!, _websiteUrlMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
          _lastAccessedAtMeta,
          lastAccessedAt.isAcceptableOrUnknown(
              data['last_accessed_at']!, _lastAccessedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      spaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      accountName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_name'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      encryptedPassword: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encrypted_password'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      recoveryEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recovery_email']),
      recoveryPhoneNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recovery_phone_number']),
      websiteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website_url']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_accessed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String spaceId;
  final String accountName;
  final String username;
  final String encryptedPassword;
  final String? notes;
  final String? recoveryEmail;
  final String? recoveryPhoneNumber;
  final String? websiteUrl;
  final bool isFavorite;
  final DateTime? lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Account(
      {required this.id,
      required this.spaceId,
      required this.accountName,
      required this.username,
      required this.encryptedPassword,
      this.notes,
      this.recoveryEmail,
      this.recoveryPhoneNumber,
      this.websiteUrl,
      required this.isFavorite,
      this.lastAccessedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['account_name'] = Variable<String>(accountName);
    map['username'] = Variable<String>(username);
    map['encrypted_password'] = Variable<String>(encryptedPassword);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || recoveryEmail != null) {
      map['recovery_email'] = Variable<String>(recoveryEmail);
    }
    if (!nullToAbsent || recoveryPhoneNumber != null) {
      map['recovery_phone_number'] = Variable<String>(recoveryPhoneNumber);
    }
    if (!nullToAbsent || websiteUrl != null) {
      map['website_url'] = Variable<String>(websiteUrl);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      accountName: Value(accountName),
      username: Value(username),
      encryptedPassword: Value(encryptedPassword),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      recoveryEmail: recoveryEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryEmail),
      recoveryPhoneNumber: recoveryPhoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryPhoneNumber),
      websiteUrl: websiteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(websiteUrl),
      isFavorite: Value(isFavorite),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      accountName: serializer.fromJson<String>(json['accountName']),
      username: serializer.fromJson<String>(json['username']),
      encryptedPassword: serializer.fromJson<String>(json['encryptedPassword']),
      notes: serializer.fromJson<String?>(json['notes']),
      recoveryEmail: serializer.fromJson<String?>(json['recoveryEmail']),
      recoveryPhoneNumber:
          serializer.fromJson<String?>(json['recoveryPhoneNumber']),
      websiteUrl: serializer.fromJson<String?>(json['websiteUrl']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      lastAccessedAt: serializer.fromJson<DateTime?>(json['lastAccessedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'accountName': serializer.toJson<String>(accountName),
      'username': serializer.toJson<String>(username),
      'encryptedPassword': serializer.toJson<String>(encryptedPassword),
      'notes': serializer.toJson<String?>(notes),
      'recoveryEmail': serializer.toJson<String?>(recoveryEmail),
      'recoveryPhoneNumber': serializer.toJson<String?>(recoveryPhoneNumber),
      'websiteUrl': serializer.toJson<String?>(websiteUrl),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'lastAccessedAt': serializer.toJson<DateTime?>(lastAccessedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Account copyWith(
          {String? id,
          String? spaceId,
          String? accountName,
          String? username,
          String? encryptedPassword,
          Value<String?> notes = const Value.absent(),
          Value<String?> recoveryEmail = const Value.absent(),
          Value<String?> recoveryPhoneNumber = const Value.absent(),
          Value<String?> websiteUrl = const Value.absent(),
          bool? isFavorite,
          Value<DateTime?> lastAccessedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Account(
        id: id ?? this.id,
        spaceId: spaceId ?? this.spaceId,
        accountName: accountName ?? this.accountName,
        username: username ?? this.username,
        encryptedPassword: encryptedPassword ?? this.encryptedPassword,
        notes: notes.present ? notes.value : this.notes,
        recoveryEmail:
            recoveryEmail.present ? recoveryEmail.value : this.recoveryEmail,
        recoveryPhoneNumber: recoveryPhoneNumber.present
            ? recoveryPhoneNumber.value
            : this.recoveryPhoneNumber,
        websiteUrl: websiteUrl.present ? websiteUrl.value : this.websiteUrl,
        isFavorite: isFavorite ?? this.isFavorite,
        lastAccessedAt:
            lastAccessedAt.present ? lastAccessedAt.value : this.lastAccessedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      accountName:
          data.accountName.present ? data.accountName.value : this.accountName,
      username: data.username.present ? data.username.value : this.username,
      encryptedPassword: data.encryptedPassword.present
          ? data.encryptedPassword.value
          : this.encryptedPassword,
      notes: data.notes.present ? data.notes.value : this.notes,
      recoveryEmail: data.recoveryEmail.present
          ? data.recoveryEmail.value
          : this.recoveryEmail,
      recoveryPhoneNumber: data.recoveryPhoneNumber.present
          ? data.recoveryPhoneNumber.value
          : this.recoveryPhoneNumber,
      websiteUrl:
          data.websiteUrl.present ? data.websiteUrl.value : this.websiteUrl,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('accountName: $accountName, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('notes: $notes, ')
          ..write('recoveryEmail: $recoveryEmail, ')
          ..write('recoveryPhoneNumber: $recoveryPhoneNumber, ')
          ..write('websiteUrl: $websiteUrl, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      spaceId,
      accountName,
      username,
      encryptedPassword,
      notes,
      recoveryEmail,
      recoveryPhoneNumber,
      websiteUrl,
      isFavorite,
      lastAccessedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.accountName == this.accountName &&
          other.username == this.username &&
          other.encryptedPassword == this.encryptedPassword &&
          other.notes == this.notes &&
          other.recoveryEmail == this.recoveryEmail &&
          other.recoveryPhoneNumber == this.recoveryPhoneNumber &&
          other.websiteUrl == this.websiteUrl &&
          other.isFavorite == this.isFavorite &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> accountName;
  final Value<String> username;
  final Value<String> encryptedPassword;
  final Value<String?> notes;
  final Value<String?> recoveryEmail;
  final Value<String?> recoveryPhoneNumber;
  final Value<String?> websiteUrl;
  final Value<bool> isFavorite;
  final Value<DateTime?> lastAccessedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.accountName = const Value.absent(),
    this.username = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.notes = const Value.absent(),
    this.recoveryEmail = const Value.absent(),
    this.recoveryPhoneNumber = const Value.absent(),
    this.websiteUrl = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String spaceId,
    required String accountName,
    required String username,
    required String encryptedPassword,
    this.notes = const Value.absent(),
    this.recoveryEmail = const Value.absent(),
    this.recoveryPhoneNumber = const Value.absent(),
    this.websiteUrl = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        spaceId = Value(spaceId),
        accountName = Value(accountName),
        username = Value(username),
        encryptedPassword = Value(encryptedPassword);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? accountName,
    Expression<String>? username,
    Expression<String>? encryptedPassword,
    Expression<String>? notes,
    Expression<String>? recoveryEmail,
    Expression<String>? recoveryPhoneNumber,
    Expression<String>? websiteUrl,
    Expression<bool>? isFavorite,
    Expression<DateTime>? lastAccessedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (accountName != null) 'account_name': accountName,
      if (username != null) 'username': username,
      if (encryptedPassword != null) 'encrypted_password': encryptedPassword,
      if (notes != null) 'notes': notes,
      if (recoveryEmail != null) 'recovery_email': recoveryEmail,
      if (recoveryPhoneNumber != null)
        'recovery_phone_number': recoveryPhoneNumber,
      if (websiteUrl != null) 'website_url': websiteUrl,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? spaceId,
      Value<String>? accountName,
      Value<String>? username,
      Value<String>? encryptedPassword,
      Value<String?>? notes,
      Value<String?>? recoveryEmail,
      Value<String?>? recoveryPhoneNumber,
      Value<String?>? websiteUrl,
      Value<bool>? isFavorite,
      Value<DateTime?>? lastAccessedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      accountName: accountName ?? this.accountName,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      notes: notes ?? this.notes,
      recoveryEmail: recoveryEmail ?? this.recoveryEmail,
      recoveryPhoneNumber: recoveryPhoneNumber ?? this.recoveryPhoneNumber,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (encryptedPassword.present) {
      map['encrypted_password'] = Variable<String>(encryptedPassword.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recoveryEmail.present) {
      map['recovery_email'] = Variable<String>(recoveryEmail.value);
    }
    if (recoveryPhoneNumber.present) {
      map['recovery_phone_number'] =
          Variable<String>(recoveryPhoneNumber.value);
    }
    if (websiteUrl.present) {
      map['website_url'] = Variable<String>(websiteUrl.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('accountName: $accountName, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('notes: $notes, ')
          ..write('recoveryEmail: $recoveryEmail, ')
          ..write('recoveryPhoneNumber: $recoveryPhoneNumber, ')
          ..write('websiteUrl: $websiteUrl, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SpacesTable spaces = $SpacesTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [spaces, accounts];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('spaces',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('accounts', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SpacesTableCreateCompanionBuilder = SpacesCompanion Function({
  required String id,
  required String name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SpacesTableUpdateCompanionBuilder = SpacesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SpacesTableReferences
    extends BaseReferences<_$AppDatabase, $SpacesTable, Space> {
  $$SpacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountsTable, List<Account>> _accountsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.accounts,
          aliasName: $_aliasNameGenerator(db.spaces.id, db.accounts.spaceId));

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SpacesTableFilterComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> accountsRefs(
      Expression<bool> Function($$AccountsTableFilterComposer f) f) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.spaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SpacesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SpacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> accountsRefs<T extends Object>(
      Expression<T> Function($$AccountsTableAnnotationComposer a) f) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.spaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SpacesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SpacesTable,
    Space,
    $$SpacesTableFilterComposer,
    $$SpacesTableOrderingComposer,
    $$SpacesTableAnnotationComposer,
    $$SpacesTableCreateCompanionBuilder,
    $$SpacesTableUpdateCompanionBuilder,
    (Space, $$SpacesTableReferences),
    Space,
    PrefetchHooks Function({bool accountsRefs})> {
  $$SpacesTableTableManager(_$AppDatabase db, $SpacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpacesCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpacesCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SpacesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({accountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (accountsRefs) db.accounts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (accountsRefs)
                    await $_getPrefetchedData<Space, $SpacesTable, Account>(
                        currentTable: table,
                        referencedTable:
                            $$SpacesTableReferences._accountsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SpacesTableReferences(db, table, p0).accountsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.spaceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SpacesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SpacesTable,
    Space,
    $$SpacesTableFilterComposer,
    $$SpacesTableOrderingComposer,
    $$SpacesTableAnnotationComposer,
    $$SpacesTableCreateCompanionBuilder,
    $$SpacesTableUpdateCompanionBuilder,
    (Space, $$SpacesTableReferences),
    Space,
    PrefetchHooks Function({bool accountsRefs})>;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String spaceId,
  required String accountName,
  required String username,
  required String encryptedPassword,
  Value<String?> notes,
  Value<String?> recoveryEmail,
  Value<String?> recoveryPhoneNumber,
  Value<String?> websiteUrl,
  Value<bool> isFavorite,
  Value<DateTime?> lastAccessedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> spaceId,
  Value<String> accountName,
  Value<String> username,
  Value<String> encryptedPassword,
  Value<String?> notes,
  Value<String?> recoveryEmail,
  Value<String?> recoveryPhoneNumber,
  Value<String?> websiteUrl,
  Value<bool> isFavorite,
  Value<DateTime?> lastAccessedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _spaceIdTable(_$AppDatabase db) => db.spaces
      .createAlias($_aliasNameGenerator(db.accounts.spaceId, db.spaces.id));

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager($_db, $_db.spaces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountName => $composableBuilder(
      column: $table.accountName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptedPassword => $composableBuilder(
      column: $table.encryptedPassword,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recoveryEmail => $composableBuilder(
      column: $table.recoveryEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recoveryPhoneNumber => $composableBuilder(
      column: $table.recoveryPhoneNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get websiteUrl => $composableBuilder(
      column: $table.websiteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableFilterComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountName => $composableBuilder(
      column: $table.accountName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptedPassword => $composableBuilder(
      column: $table.encryptedPassword,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recoveryEmail => $composableBuilder(
      column: $table.recoveryEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recoveryPhoneNumber => $composableBuilder(
      column: $table.recoveryPhoneNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get websiteUrl => $composableBuilder(
      column: $table.websiteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableOrderingComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountName => $composableBuilder(
      column: $table.accountName, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get encryptedPassword => $composableBuilder(
      column: $table.encryptedPassword, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get recoveryEmail => $composableBuilder(
      column: $table.recoveryEmail, builder: (column) => column);

  GeneratedColumn<String> get recoveryPhoneNumber => $composableBuilder(
      column: $table.recoveryPhoneNumber, builder: (column) => column);

  GeneratedColumn<String> get websiteUrl => $composableBuilder(
      column: $table.websiteUrl, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $db.spaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpacesTableAnnotationComposer(
              $db: $db,
              $table: $db.spaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool spaceId})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> spaceId = const Value.absent(),
            Value<String> accountName = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> encryptedPassword = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> recoveryEmail = const Value.absent(),
            Value<String?> recoveryPhoneNumber = const Value.absent(),
            Value<String?> websiteUrl = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> lastAccessedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            spaceId: spaceId,
            accountName: accountName,
            username: username,
            encryptedPassword: encryptedPassword,
            notes: notes,
            recoveryEmail: recoveryEmail,
            recoveryPhoneNumber: recoveryPhoneNumber,
            websiteUrl: websiteUrl,
            isFavorite: isFavorite,
            lastAccessedAt: lastAccessedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String spaceId,
            required String accountName,
            required String username,
            required String encryptedPassword,
            Value<String?> notes = const Value.absent(),
            Value<String?> recoveryEmail = const Value.absent(),
            Value<String?> recoveryPhoneNumber = const Value.absent(),
            Value<String?> websiteUrl = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> lastAccessedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            spaceId: spaceId,
            accountName: accountName,
            username: username,
            encryptedPassword: encryptedPassword,
            notes: notes,
            recoveryEmail: recoveryEmail,
            recoveryPhoneNumber: recoveryPhoneNumber,
            websiteUrl: websiteUrl,
            isFavorite: isFavorite,
            lastAccessedAt: lastAccessedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({spaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (spaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.spaceId,
                    referencedTable:
                        $$AccountsTableReferences._spaceIdTable(db),
                    referencedColumn:
                        $$AccountsTableReferences._spaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool spaceId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SpacesTableTableManager get spaces =>
      $$SpacesTableTableManager(_db, _db.spaces);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
}
