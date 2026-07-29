import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../shared/widgets/not_found_page.dart';
import 'route_definitions.dart';
import 'route_paths.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(authSessionProvider, (previous, next) {
    refreshNotifier.value++;
  });

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RoutePaths.login,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authSessionProvider);
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == RoutePaths.login;

      if (!isLoggedIn && !isLoggingIn) return RoutePaths.login;
      if (isLoggedIn && isLoggingIn) return RoutePaths.dashboard;
      return null;
    },
    routes: routes,
    errorBuilder: (BuildContext context, GoRouterState state) => const NotFoundPage(),
  );
}
