import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';

class SkipChangePasswordButton extends StatelessWidget {
  const SkipChangePasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.go(RoutePaths.home),
        child: const Text('Saltar por ahora'),
      ),
    );
  }
}
