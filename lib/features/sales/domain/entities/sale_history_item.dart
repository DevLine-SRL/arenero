import '../../../../core/models/sync_status.dart';
import 'sale.dart';

class SaleHistoryItem {
  final String id;
  final int? number;
  final String clientName;
  final String clientCi;
  final DateTime saleDate;
  final double total;
  final SalePaymentMethod paymentMethod;
  final SyncStatus syncStatus;

  const SaleHistoryItem({
    required this.id,
    required this.number,
    required this.clientName,
    required this.clientCi,
    required this.saleDate,
    this.total = 0,
    required this.paymentMethod,
    this.syncStatus = SyncStatus.synced,
  });

  SaleHistoryItem copyWith({
    String? id,
    int? number,
    String? clientName,
    String? clientCi,
    DateTime? saleDate,
    double? total,
    SalePaymentMethod? paymentMethod,
    SyncStatus? syncStatus,
  }) {
    return SaleHistoryItem(
      id: id ?? this.id,
      number: number ?? this.number,
      clientName: clientName ?? this.clientName,
      clientCi: clientCi ?? this.clientCi,
      saleDate: saleDate ?? this.saleDate,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
