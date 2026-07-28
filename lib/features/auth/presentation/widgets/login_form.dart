import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/login_form_provider.dart';

class LoginFormWidget extends ConsumerStatefulWidget {
  const LoginFormWidget({super.key});

  @override
  ConsumerState<LoginFormWidget> createState() => _LoginFormWidget();
}

class _LoginFormWidget extends ConsumerState<LoginFormWidget> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginFormProvider);

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: state.emailError,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            ref.read(loginFormProvider.notifier).onEmailChanged(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outlined),
            errorText: state.passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            ref.read(loginFormProvider.notifier).onPasswordChanged(value);
          },
        ),
      ],
    );
  }
}
