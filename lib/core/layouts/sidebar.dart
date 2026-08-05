import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_definitions.dart';

class Sidebar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const Sidebar({super.key, required this.navigationShell});

  int? _selectedIndex() {
    final index = navigationShell.currentIndex;
    if (index < adminBranchStart) return null;
    return index - adminBranchStart;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationDrawer(
      selectedIndex: _selectedIndex(),
      onDestinationSelected: (index) {
        Navigator.pop(context);
        navigationShell.goBranch(adminBranchStart + index);
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
          icon: Icon(Icons.dashboard_rounded),
          label: Text('Panel'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.groups_rounded),
          label: Text('Gestión de vendedores'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.inventory_2_rounded),
          label: Text('Gestión de productos'),
        ),
      ],
    );
  }
}
