import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/clients/presentation/pages/clients_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/sales/presentation/pages/register_sale_page.dart';
import '../../features/sales/presentation/pages/sale_detail_page.dart';
import '../../features/sales/presentation/pages/sales_history_page.dart';
import '../../features/sellers/presentation/pages/sellers_management_page.dart';
import '../../shared/widgets/forbidden_page.dart';
import '../layouts/main_layout.dart';
import 'route_paths.dart';

const adminBranchStart = 3;

const branchTitles = <String, String>{
  RoutePaths.salesHistory: 'Ventas',
  RoutePaths.registerSale: 'Registrar Venta',
  RoutePaths.clients: 'Clientes',
  RoutePaths.dashboard: 'Panel',
  RoutePaths.sellersManagement: 'Gestión de Vendedores',
  RoutePaths.products: 'Gestión de Productos',
};

const adminOnlyRoutes = <String>[
  RoutePaths.dashboard,
  RoutePaths.products,
  RoutePaths.sellersManagement,
];

final publicRoutes = <RouteBase>[
  GoRoute(
    path: RoutePaths.login,
    name: RouteNames.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: RoutePaths.forgotPassword,
    name: RouteNames.forgotPassword,
    builder: (context, state) => const ForgotPasswordPage(),
  ),
];

final protectedRoutes = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      MainLayout(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RoutePaths.salesHistory,
          name: RouteNames.salesHistory,
          builder: (context, state) => const SalesHistoryPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: RouteNames.saleDetail,
              builder: (context, state) =>
                  SaleDetailPage(saleId: state.pathParameters['id']!),
            ),
          ],
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
          path: RoutePaths.dashboard,
          name: RouteNames.dashboard,
          builder: (context, state) => const DashboardPage(),
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
  GoRoute(
    path: RoutePaths.changePassword,
    name: RouteNames.changePassword,
    builder: (context, state) => const ChangePasswordPage(),
  ),
  GoRoute(
    path: RoutePaths.forbidden,
    name: RouteNames.forbidden,
    builder: (context, state) => const ForbiddenPage(),
  ),
  protectedRoutes,
];
