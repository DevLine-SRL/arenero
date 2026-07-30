import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../shared/widgets/confirm_dialog.dart';

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
      ref.read(logoutUseCaseProvider)();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const titles = [
      'Panel',
      'Registrar Venta',
      'Historial de Ventas',
      'Productos',
    ];

    final title = titles[navigationShell.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context, ref),
            tooltip: 'Cerrar Sesión',
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_rounded),
            label: 'Registrar Venta',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Productos',
          ),
        ],
      ),
    );
  }
}
