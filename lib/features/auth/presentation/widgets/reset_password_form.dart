import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../providers/reset_password_form_provider.dart';

class ResetPasswordFormWidget extends ConsumerWidget {
  const ResetPasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resetPasswordFormProvider);

    return TextField(
      decoration: InputDecoration(
        label: const RequiredLabel('Correo electrónico'),
        prefixIcon: const Icon(Icons.email_outlined),
        errorText: state.emailError,
        border: state.emailError != null
            ? OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 2,
                ),
              )
            : null,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      enabled: !state.isSuccess,
      onChanged: (value) {
        ref.read(resetPasswordFormProvider.notifier).onEmailChanged(value);
      },
      onSubmitted: (_) {
        if (state.isValid) {
          ref.read(resetPasswordFormProvider.notifier).submit();
        }
      },
    );
  }
}