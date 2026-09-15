import 'package:flutter/material.dart';

enum ReportSection {
  summary('Resumen', Icons.insights_rounded),
  client('Cliente', Icons.people_rounded),
  seller('Vendedor', Icons.badge_rounded),
  product('Producto', Icons.inventory_2_rounded);

  const ReportSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Selector de sección del panel, alineado visualmente con los selectores de
/// entidad de registrar venta: [InputDecorator] con outline al 30% y hoja
/// inferior con las opciones.
class ReportsSectionSelector extends StatelessWidget {
  final ReportSection value;
  final ValueChanged<ReportSection> onChanged;

  const ReportsSectionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPicker(context),
      child: InputDecorator(
        isEmpty: false,
        decoration: InputDecoration(
          hintText: 'Seleccionar sección',
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(value.icon, color: theme.colorScheme.primary, size: 22),
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.arrow_drop_down_rounded),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SectionPickerSheet(
        selected: value,
        onSelect: (section) {
          Navigator.of(context).pop();
          onChanged(section);
        },
      ),
    );
  }
}

class _SectionPickerSheet extends StatelessWidget {
  final ReportSection selected;
  final ValueChanged<ReportSection> onSelect;

  const _SectionPickerSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Seleccionar sección'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: ReportSection.values.length,
                itemBuilder: (context, index) {
                  final section = ReportSection.values[index];
                  final isSelected = section == selected;

                  return ListTile(
                    leading: Icon(
                      section.icon,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      section.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => onSelect(section),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
