import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
  Stream<UserModel?> watchAuthState();
  UserModel? get currentUser;
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

    return UserModel.fromSupabase(user);
  }

  @override
  Future<void> logout() async {
    await client.auth.signOut();
  }

  @override
  Stream<UserModel?> watchAuthState() {
    return client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? UserModel.fromSupabase(user) : null;
    });
  }

  @override
  UserModel? get currentUser {
    final user = client.auth.currentUser;
    return user != null ? UserModel.fromSupabase(user) : null;
  }
}
