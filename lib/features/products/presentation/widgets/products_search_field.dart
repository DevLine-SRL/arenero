import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/products_search_query_provider.dart';
import 'product_status_filter.dart';

class ProductsSearchField extends ConsumerStatefulWidget {
  final ProductStatusFilter value;
  final int activeCount;
  final int inactiveCount;
  final int total;
  final ValueChanged<ProductStatusFilter> onFilterChanged;

  const ProductsSearchField({
    super.key,
    required this.value,
    required this.activeCount,
    required this.inactiveCount,
    required this.total,
    required this.onFilterChanged,
  });

  static const debounce = Duration(milliseconds: 350);

  @override
  ConsumerState<ProductsSearchField> createState() =>
      _ProductsSearchFieldState();
}

class _ProductsSearchFieldState extends ConsumerState<ProductsSearchField> {
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
    _debounce = Timer(ProductsSearchField.debounce, () {
      ref.read(productsSearchQueryProvider.notifier).onTextChanged(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(productsSearchQueryProvider.notifier).clear();
  }

  String _labelOf(ProductStatusFilter filter) => switch (filter) {
    ProductStatusFilter.active => 'Activos (${widget.activeCount})',
    ProductStatusFilter.inactive => 'Inactivos (${widget.inactiveCount})',
    ProductStatusFilter.all => 'Todos (${widget.total})',
  };

  IconData _iconOf(ProductStatusFilter filter) => switch (filter) {
    ProductStatusFilter.active => Icons.check_circle_outline_rounded,
    ProductStatusFilter.inactive => Icons.block_rounded,
    ProductStatusFilter.all => Icons.people_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasText = ref.watch(
      productsSearchQueryProvider.select((query) => query.isNotEmpty),
    );
    final filterActive = widget.value != ProductStatusFilter.all;

    return SizedBox(
      height: 40,
      child: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar en productos...',
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
              PopupMenuButton<ProductStatusFilter>(
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
                  for (final filter in ProductStatusFilter.values)
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
