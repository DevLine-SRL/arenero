import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../../../../shared/value_objects/password.dart';
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
  Stream<User?> watchAuthState() => remoteDataSource.watchAuthState();

  @override
  Future<User?> currentUser() => remoteDataSource.currentUser();

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
  Future<Either<Failure, LoginLockStatus>> getLoginLock({
    required Email email,
  }) async {
    return _rpcLock(() => remoteDataSource.getLoginLock(email: email.value));
  }

  @override
  Future<Either<Failure, LoginLockStatus>> registerFailedLogin({
    required Email email,
  }) async {
    return _rpcLock(
      () => remoteDataSource.registerFailedLogin(email: email.value),
    );
  }

  @override
  Future<Either<Failure, Unit>> resetLoginAttempts({
    required Email email,
  }) async {
    try {
      await remoteDataSource.resetLoginAttempts(email: email.value);
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
