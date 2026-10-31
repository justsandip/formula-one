// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_database.dart';

// ignore_for_file: type=lint
class $StorageItemsTable extends StorageItems
    with TableInfo<$StorageItemsTable, StorageItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StorageItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'storage_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<StorageItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  StorageItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StorageItem(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $StorageItemsTable createAlias(String alias) {
    return $StorageItemsTable(attachedDatabase, alias);
  }
}

class StorageItem extends DataClass implements Insertable<StorageItem> {
  /// The identifier for the value
  final String key;

  /// The stored value
  final String value;
  const StorageItem({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  StorageItemsCompanion toCompanion(bool nullToAbsent) {
    return StorageItemsCompanion(key: Value(key), value: Value(value));
  }

  factory StorageItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StorageItem(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  StorageItem copyWith({String? key, String? value}) =>
      StorageItem(key: key ?? this.key, value: value ?? this.value);
  StorageItem copyWithCompanion(StorageItemsCompanion data) {
    return StorageItem(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StorageItem(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageItem &&
          other.key == this.key &&
          other.value == this.value);
}

class StorageItemsCompanion extends UpdateCompanion<StorageItem> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const StorageItemsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StorageItemsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<StorageItem> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StorageItemsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return StorageItemsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StorageItemsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$StorageDatabase extends GeneratedDatabase {
  _$StorageDatabase(QueryExecutor e) : super(e);
  $StorageDatabaseManager get managers => $StorageDatabaseManager(this);
  late final $StorageItemsTable storageItems = $StorageItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [storageItems];
}

typedef $$StorageItemsTableCreateCompanionBuilder =
    StorageItemsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$StorageItemsTableUpdateCompanionBuilder =
    StorageItemsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$StorageItemsTableFilterComposer
    extends Composer<_$StorageDatabase, $StorageItemsTable> {
  $$StorageItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StorageItemsTableOrderingComposer
    extends Composer<_$StorageDatabase, $StorageItemsTable> {
  $$StorageItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StorageItemsTableAnnotationComposer
    extends Composer<_$StorageDatabase, $StorageItemsTable> {
  $$StorageItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$StorageItemsTableTableManager
    extends
        RootTableManager<
          _$StorageDatabase,
          $StorageItemsTable,
          StorageItem,
          $$StorageItemsTableFilterComposer,
          $$StorageItemsTableOrderingComposer,
          $$StorageItemsTableAnnotationComposer,
          $$StorageItemsTableCreateCompanionBuilder,
          $$StorageItemsTableUpdateCompanionBuilder,
          (
            StorageItem,
            BaseReferences<_$StorageDatabase, $StorageItemsTable, StorageItem>,
          ),
          StorageItem,
          PrefetchHooks Function()
        > {
  $$StorageItemsTableTableManager(
    _$StorageDatabase db,
    $StorageItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StorageItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StorageItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StorageItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => StorageItemsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => StorageItemsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StorageItemsTable, StorageItem>(table),
                  BaseReferences<
                    _$StorageDatabase,
                    $StorageItemsTable,
                    StorageItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StorageItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$StorageDatabase,
      $StorageItemsTable,
      StorageItem,
      $$StorageItemsTableFilterComposer,
      $$StorageItemsTableOrderingComposer,
      $$StorageItemsTableAnnotationComposer,
      $$StorageItemsTableCreateCompanionBuilder,
      $$StorageItemsTableUpdateCompanionBuilder,
      (
        StorageItem,
        BaseReferences<_$StorageDatabase, $StorageItemsTable, StorageItem>,
      ),
      StorageItem,
      PrefetchHooks Function()
    >;

class $StorageDatabaseManager {
  final _$StorageDatabase _db;
  $StorageDatabaseManager(this._db);
  $$StorageItemsTableTableManager get storageItems =>
      $$StorageItemsTableTableManager(_db, _db.storageItems);
}
