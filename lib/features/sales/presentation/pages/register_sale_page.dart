import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_controller_provider.dart';
import '../widgets/sale_cart_section.dart';
import '../widgets/sale_client_selector.dart';
import '../widgets/sale_delivery_fields.dart';
import '../widgets/sale_delivery_selector.dart';
import '../widgets/sale_notes_field.dart';
import '../providers/register_sale_controller_provider.dart';
import '../widgets/sale_order_summary.dart';
import '../widgets/sale_payment_selector.dart';
import '../widgets/sale_section_card.dart';

class RegisterSalePage extends ConsumerWidget {
  const RegisterSalePage({super.key});

  bool _hasProductWithAvailableUnit(
    Product product,
    Map<String, Set<ProductUnitOfMeasure>> usedUnitsByProduct,
  ) {
    if (!product.active) return false;

    final used =
        usedUnitsByProduct[product.id] ?? const <ProductUnitOfMeasure>{};
    return product.units.any(
      (unit) => unit.active && !used.contains(unit.unit),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(
      registerSaleControllerProvider.select((s) => s.items),
    );
    final products =
        ref.watch(productsControllerProvider).value ?? const <Product>[];

    final usedUnitsByProduct = <String, Set<ProductUnitOfMeasure>>{};
    for (final item in items) {
      if (item.isComplete && item.productId != null && item.unit != null) {
        usedUnitsByProduct
            .putIfAbsent(item.productId!, () => {})
            .add(item.unit!);
      }
    }

    final allItemsComplete = items.every((item) => item.isComplete);
    final hasProductsToAdd = products.any(
      (product) => _hasProductWithAvailableUnit(product, usedUnitsByProduct),
    );
    final canAddProduct = allItemsComplete && hasProductsToAdd;

    return SafeArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                'Registrar venta',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SaleSectionCard(
                title: 'Cliente',
                required: true,
                child: SaleClientSelector(),
              ),
              SaleSectionCard(
                title: 'Productos',
                required: true,
                trailing: FilledButton.icon(
                  onPressed: canAddProduct
                      ? () => ref
                            .read(registerSaleControllerProvider.notifier)
                            .addLine()
                      : null,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Agregar producto'),
                ),
                child: const SaleCartSection(),
              ),
              SaleSectionCard(
                title: 'Entrega y pago',
                required: true,
                child: Padding(
                  padding: EdgeInsetsGeometry.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: SaleDeliverySelector()),
                          SizedBox(width: 12),
                          Expanded(child: SalePaymentSelector()),
                        ],
                      ),
                      const SaleDeliveryFields(),
                    ],
                  ),
                ),
              ),
              const SaleSectionCard(title: 'Notas', child: SaleNotesField()),
              Material(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: const SaleOrderSummary(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
