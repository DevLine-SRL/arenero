import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/failed_operations_provider.dart';
import '../../core/providers/outbox_sync_provider.dart';

class FailedOperationsBadge extends ConsumerWidget {
  const FailedOperationsBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final count = ref.watch(failedOperationsCountProvider).value ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return Tooltip(
      message: '$count operaciones sin sincronizar. Toca para reintentar.',
      child: IconButton(
        onPressed: () => ref.read(outboxSyncProvider.notifier).retryFailed(),
        tooltip: 'Reintentar sincronización',
        icon: Badge(
          label: Text('$count'),
          backgroundColor: theme.colorScheme.error,
          child: const Icon(Icons.sync_problem_rounded),
        ),
      ),
    );
  }
}
