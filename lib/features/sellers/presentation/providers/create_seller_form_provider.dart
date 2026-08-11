import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/validators/validators.dart';
import '../../../../shared/value_objects/value_objects.dart';
import 'create_seller_form_state.dart';
import 'sellers_providers.dart';

part 'create_seller_form_provider.g.dart';

@riverpod
class CreateSellerForm extends _$CreateSellerForm {
  @override
  CreateSellerFormState build() => const CreateSellerFormState();

  void onNameChanged(String value) {
    state = state.copyWith(
      name: collapseSpaces(value),
      nameError: fullName(value),
      submitError: null,
    );
  }

  void onEmailChanged(String value) {
    final result = Email.create(value);

    state = state.copyWith(
      email: value,
      emailError: result.fold((failure) => failure.message, (_) => null),
      submitError: null,
    );
  }

  void onPasswordChanged(String value) {
    final result = Password.create(value);

    state = state.copyWith(
      password: value,
      passwordError: result.fold((failure) => failure.message, (_) => null),
      confirmPasswordError: _confirmPasswordError(state.confirmPassword, value),
      submitError: null,
    );
  }

  void onConfirmPasswordChanged(String value) {
    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordError: _confirmPasswordError(value, state.password),
      submitError: null,
    );
  }

  Future<bool> submit() async {
    final valid = _validateAll();
    if (!valid || state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, submitError: null);

    final useCase = ref.read(createSellerUseCaseProvider);
    final result = await useCase(
      name: state.name,
      rawEmail: state.email,
      rawPassword: state.password,
    );

    state = state.copyWith(isSubmitting: false);

    return result.fold((failure) {
      state = state.copyWith(submitError: failure.message);
      return false;
    }, (_) => true);
  }

  bool _validateAll() {
    final nameError = fullName(state.name);
    final emailError = Email.create(
      state.email,
    ).fold((failure) => failure.message, (_) => null);
    final passwordError = Password.create(
      state.password,
    ).fold((failure) => failure.message, (_) => null);
    final confirmPasswordError = _confirmPasswordError(
      state.confirmPassword,
      state.password,
    );

    state = state.copyWith(
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
    );

    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  String? _confirmPasswordError(String confirm, String password) {
    if (confirm != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
