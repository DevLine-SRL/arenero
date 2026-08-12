import 'package:drift/drift.dart';

class LocalClients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get ci => text()();
  TextColumn get nit => text().nullable()();
  BoolColumn get active => boolean()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
