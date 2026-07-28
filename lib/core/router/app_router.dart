import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/widgets/not_found_page.dart';
import 'route_definitions.dart';
import 'route_paths.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.login,
    routes: routes,
    errorBuilder: (BuildContext context, GoRouterState state) => const NotFoundPage(),
  );
}
