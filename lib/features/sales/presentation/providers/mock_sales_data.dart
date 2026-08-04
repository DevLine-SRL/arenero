// PROVISIONAL: datos de ejemplo para la capa de presentación.
// Replica la forma del esquema (sales, sale_details, product_units, clients)
// y se reemplazará por el catálogo real cuando exista la capa de dominio/datos.

enum DeliveryMode {
  customerPickup(dbValue: 'customer_pickup', label: 'Retiro en tienda'),
  companyDelivery(dbValue: 'company_delivery', label: 'Entrega a domicilio');

  final String dbValue;
  final String label;

  const DeliveryMode({required this.dbValue, required this.label});
}

enum PaymentMethod {
  cash(dbValue: 'cash', label: 'Efectivo'),
  transfer(dbValue: 'transfer', label: 'Transferencia'),
  qr(dbValue: 'qr', label: 'QR');

  final String dbValue;
  final String label;

  const PaymentMethod({required this.dbValue, required this.label});
}

enum UnitOfMeasure {
  m3(dbValue: 'm3', label: 'm³'),
  bag(dbValue: 'bag', label: 'Saco'),
  kg(dbValue: 'kg', label: 'kg'),
  ton(dbValue: 'ton', label: 'Ton'),
  unit(dbValue: 'unit', label: 'Unidad');

  final String dbValue;
  final String label;

  const UnitOfMeasure({required this.dbValue, required this.label});
}

class ProductUnitEntry {
  final UnitOfMeasure unit;
  final double unitPrice;

  const ProductUnitEntry({required this.unit, required this.unitPrice});
}

class ProductEntry {
  final String id;
  final String name;
  final List<ProductUnitEntry> units;

  const ProductEntry({required this.id, required this.name, required this.units});
}

class ClientEntry {
  final String id;
  final String name;
  final String ci;
  final String? phone;

  const ClientEntry({required this.id, required this.name, required this.ci, this.phone});
}

abstract final class MockCatalog {
  MockCatalog._();

  static const products = <ProductEntry>[
    ProductEntry(
      id: 'p-arena',
      name: 'Arena',
      units: [
        ProductUnitEntry(unit: UnitOfMeasure.m3, unitPrice: 123.00),
        ProductUnitEntry(unit: UnitOfMeasure.bag, unitPrice: 12.50),
        ProductUnitEntry(unit: UnitOfMeasure.ton, unitPrice: 245.00),
      ],
    ),
    ProductEntry(
      id: 'p-das',
      name: 'Das',
      units: [ProductUnitEntry(unit: UnitOfMeasure.bag, unitPrice: 312.12)],
    ),
    ProductEntry(
      id: 'p-cemento',
      name: 'Cemento',
      units: [
        ProductUnitEntry(unit: UnitOfMeasure.bag, unitPrice: 28.00),
        ProductUnitEntry(unit: UnitOfMeasure.ton, unitPrice: 560.00),
      ],
    ),
    ProductEntry(
      id: 'p-piedra',
      name: 'Piedra chancada',
      units: [
        ProductUnitEntry(unit: UnitOfMeasure.m3, unitPrice: 180.00),
        ProductUnitEntry(unit: UnitOfMeasure.bag, unitPrice: 18.50),
        ProductUnitEntry(unit: UnitOfMeasure.ton, unitPrice: 360.00),
      ],
    ),
    ProductEntry(
      id: 'p-confitillo',
      name: 'Confitillo',
      units: [
        ProductUnitEntry(unit: UnitOfMeasure.m3, unitPrice: 95.00),
        ProductUnitEntry(unit: UnitOfMeasure.bag, unitPrice: 10.00),
      ],
    ),
  ];

  static const clients = <ClientEntry>[
    ClientEntry(
      id: 'c-1',
      name: 'Juan Pérez',
      ci: '12345678',
      phone: '+51 987 654 321',
    ),
    ClientEntry(
      id: 'c-2',
      name: 'María López',
      ci: '87654321',
      phone: '+51 912 345 678',
    ),
    ClientEntry(id: 'c-3', name: 'Carlos Quispe', ci: '11223344'),
    ClientEntry(
      id: 'c-4',
      name: 'Sofía Ramírez',
      ci: '55667788',
      phone: '+51 933 111 222',
    ),
  ];
}