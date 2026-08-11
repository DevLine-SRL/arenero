import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/validators/validators.dart';
import '../../../../shared/value_objects/email.dart';
import '../../domain/entities/login_lock_status.dart';
import 'auth_providers.dart';
import 'login_form_state.dart';

part 'login_form_provider.g.dart';

@riverpod
class LoginForm extends _$LoginForm {
  Timer? _unlockTimer;

  @override
  LoginFormState build() {
    ref.onDispose(() => _unlockTimer?.cancel());
    return const LoginFormState();
  }

  void onEmailChanged(String value) {
    final result = Email.create(value);

    state = state.copyWith(
      email: value,
      emailError: result.fold((failure) => failure.message, (_) => null),
      submitError: null,
    );
  }

  void onPasswordChanged(String value) {
    final error = required(value);

    state = state.copyWith(
      password: value,
      passwordError: error,
      submitError: null,
    );
  }

  Future<void> submit() async {
    if (!state.isValid || state.isSubmitting || state.isLocked) return;

    state = state.copyWith(isSubmitting: true, submitError: null);

    final lockCheck = await ref.read(checkLoginLockUseCaseProvider)();
    final locked = lockCheck.getOrElse(
      () => const LoginLockStatus(
        locked: false,
        remaining: Duration.zero,
        attemptsLeft: 0,
        maxAttempts: 5,
        lockMinutes: 15,
      ),
    );

    if (locked.locked) {
      _applyLock(locked);
      return;
    }

    final result = await ref.read(loginUseCaseProvider)(
      rawEmail: state.email,
      rawPassword: state.password,
    );

    await result.fold(
      (failure) async {
        if (failure is InvalidCredentialsFailure) {
          final lockResult = await ref.read(
            registerFailedLoginUseCaseProvider,
          )();

          lockResult.fold(
            (_) => state = state.copyWith(
              isSubmitting: false,
              submitError: failure.message,
            ),
            (status) {
              if (status.locked) {
                _applyLock(status);
              } else {
                state = state.copyWith(
                  isSubmitting: false,
                  isLocked: false,
                  lockRemaining: null,
                  attemptsLeft: status.attemptsLeft,
                  maxAttempts: status.maxAttempts,
                  submitError: _attemptsMessage(),
                );
              }
            },
          );
        } else {
          state = state.copyWith(
            isSubmitting: false,
            submitError: failure.message,
          );
        }
      },
      (_) async {
        await ref.read(resetLoginAttemptsUseCaseProvider)();
        state = state.copyWith(
          isSubmitting: false,
          isLocked: false,
          lockRemaining: null,
          attemptsLeft: null,
          maxAttempts: null,
          submitError: null,
        );
      },
    );
  }

  void _applyLock(LoginLockStatus locked) {
    state = state.copyWith(
      isSubmitting: false,
      isLocked: true,
      lockRemaining: locked.remaining,
      attemptsLeft: locked.attemptsLeft,
      maxAttempts: locked.maxAttempts,
      submitError: _lockMessage(locked),
    );

    _scheduleUnlock(locked.remaining);
  }

  void _scheduleUnlock(Duration remaining) {
    _unlockTimer?.cancel();
    final waiting = remaining > Duration.zero ? remaining : Duration.zero;
    _unlockTimer = Timer(waiting, _recheckLock);
  }

  Future<void> _recheckLock() async {
    if (!ref.mounted) return;

    final lockCheck = await ref.read(checkLoginLockUseCaseProvider)();
    final status = lockCheck.getOrElse(
      () => const LoginLockStatus(
        locked: false,
        remaining: Duration.zero,
        attemptsLeft: 0,
        maxAttempts: 5,
        lockMinutes: 15,
      ),
    );

    if (status.locked) {
      _applyLock(status);
      return;
    }

    state = state.copyWith(
      isLocked: false,
      lockRemaining: null,
      attemptsLeft: null,
      maxAttempts: null,
      submitError: null,
    );
  }

  String _lockMessage(LoginLockStatus status) {
    final minutes = status.remaining.inMinutes;
    final label = minutes >= 1 ? '$minutes minuto(s)' : 'unos segundos';
    return 'Demasiados intentos fallidos. '
        'Inténtalo de nuevo en $label.';
  }

  String _attemptsMessage() {
    return 'Credenciales inválidas.';
  }
}
