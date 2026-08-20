import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../../domain/entities/seller.dart';
import '../../domain/repositories/sellers_repository.dart';
import '../datasources/sellers_remote_datasource.dart';

class SellersRepositoryImpl implements SellersRepository {
  final SellersRemoteDataSource remoteDataSource;

  const SellersRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Seller>>> getSellers() async {
    try {
      final sellers = await remoteDataSource.getSellers();
      return Right(sellers);
    } on supabase.PostgrestException {
      return const Left(
        UnexpectedFailure(message: 'No se pudieron obtener los vendedores.'),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al obtener los vendedores.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> createSeller({
    required FullName name,
    required Email email,
    required Password password,
  }) async {
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
    try {
      await remoteDataSource.setActive(id, active);
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

  @override
  Future<Either<Failure, Unit>> updateSeller({
    required String id,
    required FullName name,
    required Email email,
  }) async {
    try {
      await remoteDataSource.updateSeller(
        id: id,
        name: name.value,
        email: email.value,
      );
      return const Right(unit);
    } on supabase.PostgrestException catch (e) {
      final message = e.message.contains('duplicate') || e.code == '23505'
          ? 'Ya existe un vendedor registrado con ese correo electrónico.'
          : 'No se pudo guardar los cambios del vendedor.';
      return Left(ValidationFailure(message: message, code: e.code));
    } catch (_) {
      return const Left(
        UnexpectedFailure(message: 'No se pudo guardar los cambios del vendedor.'),
      );
    }
  }
}
