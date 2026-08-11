import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_paths.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class ForbiddenPage extends ConsumerWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.read(authSessionProvider).value?.role;
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
              onPressed: () => context.goNamed(landingRouteNameFor(role)),
              child: const Text('Ir al panel'),
            ),
          ],
        ),
      ),
    );
  }
}
