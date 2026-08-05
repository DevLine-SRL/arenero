class Client {
  final String id;
  final String name;
  final String? phone;
  final String ci;
  final String? nit;
  final bool active;

  const Client({
    required this.id,
    required this.name,
    this.phone,
    required this.ci,
    this.nit,
    required this.active,
  });

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    String? ci,
    String? nit,
    bool? active,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      ci: ci ?? this.ci,
      nit: nit ?? this.nit,
      active: active ?? this.active,
    );
  }
}
