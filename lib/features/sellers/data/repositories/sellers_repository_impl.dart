import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
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
}
