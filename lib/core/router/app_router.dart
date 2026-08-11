import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../shared/widgets/not_found_page.dart';
import '../providers/supabase_client_provider.dart';
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
      final user = authState.value;
      final hasActiveSession =
          ref.read(supabaseClientProvider).auth.currentSession != null;
      final isLoggedIn = user != null || hasActiveSession;
      final isPublicRoute =
          state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.forgotPassword;
      final isLoggingIn = state.matchedLocation == RoutePaths.login;

      if (!isLoggedIn && !isPublicRoute) return RoutePaths.login;
      if (isLoggedIn && isLoggingIn) {
        return user?.role == 'admin'
            ? RoutePaths.dashboard
            : RoutePaths.salesHistory;
      }

      final isAdminRoute = adminOnlyRoutes.contains(state.matchedLocation);
      if (isLoggedIn && isAdminRoute && user?.role != 'admin') {
        return RoutePaths.forbidden;
      }
      return null;
    },
    routes: routes,
    errorBuilder: (BuildContext context, GoRouterState state) =>
        const NotFoundPage(),
  );
}
