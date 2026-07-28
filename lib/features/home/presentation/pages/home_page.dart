import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../.../../../../core/router/route_paths.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arenero Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              context.goNamed(RouteNames.login);
            },
            tooltip: 'Cerrar Sesión',
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }
}
