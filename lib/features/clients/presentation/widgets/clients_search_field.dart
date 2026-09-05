import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clients_search_query_provider.dart';
import 'client_status_filter.dart';

/// Campo de búsqueda con el filtro de estado integrado, mismo patrón que
/// [ProductsSearchField]. El rebote de teclado vive aquí y no en el provider,
/// para que el provider siga siendo puro y fácil de probar.
class ClientsSearchField extends ConsumerStatefulWidget {
  final ClientStatusFilter value;
  final ValueChanged<ClientStatusFilter> onFilterChanged;

  const ClientsSearchField({
    super.key,
    required this.value,
    required this.onFilterChanged,
  });

  static const debounce = Duration(milliseconds: 350);

  @override
  ConsumerState<ClientsSearchField> createState() => _ClientsSearchFieldState();
}

class _ClientsSearchFieldState extends ConsumerState<ClientsSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(ClientsSearchField.debounce, () {
      ref.read(clientsSearchQueryProvider.notifier).onTextChanged(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(clientsSearchQueryProvider.notifier).clear();
  }

  String _labelOf(ClientStatusFilter filter) => switch (filter) {
    ClientStatusFilter.active => 'Activos',
    ClientStatusFilter.inactive => 'Inactivos',
    ClientStatusFilter.all => 'Todos',
  };

  IconData _iconOf(ClientStatusFilter filter) => switch (filter) {
    ClientStatusFilter.active => Icons.check_circle_outline_rounded,
    ClientStatusFilter.inactive => Icons.block_rounded,
    ClientStatusFilter.all => Icons.people_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasText = ref.watch(
      clientsSearchQueryProvider.select((query) => query.text.isNotEmpty),
    );
    final filterActive = widget.value != ClientStatusFilter.all;

    return SizedBox(
      height: 40,
      child: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, cédula o NIT',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 0,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasText)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Limpiar búsqueda',
                  onPressed: _clear,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 0),
                  padding: const EdgeInsets.all(4),
                ),
              PopupMenuButton<ClientStatusFilter>(
                icon: Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: filterActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Filtrar por estado',
                onSelected: widget.onFilterChanged,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 0),
                itemBuilder: (context) => [
                  for (final filter in ClientStatusFilter.values)
                    PopupMenuItem(
                      value: filter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _iconOf(filter),
                            size: 18,
                            color: filter == widget.value
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(_labelOf(filter)),
                          const SizedBox(width: 8),
                          if (filter == widget.value)
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 0,
          ),
        ),
        textInputAction: TextInputAction.search,
        onChanged: _onChanged,
      ),
    );
  }
}
