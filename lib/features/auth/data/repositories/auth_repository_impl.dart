import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../../domain/entities/login_lock_status.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

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

      return Right(user);
    } on supabase.AuthRetryableFetchException {
      return const Left(NetworkFailure());
    } on supabase.AuthException catch (exception) {
      return Left(_mapLoginAuthException(exception));
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al iniciar sesión. Inténtalo de nuevo.',
        ),
      );
    }
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  Stream<User?> watchAuthState() {
    return remoteDataSource.watchAuthState();
  }

  @override
  Future<User?> currentUser() {
    return remoteDataSource.currentUser();
  }

  @override
  Future<Either<Failure, DateTime?>> touchLastSeen() async {
    try {
      final lastSeenAt = await remoteDataSource.touchLastSeen();

      return Right(lastSeenAt);
    } on supabase.AuthRetryableFetchException {
      return const Left(NetworkFailure());
    } on supabase.PostgrestException catch (exception) {
      return Left(
        _mapPostgrestException(
          exception,
          'Error inesperado al registrar actividad.',
        ),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al registrar actividad.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, LoginLockStatus>> getLoginLock({
    required Email email,
  }) async {
    return _rpcLock(
      () => remoteDataSource.getLoginLock(
        email: email.value,
      ),
    );
  }

  @override
  Future<Either<Failure, LoginLockStatus>> registerFailedLogin({
    required Email email,
  }) async {
    return _rpcLock(
      () => remoteDataSource.registerFailedLogin(
        email: email.value,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> resetLoginAttempts({
    required Email email,
  }) async {
    try {
      await remoteDataSource.resetLoginAttempts(
        email: email.value,
      );

      return const Right(unit);
    } on supabase.AuthRetryableFetchException {
      return const Left(NetworkFailure());
    } on supabase.PostgrestException catch (exception) {
      return Left(
        _mapPostgrestException(
          exception,
          'Error inesperado al registrar intentos.',
        ),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al registrar intentos.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> requestPasswordReset({
    required Email email,
    String? redirectTo,
  }) async {
    try {
      await remoteDataSource.requestPasswordReset(
        email: email.value,
        redirectTo: redirectTo,
      );

      return const Right(unit);
    } on supabase.AuthRetryableFetchException {
      return const Left(NetworkFailure());
    } on supabase.AuthException catch (exception) {
      return Left(_mapPasswordResetAuthException(exception));
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          message:
              'No fue posible procesar la solicitud. Inténtalo nuevamente.',
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
    } on supabase.AuthRetryableFetchException {
      return const Left(NetworkFailure());
    } on supabase.PostgrestException catch (exception) {
      return Left(
        _mapPostgrestException(
          exception,
          'Error inesperado al consultar el bloqueo.',
        ),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al consultar el bloqueo.',
        ),
      );
    }
  }

  Failure _mapLoginAuthException(
    supabase.AuthException exception,
  ) {
    return switch (exception.statusCode) {
      '400' => const InvalidCredentialsFailure(),
      '422' => const ValidationFailure(),
      '429' => const UnexpectedFailure(
        message:
            'Se realizaron demasiados intentos. Espera un momento e inténtalo nuevamente.',
        code: '429',
      ),
      _ => const InvalidCredentialsFailure(),
    };
  }

  Failure _mapPasswordResetAuthException(
    supabase.AuthException exception,
  ) {
    return switch (exception.statusCode) {
      '400' || '422' => const ValidationFailure(
        message: 'Ingrese un correo electrónico válido.',
      ),
      '429' => const UnexpectedFailure(
        message:
            'Se realizaron demasiadas solicitudes. Espera un momento e inténtalo nuevamente.',
        code: '429',
      ),
      _ => UnexpectedFailure(
        message:
            'No fue posible procesar la solicitud. Inténtalo nuevamente.',
        code: exception.statusCode,
      ),
    };
  }

  Failure _mapPostgrestException(
    supabase.PostgrestException exception,
    String fallback,
  ) {
    return switch (exception.code) {
      '42501' => const UnauthorizedFailure(
        message: 'No tienes permisos para realizar esta acción.',
        code: '42501',
      ),
      'PGRST116' => const NotFoundFailure(
        message: 'El recurso solicitado no existe.',
        code: 'PGRST116',
      ),
      _ => UnexpectedFailure(
        message: fallback,
        code: exception.code,
      ),
    };
  }
}