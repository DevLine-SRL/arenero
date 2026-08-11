import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'forgot_password_form_widget.dart';
import 'back_to_login_button.dart';
import '../providers/forgot_password_form_provider.dart';

class ForgotPasswordEmailStep extends ConsumerWidget {
  const ForgotPasswordEmailStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        const Text(
          'Ingresa tu correo electrónico para restablecer tu contraseña.',
        ),
        const ForgotPasswordFormWidget(),
        if (state.submitEmailError != null)
          Text(
            state.submitEmailError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        FilledButton(
          onPressed: state.isEmailValid && !state.isLoadingEmail
              ? () =>
                    ref.read(forgotPasswordFormProvider.notifier).submitEmail()
              : null,
          child: state.isLoadingEmail
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Enviar enlace'),
        ),
        const BackToLoginButton(),
      ],
    );
  }
}
