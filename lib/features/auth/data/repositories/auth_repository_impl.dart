import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
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
