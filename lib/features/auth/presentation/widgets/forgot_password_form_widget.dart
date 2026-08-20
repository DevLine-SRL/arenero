import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../providers/forgot_password_form_provider.dart';

class ForgotPasswordFormWidget extends ConsumerWidget {
  const ForgotPasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordFormProvider);

    return TextField(
      decoration: InputDecoration(
        label: const RequiredLabel('Correo electrónico'),
        prefixIcon: const Icon(Icons.email_outlined),
        errorText: state.emailError,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        ref.read(forgotPasswordFormProvider.notifier).onEmailChanged(value);
      },
    );
  }
}
