import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../../../../shared/value_objects/password.dart';
import '../../domain/entities/login_lock_status.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final bool Function() isOnline;

  const AuthRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource, {
    required this.isOnline,
  });

  @override
  Future<Either<Failure, User>> login({
    required Email email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email.value,
        password: password,
      );
      await _persistProfile(user);
      return Right(user);
    } on supabase.AuthRetryableFetchException {
      return const Left(NetworkFailure());
    } on AccountDisabledRemoteException {
      return const Left(AccountDisabledFailure());
    } on supabase.AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al iniciar sesión. Inténtalo de nuevo.',
        ),
      );
    }
  }

  @override
  Future<void> logout() => remoteDataSource.logout();

  @override
  Stream<User?> watchAuthState() async* {
    try {
      final stream = remoteDataSource.watchAuthState();
      await for (final user in stream) {
        yield user;
        if (user != null) {
          unawaited(_persistProfile(user));
        }
      }
    } on ProfileUnavailableException catch (e) {
      final cached = await _cachedProfile(e.userId);
      yield cached;
    } catch (_) {
      // Un error inesperado del stream remoto no debe derribar la sesión.
    }
  }

  @override
  Future<User?> currentUser() async {
    if (!isOnline()) {
      return _cachedProfileForActiveSession();
    }
    try {
      return await remoteDataSource.currentUser();
    } on ProfileUnavailableException catch (e) {
      return _cachedProfile(e.userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, DateTime?>> touchLastSeen() async {
    try {
      final lastSeenAt = await remoteDataSource.touchLastSeen();
      return Right(lastSeenAt);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'Error inesperado al registrar actividad.'),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(message: 'Error inesperado al registrar actividad.'),
      );
    }
  }

  @override
  Future<Either<Failure, LoginLockStatus>> getLoginLock() async {
    return _rpcLock(() => remoteDataSource.getLoginLock());
  }

  @override
  Future<Either<Failure, LoginLockStatus>> registerFailedLogin() async {
    return _rpcLock(() => remoteDataSource.registerFailedLogin());
  }

  @override
  Future<Either<Failure, Unit>> resetLoginAttempts() async {
    try {
      await remoteDataSource.resetLoginAttempts();
      return const Right(unit);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'Error inesperado al registrar intentos.'),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(message: 'Error inesperado al registrar intentos.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetCode({
    required Email email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetCode(email: email.value);
      return const Right(unit);
    } on supabase.AuthRetryableFetchException {
      return const Left(NetworkFailure());
    } on supabase.AuthException {
      return const Left(
        NotFoundFailure(
          message: 'Si el correo está registrado, recibirás el código',
        ),
      );
    } catch (e) {
      return const Left(
        UnexpectedFailure(
          message: 'No pudimos enviar el código. Inténtalo de nuevo.',
        ),
      );
    }
  }

  Future<Either<Failure, LoginLockStatus>> _rpcLock(
    Future<Map<String, dynamic>> Function() call,
  ) async {
    try {
      final map = await call();
      return Right(LoginLockStatus.fromMap(map));
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'Error inesperado al consultar el bloqueo.'),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(message: 'Error inesperado al consultar el bloqueo.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetCode({
    required Email email,
    required String code,
  }) async {
    try {
      await remoteDataSource.verifyPasswordResetCode(
        email: email.value,
        code: code,
      );
      return const Right(unit);
    } on supabase.AuthRetryableFetchException {
      return const Left(NetworkFailure());
    } on supabase.AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return const Left(
        UnexpectedFailure(
          message: 'Código inválido o vencido. Inténtalo de nuevo.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required Password password,
  }) async {
    try {
      await remoteDataSource.changePassword(password: password.value);
      return const Right(unit);
    } on supabase.AuthRetryableFetchException {
      return const Left(NetworkFailure());
    } on supabase.AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return const Left(
        UnexpectedFailure(
          message: 'No se pudo cambiar la contraseña. Inténtalo de nuevo.',
        ),
      );
    }
  }

  /// Persiste el perfil en la caché local sin propagar sus errores: una caché
  /// que falla no debe invalidar una sesión ya confirmada por el remoto.
  Future<void> _persistProfile(User user) async {
    try {
      await localDataSource.upsertProfile(user);
    } catch (_) {
      // La caché se rellenará en la próxima lectura con red.
    }
  }

  Future<User?> _cachedProfileForActiveSession() async {
    final userId = remoteDataSource.activeUserId();
    if (userId == null) return null;
    return _cachedProfile(userId);
  }

  Future<User?> _cachedProfile(String userId) async {
    try {
      return await localDataSource.getProfile(userId);
    } catch (_) {
      return null;
    }
  }

  Failure _mapAuthException(supabase.AuthException e) {
    return switch (e.statusCode) {
      '400' => InvalidCredentialsFailure(),
      '422' => ValidationFailure(),
      _ => InvalidCredentialsFailure(),
    };
  }

  Failure _mapPostgrestException(
    supabase.PostgrestException e,
    String fallback,
  ) {
    return switch (e.code) {
      '42501' => const UnauthorizedFailure(
        message: 'No tienes permisos para realizar esta acción.',
        code: '42501',
      ),
      'PGRST116' => const NotFoundFailure(
        message: 'El usuario no existe.',
        code: 'PGRST116',
      ),
      _ => UnexpectedFailure(message: fallback, code: e.code),
    };
  }
}
