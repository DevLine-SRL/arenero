import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/sale.dart';
import '../models/sale_detail_model.dart';
import '../models/sale_delivery_model.dart';
import '../models/sale_history_item_model.dart';
import '../models/sale_model.dart';

const String _saleSelect = '''
  id, client_id, seller_id, sale_date, delivery_mode, payment_method,
  status, total, notes,
  client:clients(id, name, phone, ci, nit, active),
  sale_details(id, sale_id, product_unit_id, quantity, unit_price, discount,
    product_unit:product_units(unit)),
  sale_deliveries(id, sale_id, delivery_address, vehicle_plate, delivery_date)
''';

abstract class SalesRemoteDataSource {
  Future<SaleModel> registerSale({
    required String clientId,
    required String sellerId,
    required SaleDeliveryMode deliveryMode,
    required SalePaymentMethod paymentMethod,
    String? notes,
    SaleDeliveryModel? delivery,
    required List<SaleDetailModel> details,
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

  Future<void> voidSale(String saleId);
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final supabase.SupabaseClient client;

  const SalesRemoteDataSourceImpl(this.client);

  @override
  Future<SaleModel> registerSale({
    required String clientId,
    required String sellerId,
    required SaleDeliveryMode deliveryMode,
    required SalePaymentMethod paymentMethod,
    String? notes,
    SaleDeliveryModel? delivery,
    required List<SaleDetailModel> details,
  }) async {
    final saleId = await client.rpc(
      'register_sale',
      params: {
        'p_client_id': clientId,
        'p_seller_id': sellerId,
        'p_delivery_mode': deliveryMode.dbValue,
        'p_payment_method': paymentMethod.dbValue,
        'p_notes': notes,
        'p_delivery': delivery?.toJson(),
        'p_details': [for (final detail in details) detail.toJson()],
      },
    );

    return _fetchSale(saleId as String);
  }

  @override
  Future<List<SaleModel>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    var query = client.from('sales').select(_saleSelect);

    if (status != null) query = query.eq('status', status.dbValue);
    if (from != null) query = query.gte('sale_date', from.toIso8601String());
    if (to != null) query = query.lte('sale_date', to.toIso8601String());

    final rows = await query.order('sale_date', ascending: false);
    return [for (final row in rows) SaleModel.fromJson(row)];
  }

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

  @override
  Future<void> voidSale(String saleId) async {
    await client.rpc('void_sale', params: {'p_sale_id': saleId});
  }

  Future<SaleModel> _fetchSale(String saleId) async {
    final rows = await client
        .from('sales')
        .select(_saleSelect)
        .eq('id', saleId);

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
