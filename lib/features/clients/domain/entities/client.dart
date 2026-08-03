class Client {
  final String id;
  final String name;
  final String? phone;
  final String ci;
  final bool active;

  const Client({
    required this.id,
    required this.name,
    this.phone,
    required this.ci,
    required this.active,
  });

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    String? ci,
    bool? active,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      ci: ci ?? this.ci,
      active: active ?? this.active,
    );
  }
}
