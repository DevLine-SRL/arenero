import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
  Stream<UserModel?> watchAuthState();
  Future<UserModel?> currentUser();
  Future<DateTime?> touchLastSeen();
  Future<Map<String, dynamic>> getLoginLock();
  Future<Map<String, dynamic>> registerFailedLogin();
  Future<void> resetLoginAttempts();
  Future<void> sendPasswordResetCode({required String email});
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });
  Future<void> changePassword({required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient client;

  const AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const supabase.AuthException('Login falló sin usuario retornado');
    }

    final profile = await _fetchProfile(user.id);
    if (profile == null) {
      await client.auth.signOut();
      throw const AccountDisabledRemoteException();
    }

    await client.rpc('touch_last_seen');
    final freshProfile = await _fetchProfile(user.id);

    return UserModel.fromProfile(user, freshProfile ?? profile);
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

  @override
  Future<DateTime?> touchLastSeen() async {
    final result = await client.rpc('touch_last_seen');
    if (result is! String) return null;
    return DateTime.tryParse(result);
  }

  @override
  Future<Map<String, dynamic>> getLoginLock() async {
    final result = await client.rpc('get_login_lock');
    return _asLockMap(result);
  }

  @override
  Future<Map<String, dynamic>> registerFailedLogin() async {
    final result = await client.rpc('register_failed_login');
    return _asLockMap(result);
  }

  @override
  Future<void> resetLoginAttempts() async {
    await client.rpc('reset_login_attempts');
  }

  Map<String, dynamic> _asLockMap(dynamic result) {
    if (result is Map) return Map<String, dynamic>.from(result);
    return const {
      'locked': false,
      'remaining_seconds': 0,
      'attempts_left': 5,
      'max_attempts': 5,
      'lock_minutes': 15,
    };
  }

  @override
  Future<void> sendPasswordResetCode({required String email}) async {
    await client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await client.auth.verifyOTP(
      email: email,
      token: code,
      type: supabase.OtpType.recovery,
    );
  }

  @override
  Future<void> changePassword({required String password}) async {
    await client.auth.updateUser(supabase.UserAttributes(password: password));
  }

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    return client
        .from('profiles')
        .select('role, active, last_seen_at')
        .eq('id', userId)
        .maybeSingle();
  }
}

class AccountDisabledRemoteException implements Exception {
  const AccountDisabledRemoteException();

  @override
  String toString() => 'AccountDisabledRemoteException';
}
