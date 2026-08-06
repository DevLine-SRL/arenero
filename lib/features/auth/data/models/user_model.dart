import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    required super.role,
    required super.active,
    super.lastSeenAt,
  });

  factory UserModel.fromProfile(
    supabase.User supabaseUser,
    Map<String, dynamic> profile,
  ) {
    final lastSeenAt = profile['last_seen_at'];

    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: _readName(supabaseUser.userMetadata),
      role: profile['role'] as String? ?? 'user',
      active: profile['active'] as bool? ?? false,
      lastSeenAt: _parseDateTime(lastSeenAt),
    );
  }

  static String? _readName(Map<String, dynamic>? metadata) {
    final value = metadata?['name'];

    if (value is! String) {
      return null;
    }

    final normalizedName = value.trim();

    return normalizedName.isEmpty ? null : normalizedName;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}