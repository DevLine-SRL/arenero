import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/password_recovery_provider.dart';

class PasswordRecoveryDialog extends ConsumerStatefulWidget {
  final String? redirectTo;

  const PasswordRecoveryDialog({super.key, this.redirectTo});

  @override
  ConsumerState<PasswordRecoveryDialog> createState() {
    return _PasswordRecoveryDialogState();
  }
}

class _PasswordRecoveryDialogState
    extends ConsumerState<PasswordRecoveryDialog> {
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordRecoveryProvider);
    final notifier = ref.read(passwordRecoveryProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    if (_emailController.text != state.email) {
      _emailController.value = TextEditingValue(
        text: state.email,
        selection: TextSelection.collapsed(offset: state.email.length),
      );
    }

    return PopScope(
      canPop: !state.isSubmitting,
      child: AlertDialog(
        icon: Icon(
          Icons.lock_reset_outlined,
          size: 36,
          color: colorScheme.primary,
        ),
        title: const Text('Recuperar contraseña', textAlign: TextAlign.center),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ingresa tu correo electrónico. Te enviaremos '
                      'instrucciones para recuperar tu contraseña.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      autofocus: true,
                      enabled: !state.isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.email],
                      onChanged: notifier.onEmailChanged,
                      onFieldSubmitted: (_) {
                        _submit(context, notifier, state.isSubmitting);
                      },
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Ingresa tu correo electrónico.';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'usuario@correo.com',
                        helperText: 'Ingresa el correo asociado a tu cuenta.',
                        prefixIcon: const Icon(Icons.email_outlined),
                        errorText: state.emailError,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorScheme.error,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: state.message == null
                          ? const SizedBox.shrink(
                              key: ValueKey('no-recovery-message'),
                            )
                          : Padding(
                              key: ValueKey(
                                state.isSuccess
                                    ? 'recovery-success'
                                    : 'recovery-error',
                              ),
                              padding: const EdgeInsets.only(top: 16),
                              child: _RecoveryMessage(
                                message: state.message!,
                                isSuccess: state.isSuccess,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          TextButton(
            onPressed: state.isSubmitting
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  },
            child: Text(state.isSuccess ? 'Cerrar' : 'Cancelar'),
          ),
          if (!state.isSuccess)
            FilledButton(
              onPressed: state.isSubmitting
                  ? null
                  : () {
                      _submit(context, notifier, state.isSubmitting);
                    },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: state.isSubmitting
                    ? const Row(
                        key: ValueKey('password-recovery-loading'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Enviando...'),
                        ],
                      )
                    : const Row(
                        key: ValueKey('password-recovery-idle'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_outlined, size: 19),
                          SizedBox(width: 8),
                          Text('Enviar instrucciones'),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }

  void _submit(
    BuildContext context,
    PasswordRecovery notifier,
    bool isSubmitting,
  ) {
    if (isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      notifier.submit(redirectTo: widget.redirectTo);
    }
  }
}

class _RecoveryMessage extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const _RecoveryMessage({required this.message, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = isSuccess
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;

    final foregroundColor = isSuccess
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    final borderColor = isSuccess ? colorScheme.primary : colorScheme.error;

    final icon = isSuccess
        ? Icons.check_circle_outline_rounded
        : Icons.info_outline_rounded;

    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor.withValues(alpha: 0.45)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foregroundColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
