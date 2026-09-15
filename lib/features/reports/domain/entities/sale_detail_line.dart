class SaleDetailLine {
  final String saleId;
  final String number;
  final DateTime saleDate;
  final String productName;
  final String unit;
  final double quantity;
  final double subtotal;

  const SaleDetailLine({
    required this.saleId,
    required this.number,
    required this.saleDate,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.subtotal,
  });
}
