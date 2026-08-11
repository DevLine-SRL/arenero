import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'code_input_field.dart';
import 'back_to_login_button.dart';
import '../providers/forgot_password_form_provider.dart';

class ForgotPasswordCodeStep extends ConsumerWidget {
  const ForgotPasswordCodeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        const Text('Ingresa el código de 6 dígitos que enviamos a tu correo.'),
        CodeInputField(
          errorText: state.codeError,
          onChanged: (value) {
            ref.read(forgotPasswordFormProvider.notifier).onCodeChanged(value);
          },
        ),
        if (state.submitCodeError != null)
          Text(
            state.submitCodeError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        FilledButton(
          onPressed: state.isCodeValid && !state.isLoadingCode
              ? () => ref.read(forgotPasswordFormProvider.notifier).submitCode()
              : null,
          child: state.isLoadingCode
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Verificar código'),
        ),
        const BackToLoginButton(),
      ],
    );
  }
}
