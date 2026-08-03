import '../../domain/entities/client.dart';

class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.name,
    super.phone,
    required super.ci,
    required super.active,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      ci: json['ci'] as String,
      active: json['active'] as bool,
    );
  }

  /// Solo las columnas que la aplicación escribe. `id`, `active`,
  /// `created_at` y `updated_at` los gobierna la base de datos.
  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone, 'ci': ci};
  }
}
