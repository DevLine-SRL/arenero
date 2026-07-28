import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';

class LoginButton extends StatelessWidget {
  final bool isFormValid;

  const LoginButton({super.key, required this.isFormValid});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isFormValid
        ? () => context.goNamed(RouteNames.home)
        : null,
      icon: const Icon(Icons.login),
      label: const Text('Iniciar Sesión'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
