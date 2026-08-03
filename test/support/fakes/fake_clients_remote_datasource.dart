import 'package:arenero/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:arenero/features/clients/data/models/client_model.dart';

/// Datasource de mentira, escrito a mano: el proyecto no usa librerías de
/// mocking. Cada método devuelve lo que la prueba le ponga en el campo
/// correspondiente, o lanza lo que le ponga en `errorToThrow`.
///
/// Los métodos que una prueba no configura no fallan en silencio: devuelven
/// valores vacíos y dejan constancia en los contadores de llamadas.
class FakeClientsRemoteDataSource implements ClientsRemoteDataSource {
  Object? errorToThrow;

  List<ClientModel> searchResult = const [];
  ClientModel? createResult;
  ClientModel? updateResult;
  bool existsResult = false;

  String? lastSearchQuery;
  bool? lastIncludeInactive;
  String? lastCreatedCi;
  String? lastCreatedName;
  String? lastCreatedPhone;
  String? lastCreatedNit;
  int setActiveCallCount = 0;

  @override
  Future<List<ClientModel>> searchClients({
    required String query,
    bool includeInactive = false,
  }) async {
    lastSearchQuery = query;
    lastIncludeInactive = includeInactive;
    _throwIfConfigured();
    return searchResult;
  }

  @override
  Future<ClientModel> createClient({
    required String name,
    required String ci,
    String? phone,
    String? nit,
  }) async {
    lastCreatedName = name;
    lastCreatedCi = ci;
    lastCreatedPhone = phone;
    lastCreatedNit = nit;
    _throwIfConfigured();
    return createResult ??
        ClientModel(
          id: 'client-1',
          name: name,
          ci: ci,
          phone: phone,
          nit: nit,
          active: true,
        );
  }

  @override
  Future<bool> existsByCi(String ci) async {
    _throwIfConfigured();
    return existsResult;
  }

  @override
  Future<ClientModel> updateClient({
    required String id,
    required String name,
    required String ci,
    String? phone,
    String? nit,
  }) async {
    _throwIfConfigured();
    return updateResult ??
        ClientModel(
          id: id,
          name: name,
          ci: ci,
          phone: phone,
          nit: nit,
          active: true,
        );
  }

  @override
  Future<void> setActive(String id, bool active) async {
    setActiveCallCount++;
    _throwIfConfigured();
  }

  void _throwIfConfigured() {
    final error = errorToThrow;
    if (error != null) throw error;
  }
}
