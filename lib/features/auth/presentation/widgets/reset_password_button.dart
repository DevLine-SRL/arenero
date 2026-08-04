import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reset_password_form_provider.dart';

class ResetPasswordButton extends ConsumerWidget {
  const ResetPasswordButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resetPasswordFormProvider);

    if (state.isSuccess) {
      return const SizedBox.shrink();
    }

    return FilledButton(
      onPressed: state.isValid && !state.isSubmitting
          ? () => ref.read(resetPasswordFormProvider.notifier).submit()
          : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: state.isSubmitting
          ? const Row(
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
                Text('Enviando...'),
              ],
            )
          : const Text('Enviar enlace de recuperación'),
    );
  }
}