import 'package:flutter/material.dart';

import '../../../reports/domain/entities/report_suggestion.dart';

/// Selector de entidad del panel, mismo patrón que
/// [SaleClientSelector]: un [InputDecorator] con outline al 30% que, al
/// pulsarse, abre un [DraggableScrollableSheet] con búsqueda y lista de
/// resultados.
class ReportsEntityPicker extends StatelessWidget {
  final ReportSuggestion? selected;
  final Future<List<ReportSuggestion>> Function(String query) search;
  final IconData icon;
  final String hintText;
  final ValueChanged<ReportSuggestion> onSelected;
  final VoidCallback onCleared;

  const ReportsEntityPicker({
    super.key,
    required this.selected,
    required this.search,
    required this.icon,
    required this.hintText,
    required this.onSelected,
    required this.onCleared,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPicker(context),
      child: InputDecorator(
        isEmpty: selected == null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          prefixIcon: selected != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(icon),
                ),
          suffixIcon: selected != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Quitar selección',
                    onPressed: onCleared,
                  ),
                )
              : const Padding(
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
        child: selected != null
            ? Text(
                selected!.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PickerSheet(
        selected: selected,
        icon: icon,
        search: search,
        onSelected: (entity) {
          Navigator.of(context).pop();
          onSelected(entity);
        },
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  final ReportSuggestion? selected;
  final IconData icon;
  final Future<List<ReportSuggestion>> Function(String query) search;
  final ValueChanged<ReportSuggestion> onSelected;

  const _PickerSheet({
    required this.selected,
    required this.icon,
    required this.search,
    required this.onSelected,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  final _controller = TextEditingController();
  String _query = '';
  bool _loading = false;
  List<ReportSuggestion> _results = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _doSearch('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _doSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await widget.search(query.trim());
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los datos.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
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
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                            _doSearch('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _query = value);
                  _doSearch(value);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        )
                      : _results.isEmpty
                          ? Center(
                              child: Text(
                                _query.isEmpty
                                    ? 'Sin resultados'
                                    : 'No se encontraron resultados',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final item = _results[index];
                                final isSelected =
                                    item.id == widget.selected?.id;

                                return ListTile(
                                  leading: Icon(
                                    widget.icon,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  title: Text(
                                    item.name,
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
                                  selectedTileColor: theme
                                      .colorScheme.primaryContainer
                                      .withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onTap: () => widget.onSelected(item),
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
