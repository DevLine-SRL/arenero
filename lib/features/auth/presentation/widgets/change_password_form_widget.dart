import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../providers/change_password_form_provider.dart';

class ChangePasswordFormWidget extends ConsumerStatefulWidget {
  const ChangePasswordFormWidget({super.key});

  @override
  ConsumerState<ChangePasswordFormWidget> createState() =>
      _ChangePasswordFormWidget();
}

class _ChangePasswordFormWidget extends ConsumerState<ChangePasswordFormWidget> {
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordFormProvider);

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            label: const RequiredLabel('Nueva contraseña'),
            prefixIcon: const Icon(Icons.lock_outlined),
            errorText: state.passwordError,
            suffixIcon: Focus(
              canRequestFocus: false,
              child: IconButton(
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
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            ref.read(changePasswordFormProvider.notifier).onPasswordChanged(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            label: const RequiredLabel('Confirmar contraseña'),
            prefixIcon: const Icon(Icons.lock_outlined),
            errorText: state.confirmationError,
            suffixIcon: Focus(
              canRequestFocus: false,
              child: IconButton(
                icon: Icon(
                  _obscureConfirmation
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmation = !_obscureConfirmation;
                  });
                },
              ),
            ),
          ),
          obscureText: _obscureConfirmation,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            ref
                .read(changePasswordFormProvider.notifier)
                .onConfirmationChanged(value);
          },
        ),
      ],
    );
  }
}