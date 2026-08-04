import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reset_password_form_provider.dart';

class ResetPasswordMessage extends ConsumerWidget {
  const ResetPasswordMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resetPasswordFormProvider);

    if (state.isSuccess) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Si el correo está registrado, se ha enviado un enlace de recuperación a tu dirección de correo electrónico.',
                style: TextStyle(color: Colors.green.shade900),
              ),
            ),
          ],
        ),
      );
    }

    if (state.submitError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No fue posible procesar la solicitud. Si el correo es válido, recibirás instrucciones para recuperar tu contraseña.',
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}