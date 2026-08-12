// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

final class AuthRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  AuthRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'09d2207e9dfe4f413b98004fa1729ab67257beba';

@ProviderFor(authLocalDataSource)
final authLocalDataSourceProvider = AuthLocalDataSourceProvider._();

final class AuthLocalDataSourceProvider
    extends
        $FunctionalProvider<
          AuthLocalDataSource,
          AuthLocalDataSource,
          AuthLocalDataSource
        >
    with $Provider<AuthLocalDataSource> {
  AuthLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthLocalDataSource create(Ref ref) {
    return authLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthLocalDataSource>(value),
    );
  }
}

String _$authLocalDataSourceHash() =>
    r'88da6b9bfe2115ff79d84f84d2b8d9cf8a2ecb86';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'4f2bac0e1bc4b6227ac9fc3175ea74d89fe18562';

@ProviderFor(loginUseCase)
final loginUseCaseProvider = LoginUseCaseProvider._();

final class LoginUseCaseProvider
    extends $FunctionalProvider<LoginUseCase, LoginUseCase, LoginUseCase>
    with $Provider<LoginUseCase> {
  LoginUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoginUseCase create(Ref ref) {
    return loginUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginUseCase>(value),
    );
  }
}

String _$loginUseCaseHash() => r'e082833fd1fc26be8c5fac08d612713cb2c18a17';

@ProviderFor(watchAuthStateUseCase)
final watchAuthStateUseCaseProvider = WatchAuthStateUseCaseProvider._();

final class WatchAuthStateUseCaseProvider
    extends
        $FunctionalProvider<
          WatchAuthStateUseCase,
          WatchAuthStateUseCase,
          WatchAuthStateUseCase
        >
    with $Provider<WatchAuthStateUseCase> {
  WatchAuthStateUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAuthStateUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAuthStateUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchAuthStateUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchAuthStateUseCase create(Ref ref) {
    return watchAuthStateUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchAuthStateUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchAuthStateUseCase>(value),
    );
  }
}

String _$watchAuthStateUseCaseHash() =>
    r'bb87135ca277fb045a27412d2e037c680ad850e1';

@ProviderFor(logoutUseCase)
final logoutUseCaseProvider = LogoutUseCaseProvider._();

final class LogoutUseCaseProvider
    extends $FunctionalProvider<LogoutUseCase, LogoutUseCase, LogoutUseCase>
    with $Provider<LogoutUseCase> {
  LogoutUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoutUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoutUseCaseHash();

  @$internal
  @override
  $ProviderElement<LogoutUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogoutUseCase create(Ref ref) {
    return logoutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogoutUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogoutUseCase>(value),
    );
  }
}

String _$logoutUseCaseHash() => r'2b963e9e0eff2155f687d45b1b5c652ddb695d62';

@ProviderFor(getCurrentUserUseCase)
final getCurrentUserUseCaseProvider = GetCurrentUserUseCaseProvider._();

final class GetCurrentUserUseCaseProvider
    extends
        $FunctionalProvider<
          GetCurrentUserUseCase,
          GetCurrentUserUseCase,
          GetCurrentUserUseCase
        >
    with $Provider<GetCurrentUserUseCase> {
  GetCurrentUserUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentUserUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentUserUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentUserUseCase create(Ref ref) {
    return getCurrentUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentUserUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentUserUseCase>(value),
    );
  }
}

String _$getCurrentUserUseCaseHash() =>
    r'4a27d130940e444424e46ed4afad7c5a5c8cf5b2';

@ProviderFor(touchLastSeenUseCase)
final touchLastSeenUseCaseProvider = TouchLastSeenUseCaseProvider._();

final class TouchLastSeenUseCaseProvider
    extends
        $FunctionalProvider<
          TouchLastSeenUseCase,
          TouchLastSeenUseCase,
          TouchLastSeenUseCase
        >
    with $Provider<TouchLastSeenUseCase> {
  TouchLastSeenUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'touchLastSeenUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$touchLastSeenUseCaseHash();

  @$internal
  @override
  $ProviderElement<TouchLastSeenUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TouchLastSeenUseCase create(Ref ref) {
    return touchLastSeenUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TouchLastSeenUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TouchLastSeenUseCase>(value),
    );
  }
}

String _$touchLastSeenUseCaseHash() =>
    r'a445261a6d7e2a6397319ebc4f9ccd9388adda48';

@ProviderFor(checkLoginLockUseCase)
final checkLoginLockUseCaseProvider = CheckLoginLockUseCaseProvider._();

final class CheckLoginLockUseCaseProvider
    extends
        $FunctionalProvider<
          CheckLoginLockUseCase,
          CheckLoginLockUseCase,
          CheckLoginLockUseCase
        >
    with $Provider<CheckLoginLockUseCase> {
  CheckLoginLockUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkLoginLockUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkLoginLockUseCaseHash();

  @$internal
  @override
  $ProviderElement<CheckLoginLockUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckLoginLockUseCase create(Ref ref) {
    return checkLoginLockUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckLoginLockUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckLoginLockUseCase>(value),
    );
  }
}

String _$checkLoginLockUseCaseHash() =>
    r'bca82264501c75a53017f01debea67981b3c4911';

@ProviderFor(registerFailedLoginUseCase)
final registerFailedLoginUseCaseProvider =
    RegisterFailedLoginUseCaseProvider._();

final class RegisterFailedLoginUseCaseProvider
    extends
        $FunctionalProvider<
          RegisterFailedLoginUseCase,
          RegisterFailedLoginUseCase,
          RegisterFailedLoginUseCase
        >
    with $Provider<RegisterFailedLoginUseCase> {
  RegisterFailedLoginUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerFailedLoginUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerFailedLoginUseCaseHash();

  @$internal
  @override
  $ProviderElement<RegisterFailedLoginUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RegisterFailedLoginUseCase create(Ref ref) {
    return registerFailedLoginUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterFailedLoginUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterFailedLoginUseCase>(value),
    );
  }
}

String _$registerFailedLoginUseCaseHash() =>
    r'826e4e39e576b5f3ef43770a0861ac829a60c063';

@ProviderFor(resetLoginAttemptsUseCase)
final resetLoginAttemptsUseCaseProvider = ResetLoginAttemptsUseCaseProvider._();

final class ResetLoginAttemptsUseCaseProvider
    extends
        $FunctionalProvider<
          ResetLoginAttemptsUseCase,
          ResetLoginAttemptsUseCase,
          ResetLoginAttemptsUseCase
        >
    with $Provider<ResetLoginAttemptsUseCase> {
  ResetLoginAttemptsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetLoginAttemptsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetLoginAttemptsUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResetLoginAttemptsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResetLoginAttemptsUseCase create(Ref ref) {
    return resetLoginAttemptsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetLoginAttemptsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetLoginAttemptsUseCase>(value),
    );
  }
}

String _$resetLoginAttemptsUseCaseHash() =>
    r'c84fcad664472d278526c592f39c92230af376e7';

@ProviderFor(sendForgotPasswordCodeUseCase)
final sendForgotPasswordCodeUseCaseProvider =
    SendForgotPasswordCodeUseCaseProvider._();

final class SendForgotPasswordCodeUseCaseProvider
    extends
        $FunctionalProvider<
          SendForgotPasswordCodeUseCase,
          SendForgotPasswordCodeUseCase,
          SendForgotPasswordCodeUseCase
        >
    with $Provider<SendForgotPasswordCodeUseCase> {
  SendForgotPasswordCodeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendForgotPasswordCodeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendForgotPasswordCodeUseCaseHash();

  @$internal
  @override
  $ProviderElement<SendForgotPasswordCodeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SendForgotPasswordCodeUseCase create(Ref ref) {
    return sendForgotPasswordCodeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendForgotPasswordCodeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendForgotPasswordCodeUseCase>(
        value,
      ),
    );
  }
}

String _$sendForgotPasswordCodeUseCaseHash() =>
    r'fdb5b5b786e6db67bd661f13adf22c662478926e';

@ProviderFor(verifyForgotPasswordCodeUseCase)
final verifyForgotPasswordCodeUseCaseProvider =
    VerifyForgotPasswordCodeUseCaseProvider._();

final class VerifyForgotPasswordCodeUseCaseProvider
    extends
        $FunctionalProvider<
          VerifyForgotPasswordCodeUseCase,
          VerifyForgotPasswordCodeUseCase,
          VerifyForgotPasswordCodeUseCase
        >
    with $Provider<VerifyForgotPasswordCodeUseCase> {
  VerifyForgotPasswordCodeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyForgotPasswordCodeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyForgotPasswordCodeUseCaseHash();

  @$internal
  @override
  $ProviderElement<VerifyForgotPasswordCodeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerifyForgotPasswordCodeUseCase create(Ref ref) {
    return verifyForgotPasswordCodeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyForgotPasswordCodeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyForgotPasswordCodeUseCase>(
        value,
      ),
    );
  }
}

String _$verifyForgotPasswordCodeUseCaseHash() =>
    r'ad7a074fe2074a57f4d1cf481ec735789b42df2f';

@ProviderFor(changePasswordUseCase)
final changePasswordUseCaseProvider = ChangePasswordUseCaseProvider._();

final class ChangePasswordUseCaseProvider
    extends
        $FunctionalProvider<
          ChangePasswordUseCase,
          ChangePasswordUseCase,
          ChangePasswordUseCase
        >
    with $Provider<ChangePasswordUseCase> {
  ChangePasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ChangePasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangePasswordUseCase create(Ref ref) {
    return changePasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePasswordUseCase>(value),
    );
  }
}

String _$changePasswordUseCaseHash() =>
    r'9fc17cf46dc8f8024d7920160308f91cf6e71379';

@ProviderFor(authSession)
final authSessionProvider = AuthSessionProvider._();

final class AuthSessionProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  AuthSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authSession(ref);
  }
}

String _$authSessionHash() => r'4e8b5136b66c2db633de5d2bf9b7c226fe425773';
