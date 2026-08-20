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
      name:
          profile['name'] as String? ??
          supabaseUser.userMetadata?['name'] as String?,
      role: profile['role'] as String,
      active: profile['active'] as bool,
      lastSeenAt: lastSeenAt is String ? DateTime.tryParse(lastSeenAt) : null,
    );
  }
}
