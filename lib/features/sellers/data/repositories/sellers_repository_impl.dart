import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_errors.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../../domain/entities/seller.dart';
import '../../domain/repositories/sellers_repository.dart';
import '../datasources/sellers_local_datasource.dart';
import '../datasources/sellers_remote_datasource.dart';

class SellersRepositoryImpl implements SellersRepository {
  final SellersRemoteDataSource remoteDataSource;
  final SellersLocalDataSource localDataSource;
  final bool Function() isOnline;

  const SellersRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource, {
    required this.isOnline,
  });

  @override
  Future<Either<Failure, List<Seller>>> getSellers() async {
    if (!isOnline()) {
      return _cachedSellers();
    }
    try {
      final sellers = await remoteDataSource.getSellers();
      await _syncLocal(() => localDataSource.replaceSellers(sellers));
      return Right(sellers);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'No se pudieron obtener los vendedores.'),
      );
    } catch (e) {
      if (isNetworkError(e)) {
        return _cachedSellers();
      }
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al obtener los vendedores.',
        ),
      );
    }
  }

  Future<Either<Failure, List<Seller>>> _cachedSellers() async {
    try {
      final cached = await localDataSource.getCachedSellers();
      if (cached.isEmpty) {
        return const Left(NetworkFailure());
      }
      return Right(cached);
    } catch (_) {
      return const Left(
        CacheFailure(message: 'No se pudo leer la caché de vendedores.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> createSeller({
    required FullName name,
    required Email email,
    required Password password,
  }) async {
    if (!isOnline()) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.createSeller(
        name: name.value,
        email: email.value,
        password: password.value,
      );
      return const Right(unit);
    } on CreateSellerRemoteException catch (e) {
      return Left(_mapCreateSellerError(e));
    } catch (_) {
      return const Left(
        UnexpectedFailure(message: 'No se pudo crear el vendedor.'),
      );
    }
  }

  Failure _mapCreateSellerError(CreateSellerRemoteException e) {
    final message = switch (e.code) {
      'UNAUTHORIZED' => 'Tu sesión expiró, inicia sesión de nuevo.',
      'FORBIDDEN' => 'No tienes permisos de administrador.',
      'INVALID_EMAIL' => 'El correo electrónico no es válido.',
      'WEAK_PASSWORD' =>
        'La contraseña debe tener al menos 8 caracteres, incluir mayúscula, minúscula y un carácter especial.',
      'NAME_REQUIRED' => 'El nombre es obligatorio.',
      'INVALID_NAME' =>
        'El nombre solo puede contener letras, espacios y guiones.',
      'EMAIL_TAKEN' => 'Ya existe una cuenta con ese correo electrónico.',
      'INVALID_REQUEST' => 'Datos inválidos.',
      _ => 'No se pudo crear el vendedor.',
    };
    return UnexpectedFailure(message: message, code: e.code);
  }

  @override
  Future<Either<Failure, Unit>> setActive(String id, bool active) async {
    if (!isOnline()) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.setActive(id, active);
      await _syncLocal(() => localDataSource.setActive(id, active));
      return const Right(unit);
    } on supabase.PostgrestException {
      return const Left(
        UnexpectedFailure(
          message: 'No se pudo actualizar el estado del vendedor.',
        ),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al actualizar el estado del vendedor.',
        ),
      );
    }
  }

  Future<void> _syncLocal(Future<void> Function() write) async {
    try {
      await write();
    } catch (_) {}
  }

  Failure _mapPostgrestException(
    supabase.PostgrestException e,
    String fallbackMessage,
  ) {
    return switch (e.code) {
      '42501' => const UnauthorizedFailure(
        message: 'No tienes permisos para realizar esta acción.',
        code: '42501',
      ),
      _ => UnexpectedFailure(message: fallbackMessage, code: e.code),
    };
  }
}
