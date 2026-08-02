import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/seller_model.dart';

abstract class SellersRemoteDataSource {
  Future<List<SellerModel>> getSellers();

  Future<void> setActive(String id, bool active);

  Future<void> createSeller({
    required String name,
    required String email,
    required String password,
  });
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

  @override
  Future<void> createSeller({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.functions.invoke(
        'create-seller',
        body: {'name': name, 'email': email, 'password': password},
      );

      if (response.status < 200 || response.status >= 300) {
        throw CreateSellerRemoteException(
          code: _extractErrorCode(response.data),
          status: response.status,
        );
      }
    } on supabase.FunctionException catch (e) {
      throw CreateSellerRemoteException(
        code: _extractErrorCode(e.details),
        status: e.status,
      );
    }
  }

  String? _extractErrorCode(Object? details) {
    Map? map;
    if (details is Map) {
      map = details;
    } else if (details is String) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map) map = decoded;
      } on FormatException {
        return null;
      }
    }

    final errorMap = map?['error'];
    if (errorMap is Map) {
      final code = errorMap['code'];
      if (code != null) return code.toString();
    }
    return null;
  }
}

class CreateSellerRemoteException implements Exception {
  final String? code;
  final int? status;

  const CreateSellerRemoteException({this.code, this.status});

  @override
  String toString() => 'CreateSellerRemoteException($status): $code';
}
