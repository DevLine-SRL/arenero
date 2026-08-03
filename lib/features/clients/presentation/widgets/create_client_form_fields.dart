import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../providers/create_client_form_provider.dart';

class CreateClientFormFields extends ConsumerStatefulWidget {
  final VoidCallback? onSubmitted;

  const CreateClientFormFields({super.key, this.onSubmitted});

  @override
  ConsumerState<CreateClientFormFields> createState() =>
      _CreateClientFormFieldsState();
}

class _CreateClientFormFieldsState
    extends ConsumerState<CreateClientFormFields> {
  final _ciFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Tarea #40: al salir del campo se consulta si la cédula ya existe, para
    // avisar antes de que el usuario termine de llenar el formulario.
    _ciFocus.addListener(() {
      if (!_ciFocus.hasFocus) {
        ref.read(createClientFormProvider.notifier).checkCiAvailability();
      }
    });
  }

  @override
  void dispose() {
    _ciFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createClientFormProvider);
    final notifier = ref.read(createClientFormProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            label: const RequiredLabel('Nombre completo'),
            prefixIcon: const Icon(Icons.person_outline_rounded),
            errorText: state.nameError,
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: notifier.onNameChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          focusNode: _ciFocus,
          decoration: InputDecoration(
            label: const RequiredLabel('Cédula de identidad'),
            prefixIcon: const Icon(Icons.badge_outlined),
            errorText: state.ciError,
            errorMaxLines: 2,
            helperText: 'Complemento opcional, por ejemplo 1234567-1A',
            suffixIcon: state.isCheckingCi
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onChanged: notifier.onCiChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: const Icon(Icons.phone_outlined),
            errorText: state.phoneError,
            helperText: 'Opcional',
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onChanged: notifier.onPhoneChanged,
          onSubmitted: (_) => widget.onSubmitted?.call(),
        ),
      ],
    );
  }
}
