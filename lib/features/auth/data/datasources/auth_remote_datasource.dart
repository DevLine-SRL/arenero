import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
  Stream<UserModel?> watchAuthState();
  Future<UserModel?> currentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient client;

  const AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const supabase.AuthException('Login falló sin usuario retornado');
    }

    final profile = await _fetchProfile(user.id);
    if (profile == null || profile['active'] == false) {
      await client.auth.signOut();
      throw const supabase.AuthException('Credenciales inválidas.');
    }
    return UserModel.fromProfile(user, profile);
  }

  @override
  Future<void> logout() async {
    await client.auth.signOut();
  }

  @override
  Stream<UserModel?> watchAuthState() {
    return client.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;

      final profile = await _fetchProfile(user.id);
      if (profile == null || profile['active'] == false) {
        await client.auth.signOut();
        return null;
      }
      return UserModel.fromProfile(user, profile);
    });
  }

  @override
  Future<UserModel?> currentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final profile = await _fetchProfile(user.id);
    if (profile == null || profile['active'] == false) return null;
    return UserModel.fromProfile(user, profile);
  }

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    return client.from('profiles').select('role, active').eq('id', userId).maybeSingle();
  }
}
