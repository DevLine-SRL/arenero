import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/sale.dart';
import '../models/sale_detail_model.dart';
import '../models/sale_delivery_model.dart';
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
    final total = details.fold<double>(
      0,
      (sum, detail) => sum + detail.subtotal,
    );

    final row = await client
        .from('sales')
        .insert({
          'client_id': clientId,
          'seller_id': sellerId,
          'sale_date': DateTime.now().toIso8601String(),
          'delivery_mode': deliveryMode.dbValue,
          'payment_method': paymentMethod.dbValue,
          'total': total,
          'notes': notes,
        })
        .select('id')
        .single();

    final saleId = row['id'] as String;

    if (details.isNotEmpty) {
      await client.from('sale_details').insert([
        for (final detail in details) {'sale_id': saleId, ...detail.toJson()},
      ]);
    }

    if (delivery != null) {
      await client.from('sale_deliveries').insert({
        'sale_id': saleId,
        ...delivery.toJson(),
      });
    }

    return _fetchSale(saleId);
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
