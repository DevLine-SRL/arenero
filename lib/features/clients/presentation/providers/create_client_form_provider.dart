import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/validators/validators.dart';
import '../../domain/entities/client.dart';
import '../../domain/usecases/check_nit_available_usecase.dart';
import 'clients_providers.dart';
import 'clients_search_provider.dart';
import 'create_client_form_state.dart';

part 'create_client_form_provider.g.dart';

/// `CreateClientFormState.copyWith` borra los mensajes de error que no recibe,
/// para poder limpiarlos pasando `null`. Por eso cada método de aquí declara
/// los cuatro errores: así se ve en el sitio qué queda y qué se limpia, sin
/// depender de un valor por defecto escondido.
@riverpod
class CreateClientForm extends _$CreateClientForm {
  @override
  CreateClientFormState build() => const CreateClientFormState();

  void reset({String initialName = ''}) {
    state = const CreateClientFormState();
    if (initialName.trim().isNotEmpty) {
      onNameChanged(initialName);
    }
  }

  void onNameChanged(String value) {
    state = state.copyWith(
      name: value,
      nameError: required(value),
      ciError: state.ciError,
      phoneError: state.phoneError,
      nitError: state.nitError,
      submitError: null,
    );
  }

  void onCiChanged(String value) {
    // Un aviso de duplicado deja de aplicar en cuanto cambia el valor, así que
    // el error de cédula se recalcula solo desde el formato.
    state = state.copyWith(
      ci: value,
      nameError: state.nameError,
      ciError: ci(value),
      phoneError: state.phoneError,
      nitError: state.nitError,
      isCheckingCi: false,
      submitError: null,
    );
  }

  void onPhoneChanged(String value) {
    state = state.copyWith(
      phone: value,
      nameError: state.nameError,
      ciError: state.ciError,
      phoneError: phone(value),
      nitError: state.nitError,
      submitError: null,
    );
  }

  void onNitChanged(String value) {
    // Igual que con la cédula, el aviso de duplicado deja de aplicar en cuanto
    // cambia el valor: el error se recalcula solo desde el formato.
    state = state.copyWith(
      nit: value,
      nameError: state.nameError,
      ciError: state.ciError,
      phoneError: state.phoneError,
      nitError: nit(value),
      isCheckingNit: false,
      submitError: null,
    );
  }

  /// Tarea #40: avisa de cédula duplicada en cuanto el campo pierde el foco,
  /// sin esperar al envío.
  ///
  /// Si la consulta falla no se muestra nada: es solo un aviso temprano, y la
  /// restricción `clients_ci_unique` sigue cubriendo el caso al registrar.
  Future<void> checkCiAvailability() async {
    final value = state.ci;
    if (ci(value) != null) return;

    state = state.copyWith(
      nameError: state.nameError,
      ciError: state.ciError,
      phoneError: state.phoneError,
      nitError: state.nitError,
      isCheckingCi: true,
    );

    final result = await ref.read(checkCiAvailableUseCaseProvider)(value);

    // El usuario pudo seguir escribiendo mientras se consultaba.
    if (state.ci != value) return;

    state = state.copyWith(
      nameError: state.nameError,
      ciError: result.fold(
        (_) => state.ciError,
        (available) => available ? null : 'Esta cédula ya está registrada',
      ),
      phoneError: state.phoneError,
      nitError: state.nitError,
      isCheckingCi: false,
    );
  }

  /// Tarea #40: mismo aviso que [checkCiAvailability], para el NIT.
  ///
  /// El NIT es opcional, así que un campo vacío no consulta nada. Si la
  /// consulta falla no se muestra nada y el alta sigue adelante: la base no
  /// impide el NIT repetido.
  Future<void> checkNitAvailability() async {
    final value = state.nit;
    if (value.trim().isEmpty || nit(value) != null) return;

    state = state.copyWith(
      nameError: state.nameError,
      ciError: state.ciError,
      phoneError: state.phoneError,
      nitError: state.nitError,
      isCheckingNit: true,
    );

    final result = await CheckNitAvailableUseCase(
      ref.read(clientsRepositoryProvider),
    )(value);

    // El usuario pudo seguir escribiendo mientras se consultaba.
    if (state.nit != value) return;

    state = state.copyWith(
      nameError: state.nameError,
      ciError: state.ciError,
      phoneError: state.phoneError,
      nitError: result.fold(
        (_) => state.nitError,
        (available) => available ? null : 'Este NIT ya está registrado',
      ),
      isCheckingNit: false,
    );
  }

  Future<bool> submit() async {
    return await submitClient() != null;
  }

  Future<Client?> submitClient() async {
    if (!_validateAll() || state.isSubmitting) return null;

    state = state.copyWith(
      nameError: state.nameError,
      ciError: state.ciError,
      phoneError: state.phoneError,
      nitError: state.nitError,
      isSubmitting: true,
      submitError: null,
    );

    // El aviso al salir del campo no alcanza: si se pulsa Guardar con el foco
    // todavía en el NIT, la consulta del blur y el alta corren en paralelo. Sin
    // restricción de unicidad en la base, esta comprobación es la barrera.
    final rawNit = state.nit;
    if (rawNit.trim().isNotEmpty && nit(rawNit) == null) {
      final taken = await CheckNitAvailableUseCase(
        ref.read(clientsRepositoryProvider),
      )(rawNit);

      final duplicated = taken.fold((_) => false, (available) => !available);
      if (duplicated) {
        state = state.copyWith(
          nameError: state.nameError,
          ciError: state.ciError,
          phoneError: state.phoneError,
          nitError: 'Este NIT ya está registrado',
          isSubmitting: false,
          isCheckingNit: false,
        );
        return null;
      }
    }

    final result = await ref.read(createClientUseCaseProvider)(
      name: state.name,
      rawCi: state.ci,
      phone: state.phone,
      nit: state.nit,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          nameError: _fieldError(failure, 'name') ?? state.nameError,
          ciError: _fieldError(failure, 'ci') ?? state.ciError,
          phoneError: state.phoneError,
          nitError: _fieldError(failure, 'nit') ?? state.nitError,
          isSubmitting: false,
          submitError: failure.message,
        );
        return null;
      },
      (client) {
        state = const CreateClientFormState();
        ref.invalidate(clientsSearchProvider);
        return client;
      },
    );
  }

  bool _validateAll() {
    final nameError = required(state.name);
    final ciFormatError = ci(state.ci);
    final phoneError = phone(state.phone);
    final nitFormatError = nit(state.nit);

    state = state.copyWith(
      nameError: nameError,
      // Con el formato correcto, un aviso previo de duplicado sigue vigente.
      ciError: ciFormatError ?? state.ciError,
      phoneError: phoneError,
      // Con el formato correcto, un aviso previo de duplicado sigue vigente.
      nitError: nitFormatError ?? state.nitError,
      submitError: null,
    );

    return state.nameError == null &&
        state.ciError == null &&
        state.phoneError == null &&
        state.nitError == null;
  }

  String? _fieldError(Failure failure, String field) {
    if (failure is! ValidationFailure) return null;
    return failure.errors?[field];
  }
}
