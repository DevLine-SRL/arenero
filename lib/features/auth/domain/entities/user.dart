class User {
  final String id;
  final String email;
  final String? name;
  final String role;
  final bool active;

  const User({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    required this.active,
  });
}
