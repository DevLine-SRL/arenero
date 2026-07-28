import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/email.dart';
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
    } on supabase.AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<void> logout() => remoteDataSource.logout();

  @override
  Stream<User?> watchAuthState() => remoteDataSource.watchAuthState();

  @override
  User? get currentUser => remoteDataSource.currentUser;

  Failure _mapAuthException(supabase.AuthException e) {
    return switch (e.statusCode) {
      '400' => InvalidCredentialsFailure(),
      '422' => ValidationFailure(),
      _ => InvalidCredentialsFailure(),
    };
  }
}
