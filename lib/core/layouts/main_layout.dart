import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/logout_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/connection_status_indicator.dart';
import '../../shared/widgets/failed_operations_badge.dart';
import '../providers/sync_local_datasource_provider.dart';
import '../router/route_definitions.dart';
import 'bottom_nav_bar.dart';
import 'sidebar.dart';

class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final sync = ref.read(syncLocalDataSourceProvider);
    final pending = await sync.countPending();
    final failed = (await sync.getFailedOperations()).length;
    final unsynced = pending + failed;

    final content = unsynced == 0
        ? '¿Estás seguro de que deseas cerrar sesión?'
        : '¿Estás seguro de que deseas cerrar sesión?\n\n'
              'Tienes $unsynced operaciones sin sincronizar. Se conservarán '
              'localmente y se sincronizarán cuando vuelvas a entrar.';

    if (!context.mounted) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Cerrar sesión',
      content: content,
      confirmLabel: 'Si, cerrar sesión',
    );

    if (confirmed) {
      ref.read(logoutProvider.notifier)();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouter.of(context).state.uri.path;
    final title = branchTitles[path] ?? 'Arenero';

    final currentIndex = navigationShell.currentIndex;
    final isAdminBranch = currentIndex >= adminBranchStart;
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
          const FailedOperationsBadge(),
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
