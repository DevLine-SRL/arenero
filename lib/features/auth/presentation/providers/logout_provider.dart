import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_providers.dart';

part 'logout_provider.g.dart';

@riverpod
class Logout extends _$Logout {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> call() async {
    state = const AsyncLoading();
    final useCase = ref.read(logoutUseCaseProvider);
    state = await AsyncValue.guard(() => useCase());
  }
}
