class ProductReportRow {
  final String productUnitId;
  final String productName;
  final String unit;
  final double qtySold;
  final double totalAmount;

  const ProductReportRow({
    required this.productUnitId,
    required this.productName,
    required this.unit,
    required this.qtySold,
    required this.totalAmount,
  });
}
