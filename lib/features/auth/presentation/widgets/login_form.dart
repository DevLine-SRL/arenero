import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../providers/login_form_provider.dart';
import 'password_recovery_button.dart';

class LoginFormWidget extends ConsumerStatefulWidget {
  const LoginFormWidget({super.key});

  @override
  ConsumerState<LoginFormWidget> createState() {
    return _LoginFormWidgetState();
  }
}

class _LoginFormWidgetState
    extends ConsumerState<LoginFormWidget> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            enabled: !state.isSubmitting,
            decoration: InputDecoration(
              label: const RequiredLabel(
                'Correo electrónico',
              ),
              hintText: 'usuario@correo.com',
              prefixIcon: const Icon(
                Icons.email_outlined,
              ),
              errorText: state.emailError,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [
              AutofillHints.email,
              AutofillHints.username,
            ],
            autocorrect: false,
            enableSuggestions: false,
            onChanged: notifier.onEmailChanged,
            onSubmitted: (_) {
              _passwordFocusNode.requestFocus();
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            enabled: !state.isSubmitting,
            decoration: InputDecoration(
              label: const RequiredLabel(
                'Contraseña',
              ),
              prefixIcon: const Icon(
                Icons.lock_outlined,
              ),
              errorText: state.passwordError,
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'Mostrar contraseña'
                    : 'Ocultar contraseña',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: state.isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [
              AutofillHints.password,
            ],
            onChanged: notifier.onPasswordChanged,
            onSubmitted: (_) {
              if (
                  state.isValid &&
                  !state.isSubmitting &&
                  !state.isLocked
              ) {
                FocusScope.of(context).unfocus();
                notifier.submit();
              }
            },
          ),
          const SizedBox(height: 4),
          const PasswordRecoveryButton(
            // Coloca aquí el deep link autorizado en Supabase.
            //
            // Ejemplo:
            // redirectTo:
            //     'io.supabase.arenero://reset-password',
          ),
        ],
      ),
    );
  }
}