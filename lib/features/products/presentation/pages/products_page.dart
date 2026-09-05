import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../domain/entities/product.dart';
import '../../domain/services/product_duplicate_guard.dart';
import '../providers/products_controller_provider.dart';
import '../providers/products_search_query_provider.dart';
import '../widgets/products_empty_state.dart';
import '../widgets/create_product_dialog.dart';
import '../widgets/edit_product_dialog.dart';
import '../widgets/update_product_price_dialog.dart';
import '../widgets/products_search_field.dart';
import '../widgets/products_table.dart';
import '../widgets/product_status_filter.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  ProductStatusFilter _filter = ProductStatusFilter.active;

  void _onFilterChanged(ProductStatusFilter filter) {
    setState(() => _filter = filter);
  }

  void _showFailure(Failure failure) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(failure.message)));
  }

  Future<void> _setActive(Product product, bool active) async {
    final confirmed = await _confirmActiveChange(product, active);
    if (!confirmed || !mounted) return;

    final failure = await ref
        .read(productsControllerProvider.notifier)
        .setActive(product.id, active);
    if (failure != null && mounted) _showFailure(failure);
  }

  Future<bool> _confirmActiveChange(Product product, bool active) async {
    final action = active ? 'Reactivar' : 'Desactivar';
    final description = active
        ? 'El producto volverá a estar disponible para nuevas ventas.'
        : 'El producto dejará de estar disponible para nuevas ventas. Las ventas existentes no cambiarán.';

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$action producto'),
            content: Text('¿$action "${product.name}"?\n\n$description'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: active
                    ? null
                    : FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _openCreateDialog(List<Product> products) async {
    await CreateProductDialog.show(context, products);
  }

  Future<void> _openEditDialog(Product product, List<Product> products) async {
    await EditProductDialog.show(context, product: product, products: products);
  }

  Future<void> _openUpdatePriceDialog(Product product) async {
    final unit = product.primaryUnit;
    if (unit == null || !product.active || !unit.active) return;
    await UpdateProductPriceDialog.show(context, product: product, unit: unit);
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
                const SizedBox(height: 16),
                Expanded(
                  child: visibleProducts.isEmpty
                      ? ProductsEmptyState(message: emptyMessage)
                      : SingleChildScrollView(
                          child: ProductsTable(
                            products: visibleProducts,
                            onEdit: (product) =>
                                _openEditDialog(product, products),
                            onUpdatePrice: _openUpdatePriceDialog,
                            onActiveChanged: (change) =>
                                _setActive(change.product, change.active),
                          ),
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
