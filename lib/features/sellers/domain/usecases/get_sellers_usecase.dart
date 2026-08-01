import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/seller.dart';
import '../repositories/sellers_repository.dart';

class GetSellersUseCase {
  final SellersRepository repository;

  const GetSellersUseCase(this.repository);

  Future<Either<Failure, List<Seller>>> call() {
    return repository.getSellers();
  }
}
