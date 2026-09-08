import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../domain/entities/product.dart';
import '../../domain/services/product_duplicate_guard.dart';
import '../providers/products_controller_provider.dart';
import '../providers/products_search_query_provider.dart';
import '../widgets/products_empty_state.dart';
import '../widgets/create_product_dialog.dart';
import '../widgets/edit_product_dialog.dart';
import '../widgets/products_actions_bar.dart';
import '../widgets/products_search_field.dart';
import '../widgets/products_table.dart';
import '../widgets/product_status_filter.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final Set<String> _selected = {};
  ProductStatusFilter _filter = ProductStatusFilter.active;

  void _toggleSelected(String id, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }

  void _onFilterChanged(ProductStatusFilter filter) {
    setState(() {
      _filter = filter;
      _selected.clear();
    });
  }

  Future<void> _setActive(bool active) async {
    if (_selected.isEmpty) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: active ? 'Habilitar productos' : 'Deshabilitar productos',
      content: active
          ? '¿Estás seguro de que deseas habilitar ${_selected.length == 1 ? 'el producto seleccionado' : 'los ${_selected.length} productos seleccionados'}?'
          : '¿Estás seguro de que deseas deshabilitar ${_selected.length == 1 ? 'el producto seleccionado' : 'los ${_selected.length} productos seleccionados'}?',
      confirmLabel: active ? 'Si, habilitar' : 'Si, deshabilitar',
    );
    if (!confirmed) return;

    await ref
        .read(productsControllerProvider.notifier)
        .setActiveBatch(_selected, active);
    setState(_selected.clear);
  }

  Future<void> _openCreateDialog(List<Product> products) async {
    final created = await CreateProductDialog.show(context, products);
    if (created == true) {
      ref.invalidate(productsControllerProvider);
    }
  }

  Future<void> _openEditDialog(Product product, List<Product> products) async {
    final saved = await EditProductDialog.show(
      context,
      product: product,
      products: products,
    );

    if (saved != true || !mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Producto guardado')));
    ref.invalidate(productsControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error is Failure ? error.message : 'Error inesperado.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(productsControllerProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (products) {
            final activeCount = products.where((p) => p.active).length;
            final inactiveCount = products.length - activeCount;

            final query = ref.watch(productsSearchQueryProvider);
            final visibleProducts = _filterProducts(products, query);

            final emptyMessage = products.isEmpty
                ? 'Aun no hay productos registrados'
                : visibleProducts.isEmpty && query.trim().isNotEmpty
                ? 'No se encontraron productos para esa busqueda'
                : switch (_filter) {
                    ProductStatusFilter.active => 'No hay productos activos',
                    ProductStatusFilter.inactive =>
                      'No hay productos inactivos',
                    ProductStatusFilter.all => 'No hay productos',
                  };

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHeader(
                  title: 'Gestión de Productos',
                  description: 'Materiales e insumos disponibles',
                  icon: Icons.inventory_2_rounded,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ProductsSearchField(
                        value: _filter,
                        activeCount: activeCount,
                        inactiveCount: inactiveCount,
                        total: products.length,
                        onFilterChanged: _onFilterChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => _openCreateDialog(products),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Nuevo'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProductsActionsBar(
                  filter: _filter,
                  selectedCount: _selected.length,
                  onEnable: _selected.isEmpty ? null : () => _setActive(true),
                  onDisable: _selected.isEmpty ? null : () => _setActive(false),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: visibleProducts.isEmpty
                      ? ProductsEmptyState(message: emptyMessage)
                      : ProductsTable(
                          products: visibleProducts,
                          selectedIds: _selected,
                          onToggle: _toggleSelected,
                          onEdit: (product) =>
                              _openEditDialog(product, products),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products, String query) {
    final normalizedQuery = normalizeProductName(query);

    return products.where((product) {
      final matchesFilter = switch (_filter) {
        ProductStatusFilter.active => product.active,
        ProductStatusFilter.inactive => !product.active,
        ProductStatusFilter.all => true,
      };
      if (!matchesFilter) return false;

      if (normalizedQuery.isEmpty) return true;
      return normalizeProductName(product.name).contains(normalizedQuery);
    }).toList();
  }
}
