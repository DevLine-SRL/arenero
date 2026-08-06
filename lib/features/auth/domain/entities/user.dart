class User {
  final String id;
  final String email;
  final String? name;
  final String role;
  final bool active;
  final DateTime? lastSeenAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    required this.active,
    this.lastSeenAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  bool get isActive => active;

  String get displayName {
    final normalizedName = name?.trim();

    if (normalizedName != null && normalizedName.isNotEmpty) {
      return normalizedName;
    }

    return email;
  }
}