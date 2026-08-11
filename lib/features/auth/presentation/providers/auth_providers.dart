import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/supabase_client_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/check_login_lock_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_failed_login_usecase.dart';
import '../../domain/usecases/reset_login_attempts_usecase.dart';
import '../../domain/usecases/send_forgot_password_code_usecase.dart';
import '../../domain/usecases/touch_last_seen_usecase.dart';
import '../../domain/usecases/verify_forgot_password_code_usecase.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
}

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
WatchAuthStateUseCase watchAuthStateUseCase(Ref ref) {
  return WatchAuthStateUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
TouchLastSeenUseCase touchLastSeenUseCase(Ref ref) {
  return TouchLastSeenUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
CheckLoginLockUseCase checkLoginLockUseCase(Ref ref) {
  return CheckLoginLockUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
RegisterFailedLoginUseCase registerFailedLoginUseCase(Ref ref) {
  return RegisterFailedLoginUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
ResetLoginAttemptsUseCase resetLoginAttemptsUseCase(Ref ref) {
  return ResetLoginAttemptsUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SendForgotPasswordCodeUseCase sendForgotPasswordCodeUseCase(Ref ref) {
  return SendForgotPasswordCodeUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
VerifyForgotPasswordCodeUseCase verifyForgotPasswordCodeUseCase(Ref ref) {
  return VerifyForgotPasswordCodeUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
ChangePasswordUseCase changePasswordUseCase(Ref ref) {
  return ChangePasswordUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
Stream<User?> authSession(Ref ref) {
  final useCase = ref.watch(watchAuthStateUseCaseProvider);
  return useCase();
}
