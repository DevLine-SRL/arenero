import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/client.dart';
import '../providers/clients_selection_provider.dart';

class ClientsTable extends ConsumerWidget {
  final List<Client> clients;

  const ClientsTable({super.key, required this.clients});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(clientsSelectionProvider);
    final allIds = clients.map((c) => c.id).toList();
    final allSelected = allIds.isNotEmpty && allIds.every(selection.contains);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final effectiveWidth = availableWidth < _ClientsTableRow.minContentWidth
            ? _ClientsTableRow.minContentWidth
            : availableWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ClientsTableHeader(
                    allSelected: allSelected,
                    onToggleAll: () => ref
                        .read(clientsSelectionProvider.notifier)
                        .toggleAll(allIds),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      itemCount: clients.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.4),
                      ),
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return _ClientsTableRow(
                          client: client,
                          isSelected: selection.contains(client.id),
                          onToggle: () => ref
                              .read(clientsSelectionProvider.notifier)
                              .toggle(client.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClientsTableHeader extends StatelessWidget {
  final bool allSelected;
  final VoidCallback onToggleAll;

  const _ClientsTableHeader({
    required this.allSelected,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onToggleAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: _ClientsTableRow.checkboxColumnWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Checkbox(
                  value: allSelected,
                  onChanged: (_) => onToggleAll(),
                ),
              ),
            ),
            const SizedBox(width: _ClientsTableRow.checkboxGap),
            Expanded(
              child: Text(
                'Cliente',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: _ClientsTableRow.columnGap),
            SizedBox(
              width: _ClientsTableRow.statusDotWidth,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Estado',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientsTableRow extends StatelessWidget {
  static const checkboxColumnWidth = 20.0;
  static const statusDotWidth = 44.0;
  static const columnGap = 8.0;
  static const horizontalPadding = 16.0;
  static const checkboxGap = 16.0;

  static const minContentWidth =
      checkboxColumnWidth +
      checkboxGap +
      columnGap +
      statusDotWidth +
      columnGap +
      horizontalPadding;

  final Client client;
  final bool isSelected;
  final VoidCallback onToggle;

  const _ClientsTableRow({
    required this.client,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onToggle,
      hoverColor: AppColors.primaryContainer.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: checkboxColumnWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                ),
              ),
            ),
            const SizedBox(width: checkboxGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (client.ci.isNotEmpty)
                    Text(
                      _clientIdLine(client),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (client.phone != null && client.phone!.isNotEmpty)
                    Text(
                      client.phone!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'Número no registrado',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: columnGap),
            SizedBox(
              width: statusDotWidth,
              child: Align(
                alignment: Alignment.center,
                child: _StatusDot(active: client.active),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _clientIdLine(Client client) {
    final buffer = StringBuffer('CI ${client.ci}');
    if (client.nit != null && client.nit!.isNotEmpty) {
      buffer.write(' · NIT ${client.nit}');
    }
    return buffer.toString();
  }
}

class _StatusDot extends StatelessWidget {
  final bool active;

  const _StatusDot({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.error;

    return Tooltip(
      message: active ? 'Activo' : 'Inactivo',
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
