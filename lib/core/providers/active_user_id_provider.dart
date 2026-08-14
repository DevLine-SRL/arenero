import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

part 'active_user_id_provider.g.dart';

/// Usuario con sesión activa. `null` si nadie inició sesión. Las datasources
/// locales lo usan para aislar la caché y el outbox por usuario.
@Riverpod(keepAlive: true)
String? activeUserId(Ref ref) {
  return ref.watch(authSessionProvider).value?.id;
}
