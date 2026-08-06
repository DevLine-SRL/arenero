import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository repository;

  const WatchAuthStateUseCase(this.repository);

  Stream<User?> call() {
    return repository.watchAuthState();
  }
}