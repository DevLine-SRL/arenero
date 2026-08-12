import 'package:drift/drift.dart';

class LocalProducts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get active => boolean()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalProductUnits extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get unit => text()();
  RealColumn get unitPrice => real()();
  BoolColumn get active => boolean()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
