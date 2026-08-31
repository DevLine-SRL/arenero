import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/sale.dart';
import '../models/sale_detail_model.dart';
import '../models/sale_delivery_model.dart';
import '../models/sale_history_item_model.dart';
import '../models/sale_model.dart';

// ============================================================
// CONSULTA DE VENTA
// ============================================================
//
// El precio utilizado en una venta histórica se obtiene desde:
//
// sale_details.unit_price
//
// No se utiliza product_units.unit_price porque ese valor puede
// cambiar posteriormente en el catálogo.
//
// HU-04:
// También recuperamos:
//
// - payment_status
// - amount_paid
// - pending_amount
//
// para reconstruir correctamente el estado del cobro.
// ============================================================

const String _saleSelect = '''
  id,
  number,
  client_id,
  seller_id,
  sale_date,
  delivery_mode,
  payment_method,
  payment_status,
  status,
  total,
  discount_amount,
  freight_amount,
  amount_paid,
  pending_amount,
  notes,

  client:clients(
    id,
    name,
    phone,
    ci,
    nit,
    active
  ),

  seller:profiles(
    id,
    name,
    email
  ),

  sale_details(
    id,
    sale_id,
    product_unit_id,
    quantity,
    unit_price,
    discount,

    product_unit:product_units(
      unit,

      product:products(
        name
      )
    )
  ),

  sale_deliveries(
    id,
    sale_id,
    delivery_address,
    vehicle_plate,
    delivery_date
  )
''';

// ============================================================
// CONTRATO
// ============================================================

abstract class SalesRemoteDataSource {
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
  });

  /// HU-04:
  ///
  /// Actualiza el estado del cobro después de que la venta
  /// haya sido registrada.
  Future<void> updateSalePayment({
    required String saleId,
    required SalePaymentStatus paymentStatus,
    required double amountPaid,
    required double pendingAmount,
  });

  Future<List<SaleModel>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  });

  Future<List<SaleHistoryItemModel>> getSalesHistory({
    DateTime? from,
    DateTime? to,
  });

  Future<SaleModel> getSaleById(String saleId);

  Future<void> voidSale(String saleId);
}

// ============================================================
// IMPLEMENTACIÓN SUPABASE
// ============================================================

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final supabase.SupabaseClient client;

  const SalesRemoteDataSourceImpl(this.client);

  // ============================================================
  // REGISTRAR VENTA
  // ============================================================

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
    // ----------------------------------------------------------
    // HU-02
    //
    // Segunda capa de seguridad.
    //
    // Recoge en planta:
    // freight = 0
    // delivery = null
    //
    // Domicilio:
    // se permite delivery y flete.
    // ----------------------------------------------------------

    final effectiveFreight =
        deliveryMode == SaleDeliveryMode.companyDelivery && freightAmount > 0
        ? freightAmount
        : 0.0;

    final effectiveDelivery = deliveryMode == SaleDeliveryMode.companyDelivery
        ? delivery
        : null;

    // ----------------------------------------------------------
    // Ejecutar RPC
    // ----------------------------------------------------------

    final rawSaleId = await client.rpc(
      'register_sale',
      params: {
        'p_client_id': clientId,

        'p_seller_id': sellerId,

        'p_delivery_mode': deliveryMode.dbValue,

        'p_payment_method': paymentMethod.dbValue,

        'p_discount_amount': discountAmount < 0 ? 0 : discountAmount,

        'p_freight_amount': effectiveFreight,

        'p_notes': notes,

        'p_delivery': effectiveDelivery?.toJson(),

        'p_details': [for (final detail in details) detail.toJson()],
      },
    );

    // ----------------------------------------------------------
    // Validar resultado del RPC
    // ----------------------------------------------------------

    if (rawSaleId is! String || rawSaleId.trim().isEmpty) {
      throw supabase.PostgrestException(
        message: 'No se recibió el identificador de la venta registrada.',
        code: 'INVALID_SALE_ID',
        details: rawSaleId?.toString() ?? '',
        hint: 'Verifica que el RPC register_sale retorne el UUID de la venta.',
      );
    }

    // ----------------------------------------------------------
    // Recuperar venta completa
    // ----------------------------------------------------------

    return getSaleById(rawSaleId.trim());
  }

  // ============================================================
  // HU-04 - ACTUALIZAR COBRO
  // ============================================================

  @override
  Future<void> updateSalePayment({
    required String saleId,
    required SalePaymentStatus paymentStatus,
    required double amountPaid,
    required double pendingAmount,
  }) async {
    final normalizedSaleId = saleId.trim();

    if (normalizedSaleId.isEmpty) {
      throw supabase.PostgrestException(
        message: 'El identificador de la venta es obligatorio.',
        code: 'INVALID_SALE_ID',
        details: '',
        hint: '',
      );
    }

    final safeAmountPaid = amountPaid < 0 ? 0.0 : amountPaid;

    final safePendingAmount = pendingAmount < 0 ? 0.0 : pendingAmount;

    /*
     * La aplicación envía amountPaid y pendingAmount,
     * pero la base de datos debe continuar siendo la
     * autoridad final.
     *
     * El trigger/RPC de la migración puede recalcular
     * pending_amount antes de persistirlo.
     */
    await client.rpc(
      'update_sale_payment',
      params: {
        'p_sale_id': normalizedSaleId,

        'p_payment_status': paymentStatus.dbValue,

        'p_amount_paid': safeAmountPaid,

        'p_pending_amount': safePendingAmount,
      },
    );
  }

  // ============================================================
  // CONSULTAR VENTAS
  // ============================================================

  @override
  Future<List<SaleModel>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    var query = client.from('sales').select(_saleSelect);

    if (status != null) {
      query = query.eq('status', status.dbValue);
    }

    if (from != null) {
      query = query.gte('sale_date', from.toIso8601String());
    }

    if (to != null) {
      query = query.lte('sale_date', to.toIso8601String());
    }

    final rows = await query.order('sale_date', ascending: false);

    return [for (final row in rows) SaleModel.fromJson(row)];
  }

  // ============================================================
  // HISTORIAL
  // ============================================================

  @override
  Future<List<SaleHistoryItemModel>> getSalesHistory({
    DateTime? from,
    DateTime? to,
  }) async {
    var query = client.from('v_sales').select();

    if (from != null) {
      query = query.gte('sale_date', from.toIso8601String());
    }

    if (to != null) {
      final endOfDay = DateTime(to.year, to.month, to.day, 23, 59, 59);

      query = query.lte('sale_date', endOfDay.toIso8601String());
    }

    final rows = await query.order('sale_date', ascending: false);

    return [for (final row in rows) SaleHistoryItemModel.fromJson(row)];
  }

  // ============================================================
  // ANULAR VENTA
  // ============================================================

  @override
  Future<void> voidSale(String saleId) async {
    final normalizedSaleId = saleId.trim();

    if (normalizedSaleId.isEmpty) {
      throw supabase.PostgrestException(
        message: 'El identificador de la venta es obligatorio.',
        code: 'INVALID_SALE_ID',
        details: '',
        hint: '',
      );
    }

    await client.rpc('void_sale', params: {'p_sale_id': normalizedSaleId});
  }

  // ============================================================
  // OBTENER VENTA POR ID
  // ============================================================

  @override
  Future<SaleModel> getSaleById(String saleId) async {
    final normalizedSaleId = saleId.trim();

    if (normalizedSaleId.isEmpty) {
      throw supabase.PostgrestException(
        message: 'El identificador de la venta es obligatorio.',
        code: 'INVALID_SALE_ID',
        details: '',
        hint: '',
      );
    }

    final rows = await client
        .from('sales')
        .select(_saleSelect)
        .eq('id', normalizedSaleId);

    if (rows.isEmpty) {
      throw supabase.PostgrestException(
        message: 'La venta no existe.',
        code: 'PGRST116',
        details: '',
        hint: '',
      );
    }

    return SaleModel.fromJson(rows.first);
  }
}
