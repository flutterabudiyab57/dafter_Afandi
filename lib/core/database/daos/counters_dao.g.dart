// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counters_dao.dart';

// ignore_for_file: type=lint
mixin _$CountersDaoMixin on DatabaseAccessor<AppDatabase> {
  $CountersTable get counters => attachedDatabase.counters;
  CountersDaoManager get managers => CountersDaoManager(this);
}

class CountersDaoManager {
  final _$CountersDaoMixin _db;
  CountersDaoManager(this._db);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db.attachedDatabase, _db.counters);
}
