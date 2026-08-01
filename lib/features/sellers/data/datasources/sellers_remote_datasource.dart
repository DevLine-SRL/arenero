import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/seller_model.dart';

abstract class SellersRemoteDataSource {
  Future<List<SellerModel>> getSellers();

  Future<void> setActive(String id, bool active);
}

class SellersRemoteDataSourceImpl implements SellersRemoteDataSource {
  final supabase.SupabaseClient client;

  const SellersRemoteDataSourceImpl(this.client);

  @override
  Future<List<SellerModel>> getSellers() async {
    final rows = await client
      .from('profiles')
      .select()
      .eq('role', 'seller')
      .order('created_at');

    return [for (final row in rows) SellerModel.fromJson(row)];
  }

  @override
  Future<void> setActive(String id, bool active) async {
    await client.from('profiles').update({'active': active}).eq('id', id);
  }
}
