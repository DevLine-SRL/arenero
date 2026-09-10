import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/page_header.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_controller_provider.dart';
import '../providers/register_sale_controller_provider.dart';
import '../widgets/sale_cart_section.dart';
import '../widgets/sale_client_selector.dart';
import '../widgets/sale_delivery_selector.dart';
import '../widgets/sale_discount_field.dart';
import '../widgets/sale_notes_field.dart';
import '../widgets/sale_order_summary.dart';
import '../widgets/sale_payment_collection_step.dart';
import '../widgets/sale_payment_selector.dart';
import '../widgets/sale_seller_selector.dart';

class RegisterSalePage extends ConsumerWidget {
  const RegisterSalePage({super.key});

  bool _hasProductWithAvailableUnit(
    Product product,
    Map<String, Set<ProductUnitOfMeasure>> usedUnitsByProduct,
  ) {
    if (!product.active) {
      return false;
    }

    final used =
        usedUnitsByProduct[product.id] ?? const <ProductUnitOfMeasure>{};

    return product.units.any(
      (unit) => unit.active && !used.contains(unit.unit),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).value;
    final registeredSale = ref.watch(
      registerSaleControllerProvider.select((state) => state.registeredSale),
    );

    if (registeredSale != null) {
      return const SalePaymentCollectionStep();
    }

    final isAdmin = user?.role == 'admin';

    final items = ref.watch(
      registerSaleControllerProvider.select((state) => state.items),
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

    final addProduct = canAddProduct
        ? () => ref.read(registerSaleControllerProvider.notifier).addLine()
        : null;

    final sections = <Widget>[
      const PageHeader(
        title: 'Registrar Venta',
        description: 'Registro y cobro de nuevas ventas',
        icon: Icons.point_of_sale_rounded,
      ),
      _StepSection(
        title: isAdmin ? 'Selecciona el vendedor' : 'Venta a tu nombre',
        required: true,
        child: const SaleSellerSelector(),
      ),
      _StepSection(
        title: 'Selecciona el cliente',
        required: true,
        child: const SaleClientSelector(),
      ),
      _StepSection(
        title: 'Agrega los productos',
        required: true,
        trailing: FilledButton.icon(
          onPressed: addProduct,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Agregar'),
        ),
        child: SaleCartSection(onAddProduct: addProduct),
      ),
      _StepSection(
        title: 'Selecciona el tipo de pago',
        required: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 3, child: SalePaymentSelector()),
            const SizedBox(width: 12),
            const Expanded(flex: 2, child: SaleDiscountField()),
          ],
        ),
      ),
      _StepSection(
        title: 'Modalidad de entrega',
        child: const SaleDeliverySelector(),
      ),
      _StepSection(
        title: 'Notas',
        child: const SaleNotesField(),
      ),
      const SaleOrderSummary(),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 24,
              children: sections,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepSection extends StatelessWidget {
  final String title;
  final bool required;
  final Widget? trailing;
  final Widget child;

  const _StepSection({
    required this.title,
    this.required = false,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: title,
                  children: [
                    if (required)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                  ],
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
