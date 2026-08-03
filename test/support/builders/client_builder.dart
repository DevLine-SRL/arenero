import 'package:arenero/features/clients/domain/entities/client.dart';

/// Cliente con valores por defecto razonables. Una prueba solo declara los
/// campos que le importan.
Client buildClient({
  String id = 'client-1',
  String name = 'Juan Pérez',
  String? phone = '70011223',
  String ci = '1234567',
  bool active = true,
}) {
  return Client(id: id, name: name, phone: phone, ci: ci, active: active);
}
