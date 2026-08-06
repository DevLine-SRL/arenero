import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository repository;

  const RequestPasswordResetUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String rawEmail,
    String? redirectTo,
  }) async {
    final normalizedEmail = rawEmail.trim().toLowerCase();

    final emailResult = Email.create(normalizedEmail);

    return emailResult.fold(
      Left.new,
      (email) => repository.requestPasswordReset(
        email: email,
        redirectTo: _normalizeRedirectTo(redirectTo),
      ),
    );
  }

  String? _normalizeRedirectTo(String? redirectTo) {
    final normalizedRedirect = redirectTo?.trim();

    if (normalizedRedirect == null || normalizedRedirect.isEmpty) {
      return null;
    }

    return normalizedRedirect;
  }
}