import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/services/product_duplicate_guard.dart';
import '../providers/products_controller_provider.dart';
import '../widgets/products_empty_state.dart';
import '../widgets/create_product_dialog.dart';
import '../widgets/edit_product_dialog.dart';
import '../widgets/update_product_price_dialog.dart';
import '../widgets/products_table.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  String _query = '';

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
            final activeCount = products
                .where((product) => product.active)
                .length;
            final visibleProducts = _filterProducts(products);

            final emptyMessage = products.isEmpty
                ? 'Aun no hay productos registrados'
                : visibleProducts.isEmpty && _query.trim().isNotEmpty
                ? 'No se encontraron productos para esa busqueda'
                : 'No hay productos';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Productos',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$activeCount activo${activeCount == 1 ? '' : 's'}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: const Color(0xFF7D5A3C)),
                          ),
                        ],
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
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 375,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar en productos...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF3E8D6),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(
                            color: Color(0xFFD7C7AE),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(
                            color: Color(0xFF7B4318),
                          ),
                        ),
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
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

  List<Product> _filterProducts(List<Product> products) {
    final normalizedQuery = normalizeProductName(_query);

    return products.where((product) {
      if (normalizedQuery.isEmpty) return true;
      return normalizeProductName(product.name).contains(normalizedQuery);
    }).toList();
  }
}
