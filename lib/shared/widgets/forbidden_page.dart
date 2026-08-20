import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_paths.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    return Scaffold(
      appBar: AppBar(title: const Text('403')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.errorContainer,
            ),
            const SizedBox(height: 16),
            const Text('Acceso denegado'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (from != null && from.isNotEmpty) {
                  context.go(from);
                } else if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.home);
                }
              },
              child: const Text('Volver atrás'),
            ),
          ],
        ),
      ),
    );
  }
}