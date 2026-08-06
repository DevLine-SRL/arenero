import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/value_objects/email.dart';
import 'auth_providers.dart';
import 'password_recovery_state.dart';

part 'password_recovery_provider.g.dart';

const String _validEmailMessage = 'Ingrese un correo electrónico válido.';

const String _passwordRecoverySuccessMessage =
    'Si el correo está registrado, se ha enviado un enlace de recuperación '
    'a tu dirección de correo electrónico.';

const String _passwordRecoveryFailureMessage =
    'No fue posible procesar la solicitud. Si el correo es válido, '
    'recibirás instrucciones para recuperar tu contraseña.';

@riverpod
class PasswordRecovery extends _$PasswordRecovery {
  @override
  PasswordRecoveryState build() {
    return const PasswordRecoveryState();
  }

  void onEmailChanged(String value) {
    final normalizedEmail = _normalizeEmail(value);
    final emailError = normalizedEmail.isEmpty
        ? null
        : _validateEmail(normalizedEmail);

    state = state.copyWith(
      email: value,
      emailError: emailError,
      isSubmitting: false,
      isSuccess: false,
      message: null,
    );
  }

  Future<void> submit({String? redirectTo}) async {
    if (state.isSubmitting) {
      return;
    }

    final normalizedEmail = _normalizeEmail(state.email);
    final emailError = _validateEmail(normalizedEmail);

    if (emailError != null) {
      state = state.copyWith(
        email: normalizedEmail,
        emailError: emailError,
        isSubmitting: false,
        isSuccess: false,
        message: null,
      );

      return;
    }

    state = state.copyWith(
      email: normalizedEmail,
      emailError: null,
      isSubmitting: true,
      isSuccess: false,
      message: null,
    );

    try {
      final result = await ref
          .read(requestPasswordResetUseCaseProvider)
          .call(
            rawEmail: normalizedEmail,
            redirectTo: _normalizeRedirectTo(redirectTo),
          );

      result.fold(
        (_) {
          state = state.copyWith(
            isSubmitting: false,
            isSuccess: false,
            message: _passwordRecoveryFailureMessage,
          );
        },
        (_) {
          state = state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            message: _passwordRecoverySuccessMessage,
          );
        },
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        message: _passwordRecoveryFailureMessage,
      );
    }
  }

  void clearMessage() {
    state = state.copyWith(isSuccess: false, message: null);
  }

  void reset() {
    state = const PasswordRecoveryState();
  }

  String _normalizeEmail(String value) {
    return value.trim().toLowerCase();
  }

  String? _normalizeRedirectTo(String? value) {
    if (value == null) {
      return null;
    }

    final String normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }

  String? _validateEmail(String value) {
    final String normalizedEmail = _normalizeEmail(value);

    if (normalizedEmail.isEmpty) {
      return _validEmailMessage;
    }

    final result = Email.create(normalizedEmail);

    return result.fold((_) => _validEmailMessage, (_) => null);
  }
}
