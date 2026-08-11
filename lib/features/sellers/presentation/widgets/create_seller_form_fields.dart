import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../providers/create_seller_form_provider.dart';

class CreateSellerFormFields extends ConsumerStatefulWidget {
  final VoidCallback? onSubmitted;

  const CreateSellerFormFields({super.key, this.onSubmitted});

  @override
  ConsumerState<CreateSellerFormFields> createState() =>
      _CreateSellerFormFieldsState();
}

class _CreateSellerFormFieldsState
    extends ConsumerState<CreateSellerFormFields> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createSellerFormProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            label: const RequiredLabel('Nombre'),
            prefixIcon: const Icon(Icons.person_outline_rounded),
            errorText: state.nameError,
          ),
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            ref.read(createSellerFormProvider.notifier).onNameChanged(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            label: const RequiredLabel('Correo electrónico'),
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: state.emailError,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            ref.read(createSellerFormProvider.notifier).onEmailChanged(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            label: const RequiredLabel('Contraseña'),
            prefixIcon: const Icon(Icons.lock_outlined),
            errorText: state.passwordError,
            errorMaxLines: 3,
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
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            ref
                .read(createSellerFormProvider.notifier)
                .onPasswordChanged(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            label: const RequiredLabel('Repetir contraseña'),
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            errorText: state.confirmPasswordError,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            ref
                .read(createSellerFormProvider.notifier)
                .onConfirmPasswordChanged(value);
          },
          onSubmitted: (_) => widget.onSubmitted?.call(),
        ),
      ],
    );
  }
}
