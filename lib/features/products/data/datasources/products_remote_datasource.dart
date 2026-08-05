import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/product.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();

  Future<void> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  });

  Future<void> setActive(String id, bool active);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final supabase.SupabaseClient client;

  const ProductsRemoteDataSourceImpl(this.client);

  @override
  Future<List<ProductModel>> getProducts() async {
    final rows = await client
        .from('products')
        .select(
          'id, name, active, product_units(id, product_id, unit, unit_price, active)',
        )
        .order('name');

    return [for (final row in rows) ProductModel.fromJson(row)];
  }

  @override
  Future<void> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  }) async {
    final product = await client
        .from('products')
        .insert({'name': name, 'active': true})
        .select('id')
        .single();

    await client.from('product_units').insert({
      'product_id': product['id'],
      'unit': unit.databaseValue,
      'unit_price': unitPrice,
      'active': true,
    });
  }

  @override
  Future<void> setActive(String id, bool active) async {
    await client.from('products').update({'active': active}).eq('id', id);
  }
}
