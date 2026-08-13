import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../../domain/entities/seller.dart';

abstract class SellersRepository {
  Future<Either<Failure, List<Seller>>> getSellers();

  Future<Either<Failure, List<Seller>>> getCachedSellers();

  Future<Either<Failure, Unit>> setActive(String id, bool active);

  Future<Either<Failure, Unit>> createSeller({
    required FullName name,
    required Email email,
    required Password password,
  });
}
