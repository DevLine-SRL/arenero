import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository repository;

  const WatchAuthStateUseCase(this.repository);

  Stream<User?> call() {
    return repository.watchAuthState();
  }
}
