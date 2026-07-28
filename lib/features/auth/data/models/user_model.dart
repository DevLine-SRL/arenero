import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
  });

  factory UserModel.fromSupabase(supabase.User supabaseUser) {
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] as String?,
    );
  }
}
