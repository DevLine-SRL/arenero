import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/logout_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/connection_status_indicator.dart';
import '../router/route_definitions.dart';
import 'bottom_nav_bar.dart';
import 'sidebar.dart';

class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Cerrar sesión',
      content: '¿Estás seguro de que deseas cerrar sesión?',
      confirmLabel: 'Si, cerrar sesión',
    );

    if (confirmed) {
      ref.read(logoutProvider.notifier)();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const titles = [
      'Panel',
      'Registrar Venta',
      'Clientes',
      'Productos',
      'Gestión de Vendedores',
    ];

    final currentIndex = navigationShell.currentIndex;
    final title = titles[currentIndex];
    final isAdminBranch = currentIndex >= adminBranchIndex;
    final isAdmin = ref.watch(authSessionProvider).value?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        leading: isAdmin
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Menú',
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
        title: Text(title),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: ConnectionStatusIndicator()),
          ),
          IconButton(
            onPressed: () => _confirmLogout(context, ref),
            tooltip: 'Cerrar Sesión',
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      drawer: isAdmin ? Sidebar(navigationShell: navigationShell) : null,
      body: navigationShell,
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: currentIndex,
        isAdminBranch: isAdminBranch,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
      ),
    );
  }
}
