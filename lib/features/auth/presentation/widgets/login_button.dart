import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/login_form_provider.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginFormProvider);

    final canSubmit =
        state.isValid &&
        !state.isSubmitting &&
        !state.isLocked;

    return FilledButton(
      onPressed: canSubmit
          ? () {
              FocusScope.of(context).unfocus();
              ref.read(loginFormProvider.notifier).submit();
            }
          : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 200,
        ),
        child: state.isSubmitting
            ? const Row(
                key: ValueKey('loading'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Iniciando sesión...'),
                ],
              )
            : const Row(
                key: ValueKey('idle'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login),
                  SizedBox(width: 8),
                  Text('Iniciar sesión'),
                ],
              ),
      ),
    );
  }
}