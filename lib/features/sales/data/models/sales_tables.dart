import 'package:drift/drift.dart';

class LocalSales extends Table {
  TextColumn get id => text()();
  IntColumn get number => integer().nullable()();
  TextColumn get clientId => text()();
  TextColumn get sellerId => text()();
  DateTimeColumn get saleDate => dateTime()();
  TextColumn get deliveryMode => text()();
  TextColumn get paymentMethod => text()();
  TextColumn get status => text()();
  RealColumn get total => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  TextColumn get syncError => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalSaleDetails extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productUnitId => text()();
  TextColumn get unit => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get discount => real()();
  TextColumn get productName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalSaleDeliveries extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get deliveryAddress => text().nullable()();
  TextColumn get vehiclePlate => text().nullable()();
  DateTimeColumn get deliveryDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
