import '../../../products/domain/entities/product.dart';
import '../../domain/entities/sale_detail.dart';

class SaleDetailModel extends SaleDetail {
  const SaleDetailModel({
    super.id,
    required super.productUnitId,
    required super.unit,
    required super.quantity,
    required super.unitPrice,
    super.discount,
  });

  factory SaleDetailModel.fromJson(Map<String, dynamic> json) {
    final productUnit = json['product_unit'];
    return SaleDetailModel(
      id: json['id'] as String?,
      productUnitId: json['product_unit_id'] as String,
      unit: productUnit is Map
          ? ProductUnitOfMeasure.fromDatabase(productUnit['unit'] as String)
          : ProductUnitOfMeasure.unit,
      quantity: _toDouble(json['quantity']),
      unitPrice: _toDouble(json['unit_price']),
      discount: _toDouble(json['discount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_unit_id': productUnitId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
    };
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0;
  }
}
