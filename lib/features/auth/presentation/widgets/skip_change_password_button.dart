import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../providers/auth_providers.dart';

class SkipChangePasswordButton extends ConsumerWidget {
  const SkipChangePasswordButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.read(authSessionProvider).value?.role;
    return Center(
      child: TextButton(
        onPressed: () => context.goNamed(landingRouteNameFor(role)),
        child: const Text('Saltar por ahora'),
      ),
    );
  }
}
