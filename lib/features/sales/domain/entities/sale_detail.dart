import '../../../products/domain/entities/product.dart';

class SaleDetail {
  final String? id;
  final String productUnitId;
  final ProductUnitOfMeasure unit;
  final double quantity;

  /// Precio al que se vendió la unidad, congelado al registrar la venta. No es
  /// el precio actual del catálogo.
  final double unitPrice;
  final double discount;

  /// Nombre del producto. Solo viene en la consulta de detalle; el flujo de
  /// registro no lo necesita.
  final String? productName;

  const SaleDetail({
    this.id,
    required this.productUnitId,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
    this.productName,
  });

  double get subtotal => (quantity * unitPrice) - discount;

  SaleDetail copyWith({
    String? id,
    bool clearId = false,
    String? productUnitId,
    ProductUnitOfMeasure? unit,
    double? quantity,
    double? unitPrice,
    double? discount,
    String? productName,
  }) {
    return SaleDetail(
      id: clearId ? null : (id ?? this.id),
      productUnitId: productUnitId ?? this.productUnitId,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      productName: productName ?? this.productName,
    );
  }
}
