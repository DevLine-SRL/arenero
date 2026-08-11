import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/change_password_form_provider.dart';

class ChangePasswordButton extends ConsumerWidget {
  const ChangePasswordButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(changePasswordFormProvider);

    return FilledButton(
      onPressed: state.isValid && !state.isSubmitting
          ? () => ref.read(changePasswordFormProvider.notifier).submit()
          : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
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
                Text('Cambiando contraseña...'),
              ],
            )
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_reset),
                SizedBox(width: 8),
                Text('Cambiar contraseña'),
              ],
            ),
    );
  }
}
