import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/client.dart';

class ClientsTable extends StatelessWidget {
  final List<Client> clients;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onToggle;
  final ValueChanged<Client> onEdit;

  const ClientsTable({
    super.key,
    required this.clients,
    required this.selectedIds,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
                    isSelected: selectedIds.contains(client.id),
                    onToggle: (selected) => onToggle(client.id, selected),
                    onEdit: () => onEdit(client),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClientsTableRow extends StatelessWidget {
  static const checkboxColumnWidth = 20.0;
  static const statusDotWidth = 28.0;
  static const actionsColumnWidth = 40.0;
  static const columnGap = 8.0;
  static const horizontalPadding = 16.0;
  static const checkboxGap = 16.0;

  static const minContentWidth =
      checkboxColumnWidth +
      checkboxGap +
      columnGap +
      statusDotWidth +
      columnGap +
      actionsColumnWidth +
      horizontalPadding;

  final Client client;
  final bool isSelected;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _ClientsTableRow({
    required this.client,
    required this.isSelected,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onToggle(!isSelected),
      hoverColor: AppColors.primaryContainer.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: checkboxColumnWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) => onToggle(value ?? false),
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
            _StatusDot(active: client.active),
            const SizedBox(width: columnGap),
            _CompactEditButton(onPressed: onEdit, tooltip: 'Editar cliente'),
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

class _CompactEditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const _CompactEditButton({required this.onPressed, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.edit_outlined, size: 20),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      splashRadius: 20,
    );
  }
}
