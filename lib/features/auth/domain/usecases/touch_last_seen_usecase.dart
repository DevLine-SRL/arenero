import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class TouchLastSeenUseCase {
  final AuthRepository repository;

  const TouchLastSeenUseCase(this.repository);

  Future<Either<Failure, DateTime?>> call() {
    return repository.touchLastSeen();
  }
}