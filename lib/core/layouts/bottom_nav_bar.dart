import 'package:flutter/material.dart';

const _navBarDestinations = <Widget>[
  NavigationDestination(
    icon: Icon(Icons.receipt_long_rounded),
    label: 'Ventas',
  ),
  NavigationDestination(
    icon: Icon(Icons.point_of_sale_rounded),
    label: 'Registrar Venta',
  ),
  NavigationDestination(icon: Icon(Icons.credit_card_rounded), label: 'Cobros'),
  NavigationDestination(
    icon: Icon(Icons.person_add_rounded),
    label: 'Clientes',
  ),
];

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isAdminBranch;
  final ValueChanged<int> onDestinationSelected;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.isAdminBranch,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = _navBarDestinations;
    final selectedIndex = isAdminBranch
        ? 0
        : currentIndex.clamp(0, destinations.length - 1).toInt();

    final bar = NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
    );

    if (!isAdminBranch) return bar;

    return NavigationBarTheme(data: _noSelectionTheme(context), child: bar);
  }

  NavigationBarThemeData _noSelectionTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBarThemeData(
      indicatorColor: Colors.transparent,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      labelTextStyle: WidgetStatePropertyAll(
        Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
