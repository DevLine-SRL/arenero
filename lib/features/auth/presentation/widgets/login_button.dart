import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/login_form_provider.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(loginFormProvider).isValid;

    return FilledButton.icon(
      onPressed: isFormValid
        ? () => ref.read(loginFormProvider.notifier).submit()
        : null,
      icon: const Icon(Icons.login),
      label: const Text('Iniciar Sesión'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
