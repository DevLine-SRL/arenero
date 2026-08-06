import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/password_recovery_provider.dart';

class PasswordRecoveryDialog extends ConsumerStatefulWidget {
  final String? redirectTo;

  const PasswordRecoveryDialog({
    super.key,
    this.redirectTo,
  });

  @override
  ConsumerState<PasswordRecoveryDialog> createState() {
    return _PasswordRecoveryDialogState();
  }
}

class _PasswordRecoveryDialogState
    extends ConsumerState<PasswordRecoveryDialog> {
  late final TextEditingController _emailController;
  late final FocusNode _emailFocusNode;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _emailFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _emailFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordRecoveryProvider);
    final notifier = ref.read(passwordRecoveryProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 440,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ingresa tu correo electrónico. Te enviaremos instrucciones '
                'para recuperar tu contraseña.',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                enabled: !state.isSubmitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [
                  AutofillHints.email,
                ],
                onChanged: notifier.onEmailChanged,
                onSubmitted: (_) {
                  if (!state.isSubmitting) {
                    notifier.submit(
                      redirectTo: widget.redirectTo,
                    );
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'usuario@correo.com',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                  ),
                  errorText: state.emailError,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (state.message != null) ...[
                const SizedBox(height: 16),
                _RecoveryMessage(
                  message: state.message!,
                  isSuccess: state.isSuccess,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: state.isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: state.isSubmitting
              ? null
              : () {
                  notifier.submit(
                    redirectTo: widget.redirectTo,
                  );
                },
          child: state.isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Text('Enviar instrucciones'),
        ),
      ],
    );
  }
}

class _RecoveryMessage extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const _RecoveryMessage({
    required this.message,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = isSuccess
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;

    final foregroundColor = isSuccess
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    final icon = isSuccess
        ? Icons.check_circle_outline
        : Icons.info_outline;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: foregroundColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}