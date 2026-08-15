import 'package:flutter/material.dart';

import '../../core/models/sync_status.dart';

/// Badge que indica que un elemento guardado localmente aún no se
/// sincronizó (pendiente) o falló al sincronizar (error). No dibuja nada
/// cuando el elemento ya está sincronizado.
class LocalSyncStatusBadge extends StatelessWidget {
  final SyncStatus status;

  const LocalSyncStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == SyncStatus.synced) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isError = status == SyncStatus.error;
    final background = isError
        ? colorScheme.errorContainer
        : colorScheme.tertiaryContainer;
    final foreground = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onTertiaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isError ? 'Sin sincronizar' : 'Pendiente',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
