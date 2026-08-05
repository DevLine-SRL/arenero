import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/client_model.dart';

abstract class ClientsRemoteDataSource {
  Future<List<ClientModel>> searchClients({
    required String query,
    bool includeInactive = false,
  });

  Future<ClientModel> createClient({
    required String name,
    required String ci,
    String? phone,
    String? nit,
  });

  Future<bool> existsByCi(String ci);

  Future<ClientModel> updateClient({
    required String id,
    required String name,
    required String ci,
    String? phone,
    String? nit,
  });

  Future<void> setActive(String id, bool active);
}

class ClientsRemoteDataSourceImpl implements ClientsRemoteDataSource {
  final supabase.SupabaseClient client;

  const ClientsRemoteDataSourceImpl(this.client);

  @override
  Future<List<ClientModel>> searchClients({
    required String query,
    bool includeInactive = false,
  }) async {
    var filter = client.from('clients').select();

    if (!includeInactive) {
      filter = filter.eq('active', true);
    }

    final term = _sanitizeSearchTerm(query);
    if (term.isNotEmpty) {
      filter = filter.or(
        'name.ilike.%$term%,ci.ilike.%$term%,nit.ilike.%$term%',
      );
    }

    final rows = await filter.order('name');

    return [for (final row in rows) ClientModel.fromJson(row)];
  }

  @override
  Future<ClientModel> createClient({
    required String name,
    required String ci,
    String? phone,
    String? nit,
  }) async {
    final row = await client
        .from('clients')
        .insert({
          'name': name.trim(),
          'ci': ci,
          'phone': _nullIfBlank(phone),
          'nit': _nullIfBlank(nit),
        })
        .select()
        .single();

    return ClientModel.fromJson(row);
  }

  @override
  Future<bool> existsByCi(String ci) async {
    final row = await client
        .from('clients')
        .select('id')
        .eq('ci', ci)
        .maybeSingle();

    return row != null;
  }

  @override
  Future<ClientModel> updateClient({
    required String id,
    required String name,
    required String ci,
    String? phone,
    String? nit,
  }) async {
    final row = await client
        .from('clients')
        .update({
          'name': name.trim(),
          'ci': ci,
          'phone': _nullIfBlank(phone),
          'nit': _nullIfBlank(nit),
        })
        .eq('id', id)
        .select()
        .single();

    return ClientModel.fromJson(row);
  }

  @override
  Future<void> setActive(String id, bool active) async {
    await client.from('clients').update({'active': active}).eq('id', id);
  }

  /// Los comodines y los separadores de PostgREST cambiarían el significado
  /// del filtro `or`, así que se quitan del término antes de construirlo.
  String _sanitizeSearchTerm(String query) {
    return query.trim().replaceAll(RegExp(r'[,%_()*"\\]'), '');
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
