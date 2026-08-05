import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_timeout_provider.dart';

class ActivityListener extends ConsumerWidget {
  final Widget child;

  const ActivityListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(sessionTimeoutControllerProvider.notifier);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => controller.onActivity(),
      onPointerMove: (_) => controller.onActivity(),
      onPointerHover: (_) => controller.onActivity(),
      onPointerUp: (_) => controller.onActivity(),
      child: child,
    );
  }
}
