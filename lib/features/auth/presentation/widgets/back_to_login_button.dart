import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';

class BackToLoginButton extends StatelessWidget {
  const BackToLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => context.goNamed(RouteNames.login),
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Volver al inicio de sesión'),
      ),
    );
  }
}
