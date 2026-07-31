import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_definitions.dart';

class Sidebar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const Sidebar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onAdminBranch = navigationShell.currentIndex == adminBranchIndex;

    return NavigationDrawer(
      selectedIndex: onAdminBranch ? 0 : -1,
      onDestinationSelected: (index) {
        Navigator.pop(context);
        navigationShell.goBranch(adminBranchIndex);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Text('Arenero', style: theme.textTheme.titleLarge),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Cerrar menú',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
        const NavigationDrawerDestination(
          icon: Icon(Icons.groups_rounded),
          label: Text('Gestión de vendedores'),
        ),
      ],
    );
  }
}
