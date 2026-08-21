import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/clients/presentation/providers/clients_providers.dart';
import 'package:arenero/features/clients/presentation/providers/create_client_form_provider.dart';
import 'package:arenero/features/clients/presentation/providers/create_client_form_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes/fake_clients_repository.dart';

void main() {
  late FakeClientsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeClientsRepository();
    container = ProviderContainer(
      overrides: [clientsRepositoryProvider.overrideWithValue(repository)],
    );
    // El provider se descarta al quedarse sin oyentes; esta suscripción lo
    // mantiene vivo durante toda la prueba.
    container.listen(createClientFormProvider, (_, _) {});
    addTearDown(container.dispose);
  });

  CreateClientForm notifier() =>
      container.read(createClientFormProvider.notifier);

  CreateClientFormState state() => container.read(createClientFormProvider);

  void fillValidForm() {
    notifier()
      ..onNameChanged('Juan Pérez')
      ..onCiChanged('1234567')
      ..onPhoneChanged('70011223')
      ..onNitChanged('1234567890');
  }

  group('field validation', () {
    test('flags an empty name', () {
      notifier().onNameChanged('');

      expect(state().nameError, isNotNull);
    });

    test('flags a malformed ci', () {
      notifier().onCiChanged('12A');

      expect(state().ciError, isNotNull);
    });

    test('accepts an empty phone because the field is optional', () {
      notifier().onPhoneChanged('');

      expect(state().phoneError, isNull);
    });

    test('accepts an empty nit because the field is optional', () {
      notifier().onNitChanged('');

      expect(state().nitError, isNull);
    });

    test('flags a malformed nit', () {
      notifier().onNitChanged('12A');

      expect(state().nitError, isNotNull);
      expect(state().canSubmit, isFalse);
    });

    test('is not submittable until name and ci are valid', () {
      expect(state().canSubmit, isFalse);

      fillValidForm();

      expect(state().canSubmit, isTrue);
    });
  });

  group('duplicate ci check', () {
    test('reports a duplicated ci before submitting', () async {
      repository.existsResult = const Right(true);
      notifier().onCiChanged('1234567');

      await notifier().checkCiAvailability();

      expect(state().ciError, 'Esta cédula ya está registrada');
      expect(state().canSubmit, isFalse);
    });

    test('clears the warning when the ci is free', () async {
      repository.existsResult = const Right(true);
      notifier().onCiChanged('1234567');
      await notifier().checkCiAvailability();
      expect(state().ciError, isNotNull);

      repository.existsResult = const Right(false);
      await notifier().checkCiAvailability();

      expect(state().ciError, isNull);
    });

    test('does not query the repository for a malformed ci', () async {
      notifier().onCiChanged('12A');

      await notifier().checkCiAvailability();

      expect(repository.existsCallCount, 0);
    });

    test('drops the warning as soon as the user edits the ci', () async {
      repository.existsResult = const Right(true);
      notifier().onCiChanged('1234567');
      await notifier().checkCiAvailability();

      notifier().onCiChanged('7654321');

      expect(state().ciError, isNull);
    });

    test('stays silent when the check itself fails', () async {
      repository.existsResult = const Left(UnexpectedFailure());
      notifier().onCiChanged('1234567');

      await notifier().checkCiAvailability();

      expect(state().ciError, isNull);
      expect(state().isCheckingCi, isFalse);
    });
  });

  // BUG-CLI-001: el NIT repetido tiene que avisar igual que la cédula.
  group('nit duplicate warning', () {
    test('warns when the nit already belongs to another client', () async {
      repository.existsByNitResult = const Right(true);
      fillValidForm();

      await notifier().checkNitAvailability();

      expect(state().nitError, 'Este NIT ya está registrado');
      expect(state().canSubmit, isFalse);
    });

    test('keeps the warning when submitting without editing the nit', () async {
      repository.existsByNitResult = const Right(true);
      fillValidForm();
      await notifier().checkNitAvailability();

      final submitted = await notifier().submit();

      expect(submitted, isFalse);
      expect(repository.createCallCount, 0);
      expect(state().nitError, 'Este NIT ya está registrado');
    });

    test('does not query the repository for an empty nit', () async {
      notifier().onNitChanged('');

      await notifier().checkNitAvailability();

      expect(repository.existsByNitCallCount, 0);
    });

    test('does not query the repository for a malformed nit', () async {
      notifier().onNitChanged('12A45');

      await notifier().checkNitAvailability();

      expect(repository.existsByNitCallCount, 0);
    });

    test('drops the warning as soon as the user edits the nit', () async {
      repository.existsByNitResult = const Right(true);
      notifier().onNitChanged('12345');
      await notifier().checkNitAvailability();

      notifier().onNitChanged('54321');

      expect(state().nitError, isNull);
    });

    test('stays silent when the check itself fails', () async {
      repository.existsByNitResult = const Left(UnexpectedFailure());
      notifier().onNitChanged('12345');

      await notifier().checkNitAvailability();

      expect(state().nitError, isNull);
      expect(state().isCheckingNit, isFalse);
    });

    test('surfaces the constraint violation raised on submit', () async {
      repository.createResult = const Left(
        ValidationFailure(
          message: 'Ya existe un cliente registrado con ese NIT.',
          errors: {'nit': 'Este NIT ya está registrado'},
          code: '23505',
        ),
      );
      fillValidForm();

      final submitted = await notifier().submit();

      expect(submitted, isFalse);
      expect(state().nitError, 'Este NIT ya está registrado');
    });
  });

  group('submit', () {
    test('returns the created client for inline sale registration', () async {
      notifier().reset(initialName: 'Constructora Norte');
      notifier().onCiChanged('9876543');

      final client = await notifier().submitClient();

      expect(client, isNotNull);
      expect(client!.name, 'Constructora Norte');
      expect(repository.lastCreatedName, 'Constructora Norte');
    });

    test(
      'refuses to submit an invalid form without calling the repository',
      () async {
        notifier().onNameChanged('');

        final submitted = await notifier().submit();

        expect(submitted, isFalse);
        expect(repository.createCallCount, 0);
      },
    );

    test('validates every field when submitting an untouched form', () async {
      final submitted = await notifier().submit();

      expect(submitted, isFalse);
      expect(state().nameError, isNotNull);
      expect(state().ciError, isNotNull);
    });

    test('sends the form and resets it on success', () async {
      fillValidForm();

      final submitted = await notifier().submit();

      expect(submitted, isTrue);
      expect(repository.lastCreatedName, 'Juan Pérez');
      expect(repository.lastCreatedCi, '1234567');
      expect(repository.lastCreatedNit, '1234567890');
      expect(state().name, '');
      expect(state().ci, '');
      expect(state().nit, '');
    });

    // Tarea #40: la restricción de la base de datos es la garantía real, así
    // que el error que llega del servidor tiene que aterrizar en el campo.
    test('shows a server side duplicate on the ci field', () async {
      repository.createResult = const Left(
        ValidationFailure(
          message: 'Ya existe un cliente registrado con esa cédula.',
          errors: {'ci': 'Esta cédula ya está registrada'},
          code: '23505',
        ),
      );
      fillValidForm();

      final submitted = await notifier().submit();

      expect(submitted, isFalse);
      expect(state().ciError, 'Esta cédula ya está registrada');
      expect(state().submitError, contains('Ya existe un cliente'));
    });

    test(
      'surfaces a failure without field details as a banner message',
      () async {
        repository.createResult = const Left(
          UnauthorizedFailure(message: 'No tienes permisos.'),
        );
        fillValidForm();

        final submitted = await notifier().submit();

        expect(submitted, isFalse);
        expect(state().submitError, 'No tienes permisos.');
        expect(state().isSubmitting, isFalse);
      },
    );
  });
}
