enum ProductUnitOfMeasure {
  m3,
  bag,
  kg,
  ton,
  unit;

  String get databaseValue => switch (this) {
    ProductUnitOfMeasure.m3 => 'm3',
    ProductUnitOfMeasure.bag => 'bag',
    ProductUnitOfMeasure.kg => 'kg',
    ProductUnitOfMeasure.ton => 'ton',
    ProductUnitOfMeasure.unit => 'unit',
  };

  String get label => switch (this) {
    ProductUnitOfMeasure.m3 => 'Metro cubico',
    ProductUnitOfMeasure.bag => 'Bolsa',
    ProductUnitOfMeasure.kg => 'Kilogramo',
    ProductUnitOfMeasure.ton => 'Tonelada',
    ProductUnitOfMeasure.unit => 'Unidad',
  };

  String get shortLabel => switch (this) {
    ProductUnitOfMeasure.m3 => 'm³',
    ProductUnitOfMeasure.bag => 'bolsa',
    ProductUnitOfMeasure.kg => 'kg',
    ProductUnitOfMeasure.ton => 'ton',
    ProductUnitOfMeasure.unit => 'un',
  };

  static ProductUnitOfMeasure fromDatabase(String value) {
    return ProductUnitOfMeasure.values.firstWhere(
      (unit) => unit.databaseValue == value,
      orElse: () => ProductUnitOfMeasure.unit,
    );
  }
}

class ProductUnitPrice {
  final String id;
  final String productId;
  final ProductUnitOfMeasure unit;
  final double unitPrice;
  final bool active;

  const ProductUnitPrice({
    required this.id,
    required this.productId,
    required this.unit,
    required this.unitPrice,
    required this.active,
  });

  ProductUnitPrice copyWith({
    String? id,
    String? productId,
    ProductUnitOfMeasure? unit,
    double? unitPrice,
    bool? active,
  }) {
    return ProductUnitPrice(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      active: active ?? this.active,
    );
  }
}

class Product {
  final String id;
  final String name;
  final bool active;
  final List<ProductUnitPrice> units;

  const Product({
    required this.id,
    required this.name,
    required this.active,
    this.units = const [],
  });

  ProductUnitPrice? get primaryUnit {
    final activeUnits = units.where((unit) => unit.active);
    if (activeUnits.isNotEmpty) return activeUnits.first;
    return units.isEmpty ? null : units.first;
  }

  Product copyWith({
    String? id,
    String? name,
    bool? active,
    List<ProductUnitPrice>? units,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
      units: units ?? this.units,
    );
  }
}
