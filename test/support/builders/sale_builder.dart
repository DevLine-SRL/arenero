import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/sales/domain/entities/sale.dart';
import 'package:arenero/features/sales/domain/entities/sale_delivery.dart';
import 'package:arenero/features/sales/domain/entities/sale_detail.dart';
import 'package:arenero/features/sales/domain/entities/sale_history_item.dart';

import 'client_builder.dart';

/// Línea de venta con valores por defecto razonables.
///
/// `unitPrice` es el precio al que se vendió, no el del catálogo: una prueba
/// que verifica el precio histórico lo fija a mano.
SaleDetail buildSaleDetail({
  String? id = 'detail-1',
  String productUnitId = 'product-unit-1',
  ProductUnitOfMeasure unit = ProductUnitOfMeasure.m3,
  double quantity = 2,
  double unitPrice = 10,
  double discount = 0,
  String? productName = 'Arena fina',
}) {
  return SaleDetail(
    id: id,
    productUnitId: productUnitId,
    unit: unit,
    quantity: quantity,
    unitPrice: unitPrice,
    discount: discount,
    productName: productName,
  );
}

Sale buildSale({
  String? id = 'sale-1',
  int? number = 12,
  String sellerId = 'seller-1',
  String? sellerName = 'Ana Vendedora',
  DateTime? saleDate,
  SaleDeliveryMode deliveryMode = SaleDeliveryMode.customerPickup,
  SalePaymentMethod paymentMethod = SalePaymentMethod.cash,
  SaleStatus status = SaleStatus.registered,
  double total = 20,
  String? notes,
  List<SaleDetail>? details,
  SaleDelivery? delivery,
}) {
  return Sale(
    id: id,
    number: number,
    client: buildClient(),
    sellerId: sellerId,
    sellerName: sellerName,
    saleDate: saleDate ?? DateTime(2026, 8, 10),
    deliveryMode: deliveryMode,
    paymentMethod: paymentMethod,
    status: status,
    total: total,
    notes: notes,
    details: details ?? [buildSaleDetail()],
    delivery: delivery,
  );
}

SaleHistoryItem buildSaleHistoryItem({
  String id = 'sale-1',
  int number = 12,
  String clientName = 'Juan Pérez',
  String clientCi = '1234567',
  DateTime? saleDate,
  double total = 20,
  SalePaymentMethod paymentMethod = SalePaymentMethod.cash,
}) {
  return SaleHistoryItem(
    id: id,
    number: number,
    clientName: clientName,
    clientCi: clientCi,
    saleDate: saleDate ?? DateTime(2026, 8, 10),
    total: total,
    paymentMethod: paymentMethod,
  );
}
