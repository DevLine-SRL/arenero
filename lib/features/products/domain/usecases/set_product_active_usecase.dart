import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/products_repository.dart';

class SetProductActiveUseCase {
  final ProductsRepository repository;

  const SetProductActiveUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String id,
    required bool active,
  }) {
    return repository.setActive(id, active);
  }
}
