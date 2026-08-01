import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/seller.dart';

abstract class SellersRepository {
  Future<Either<Failure, List<Seller>>> getSellers();

  Future<Either<Failure, Unit>> setActive(String id, bool active);
}
