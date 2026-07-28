import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/router/route_paths.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FloatingActionButton.extended(
          onPressed: () {
            context.goNamed(RouteNames.home);
          },
          icon: const Icon(Icons.login),
          label: const Text('Iniciar Sesión'),
        ),
      ),
    );
  }
}

