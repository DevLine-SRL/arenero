import 'sale.dart';

class SaleHistoryItem {
  final int number;
  final String clientName;
  final String clientCi;
  final DateTime saleDate;
  final double total;
  final SalePaymentMethod paymentMethod;

  const SaleHistoryItem({
    required this.number,
    required this.clientName,
    required this.clientCi,
    required this.saleDate,
    this.total = 0,
    required this.paymentMethod,
  });

  SaleHistoryItem copyWith({
    int? number,
    String? clientName,
    String? clientCi,
    DateTime? saleDate,
    double? total,
    SalePaymentMethod? paymentMethod,
  }) {
    return SaleHistoryItem(
      number: number ?? this.number,
      clientName: clientName ?? this.clientName,
      clientCi: clientCi ?? this.clientCi,
      saleDate: saleDate ?? this.saleDate,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
