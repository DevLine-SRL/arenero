import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/sellers_repository.dart';

class SetSellersActiveUseCase {
  final SellersRepository repository;

  const SetSellersActiveUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String id,
    required bool active,
  }) {
    return repository.setActive(id, active);
  }
}
