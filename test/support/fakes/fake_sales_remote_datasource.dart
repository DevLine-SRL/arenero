import 'package:arenero/features/clients/data/models/client_model.dart';
import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:arenero/features/sales/data/models/sale_detail_model.dart';
import 'package:arenero/features/sales/data/models/sale_history_item_model.dart';
import 'package:arenero/features/sales/data/models/sale_model.dart';
import 'package:arenero/features/sales/data/models/sale_delivery_model.dart';
import 'package:arenero/features/sales/domain/entities/sale.dart';

/// Datasource de mentira, escrito a mano: el proyecto no usa librerías de
/// mocking. Los métodos que una prueba no configura lanzan
/// `UnimplementedError`, así que llamarlos sin querer falla de forma evidente.
class FakeSalesRemoteDataSource implements SalesRemoteDataSource {
  SaleModel? saleToReturn;
  Object? errorToThrow;
  double? lastRegisteredDiscountAmount;
  double? lastRegisteredFreightAmount;

  String? lastRequestedSaleId;
  int getSaleByIdCallCount = 0;

  @override
  Future<SaleModel> getSaleById(String saleId) async {
    getSaleByIdCallCount++;
    lastRequestedSaleId = saleId;
    final error = errorToThrow;
    if (error != null) throw error;
    return saleToReturn ?? buildSaleModel();
  }

  @override
  Future<SaleModel> registerSale({
    required String clientId,
    required String sellerId,
    required SaleDeliveryMode deliveryMode,
    required SalePaymentMethod paymentMethod,
    required double discountAmount,
    required double freightAmount,
    String? notes,
    SaleDeliveryModel? delivery,
    required List<SaleDetailModel> details,
  }) async {
    lastRegisteredDiscountAmount = discountAmount;
    lastRegisteredFreightAmount = freightAmount;
    final error = errorToThrow;
    if (error != null) throw error;
    return saleToReturn ??
        buildSaleModel(
          total: 100,
          discountAmount: discountAmount,
          freightAmount: freightAmount,
        );
  }

  @override
  Future<List<SaleModel>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<SaleHistoryItemModel>> getSalesHistory({
    DateTime? from,
    DateTime? to,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> voidSale(String saleId) async {
    throw UnimplementedError();
  }
}

SaleModel buildSaleModel({
  String? id = 'sale-1',
  int? number = 12,
  String? sellerName = 'Ana Vendedora',
  double total = 20,
  double discountAmount = 0,
  double freightAmount = 0,
  List<SaleDetailModel>? details,
}) {
  return SaleModel(
    id: id,
    number: number,
    client: const ClientModel(
      id: 'client-1',
      name: 'Juan Pérez',
      ci: '1234567',
      active: true,
    ),
    sellerId: 'seller-1',
    sellerName: sellerName,
    saleDate: DateTime(2026, 8, 10),
    deliveryMode: SaleDeliveryMode.customerPickup,
    paymentMethod: SalePaymentMethod.cash,
    total: total,
    discountAmount: discountAmount,
    freightAmount: freightAmount,
    details:
        details ??
        const [
          SaleDetailModel(
            id: 'detail-1',
            productUnitId: 'product-unit-1',
            unit: ProductUnitOfMeasure.m3,
            quantity: 2,
            unitPrice: 10,
            productName: 'Arena fina',
          ),
        ],
  );
}
