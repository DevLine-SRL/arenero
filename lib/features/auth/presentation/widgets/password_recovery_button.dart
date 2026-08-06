import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/password_recovery_provider.dart';
import 'password_recovery_dialog.dart';

class PasswordRecoveryButton extends ConsumerWidget {
  final String? redirectTo;

  const PasswordRecoveryButton({super.key, this.redirectTo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () async {
          ref.invalidate(passwordRecoveryProvider);

          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return PasswordRecoveryDialog(redirectTo: redirectTo);
            },
          );

          if (context.mounted) {
            ref.invalidate(passwordRecoveryProvider);
          }
        },
        child: const Text('¿Olvidaste tu contraseña?'),
      ),
    );
  }
}
