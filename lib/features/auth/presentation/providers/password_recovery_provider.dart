import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/value_objects/email.dart';
import 'auth_providers.dart';
import 'password_recovery_state.dart';

part 'password_recovery_provider.g.dart';

const validEmailMessage = 'Ingrese un correo electrónico válido.';

const passwordRecoverySuccessMessage =
    'Si el correo está registrado, se ha enviado un enlace de recuperación '
    'a tu dirección de correo electrónico.';

const passwordRecoveryFailureMessage =
    'No fue posible procesar la solicitud. Si el correo es válido, '
    'recibirás instrucciones para recuperar tu contraseña.';

@riverpod
class PasswordRecovery extends _$PasswordRecovery {
  @override
  PasswordRecoveryState build() {
    return const PasswordRecoveryState();
  }

  void onEmailChanged(String value) {
    final normalizedEmail = value.trim();
    final validationResult = Email.create(normalizedEmail);

    state = state.copyWith(
      email: value,
      emailError: normalizedEmail.isEmpty
          ? null
          : validationResult.fold(
              (_) => validEmailMessage,
              (_) => null,
            ),
      isSuccess: false,
      message: null,
    );
  }

  Future<void> submit({
    String? redirectTo,
  }) async {
    if (state.isSubmitting) {
      return;
    }

    final normalizedEmail = state.email.trim().toLowerCase();
    final emailResult = Email.create(normalizedEmail);

    final validEmail = emailResult.fold(
      (_) => false,
      (_) => true,
    );

    if (!validEmail) {
      state = state.copyWith(
        emailError: validEmailMessage,
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

    final result = await ref.read(
      requestPasswordResetUseCaseProvider,
    )(
      rawEmail: normalizedEmail,
      redirectTo: redirectTo,
    );

    result.fold(
      (_) {
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          message: passwordRecoveryFailureMessage,
        );
      },
      (_) {
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          message: passwordRecoverySuccessMessage,
        );
      },
    );
  }

  void reset() {
    state = const PasswordRecoveryState();
  }
}