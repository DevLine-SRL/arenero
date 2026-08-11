sealed class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure($code): $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Sin conexión a internet', super.code});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'Error inesperado', super.code});
}

final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    super.message = 'Credenciales inválidas',
    super.code,
  });
}

final class AccountDisabledFailure extends Failure {
  const AccountDisabledFailure({
    super.message = 'Tu cuenta está desactivada. Contacta al administrador.',
    super.code,
  });
}

final class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({
    super.message = 'Datos inválidos',
    this.errors,
    super.code,
  });
}

final class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Error de caché', super.code});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Recurso no encontrado', super.code});
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'No autorizado', super.code});
}
