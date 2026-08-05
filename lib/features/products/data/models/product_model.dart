import '../../domain/entities/product.dart';

class ProductUnitPriceModel extends ProductUnitPrice {
  const ProductUnitPriceModel({
    required super.id,
    required super.productId,
    required super.unit,
    required super.unitPrice,
    required super.active,
  });

  factory ProductUnitPriceModel.fromJson(Map<String, dynamic> json) {
    return ProductUnitPriceModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      unit: ProductUnitOfMeasure.fromDatabase(json['unit'] as String),
      unitPrice: _toDouble(json['unit_price']),
      active: json['active'] as bool,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0;
  }
}

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.active,
    super.units,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawUnits = json['product_units'];
    final units = rawUnits is List
        ? [
            for (final unit in rawUnits)
              if (unit is Map<String, dynamic>)
                ProductUnitPriceModel.fromJson(unit)
              else if (unit is Map)
                ProductUnitPriceModel.fromJson(Map<String, dynamic>.from(unit)),
          ]
        : <ProductUnitPriceModel>[];

    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      active: json['active'] as bool,
      units: units,
    );
  }
}
