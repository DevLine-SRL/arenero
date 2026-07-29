import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/sales/presentation/pages/register_sale_page.dart';
import '../../features/sales/presentation/pages/sales_history_page.dart';
import '../layouts/main_layout.dart';
import 'route_paths.dart';

final publicRoutes = <RouteBase>[
  GoRoute(
    path: RoutePaths.login,
    name: RouteNames.login,
    builder: (context, state) => const LoginPage(),
  ),
];

final protectedRoutes = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      MainLayout(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RoutePaths.dashboard,
          name: RouteNames.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RoutePaths.registerSale,
          name: RouteNames.registerSale,
          builder: (context, state) => const RegisterSalePage(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RoutePaths.salesHistory,
          name: RouteNames.salesHistory,
          builder: (context, state) => const SalesHistoryPage(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RoutePaths.products,
          name: RouteNames.products,
          builder: (context, state) => const ProductsPage(),
        ),
      ],
    ),
  ],
);

final routes = <RouteBase>[
  ...publicRoutes,
  protectedRoutes,
];
