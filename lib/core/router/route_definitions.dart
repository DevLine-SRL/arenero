import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/clients/presentation/pages/clients_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/sales/presentation/pages/register_sale_page.dart';
import '../../features/sellers/presentation/pages/sellers_management_page.dart';
import '../../shared/widgets/forbidden_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../layouts/main_layout.dart';
import 'route_paths.dart';

const adminBranchIndex = 4;

final adminOnlyRoutes = <String>[RoutePaths.sellersManagement];

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
          path: RoutePaths.clients,
          name: RouteNames.clients,
          builder: (context, state) => const ClientsPage(),
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
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RoutePaths.sellersManagement,
          name: RouteNames.sellersManagement,
          builder: (context, state) => const SellersManagementPage(),
        ),
      ],
    ),
  ],
);

final routes = <RouteBase>[
  ...publicRoutes,
  GoRoute(
    path: RoutePaths.forbidden,
    name: RouteNames.forbidden,
    builder: (context, state) => const ForbiddenPage(),
  ),
  protectedRoutes,
];

final publicRoutes = <RouteBase>[
  GoRoute(
    path: RoutePaths.login,
    name: RouteNames.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute( 
    path: RoutePaths.resetPassword,
    name: RouteNames.resetPassword,
    builder: (context, state) => const ResetPasswordPage(),
  ),
];
