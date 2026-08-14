import 'package:drift/drift.dart';

class LocalClients extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get ci => text()();
  TextColumn get nit => text().nullable()();
  BoolColumn get active => boolean()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
