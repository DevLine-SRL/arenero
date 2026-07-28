import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authSessionProvider);
    final user = auth.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arenero Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(logoutUseCaseProvider)();
            },
            tooltip: 'Cerrar Sesión',
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(child: Text(user?.email ?? '')),
    );
  }
}
