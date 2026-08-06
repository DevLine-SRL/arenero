import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/auth/domain/entities/login_lock_status.dart';
import 'package:arenero/features/auth/domain/entities/user.dart';
import 'package:arenero/features/auth/domain/repositories/auth_repository.dart';
import 'package:arenero/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:arenero/features/auth/presentation/providers/auth_providers.dart';
import 'package:arenero/features/auth/presentation/providers/password_recovery_provider.dart';
import 'package:arenero/shared/value_objects/email.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> login({
    required Email email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Stream<User?> watchAuthState() {
    throw UnimplementedError();
  }

  @override
  Future<User?> currentUser() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DateTime?>> touchLastSeen() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LoginLockStatus>> getLoginLock({
    required Email email,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LoginLockStatus>> registerFailedLogin({
    required Email email,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> resetLoginAttempts({required Email email}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> requestPasswordReset({
    required Email email,
    String? redirectTo,
  }) {
    throw UnimplementedError();
  }
}

class _FakeRequestPasswordResetUseCase extends RequestPasswordResetUseCase {
  final Either<Failure, Unit> result;

  _FakeRequestPasswordResetUseCase(this.result) : super(_FakeAuthRepository());

  @override
  Future<Either<Failure, Unit>> call({
    required String rawEmail,
    String? redirectTo,
  }) async {
    return result;
  }
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        requestPasswordResetUseCaseProvider.overrideWithValue(
          _FakeRequestPasswordResetUseCase(const Right(unit)),
        ),
      ],
    );
    container.listen(passwordRecoveryProvider, (_, __) {});
    addTearDown(container.dispose);
  });

  PasswordRecovery notifier() =>
      container.read(passwordRecoveryProvider.notifier);

  group('password recovery provider', () {
    test('shows a validation error for an invalid email', () {
      notifier().onEmailChanged('invalid-email');

      final state = container.read(passwordRecoveryProvider);

      expect(state.emailError, isNotNull);
      expect(state.isSuccess, isFalse);
    });

    test(
      'marks the submission as successful when the reset request succeeds',
      () async {
        notifier()
          ..onEmailChanged('user@example.com')
          ..submit();

        await Future<void>.delayed(Duration.zero);

        final state = container.read(passwordRecoveryProvider);

        expect(state.isSubmitting, isFalse);
        expect(state.isSuccess, isTrue);
        expect(state.message, contains('enlace de recuperación'));
      },
    );
  });
}
