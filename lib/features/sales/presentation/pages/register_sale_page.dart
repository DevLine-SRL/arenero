import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_controller_provider.dart';
import '../providers/register_sale_controller_provider.dart';
import '../widgets/sale_cart_section.dart';
import '../widgets/sale_client_selector.dart';
import '../widgets/sale_delivery_fields.dart';
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

    String step(int adminStep) {
      final number = isAdmin ? adminStep : adminStep - 1;

      return 'Paso $number';
    }

    Widget deliveryAndPayment() {
      return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 620;

          final fields = [
            const SalePaymentSelector(),
            const SaleDiscountField(),
          ];

          final deliveryCard = Material(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [SaleDeliverySelector(), SaleDeliveryFields()],
              ),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < fields.length; index++) ...[
                      if (index > 0) const SizedBox(width: 12),
                      Expanded(child: fields[index]),
                    ],
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < fields.length; index++) ...[
                      if (index > 0) const SizedBox(height: 12),
                      fields[index],
                    ],
                  ],
                ),
              const SizedBox(height: 12),
              deliveryCard,
              const SizedBox(height: 12),
              const SaleNotesField(),
            ],
          );
        },
      );
    }

    final sections = <Widget>[
      _Header(isAdmin: isAdmin),
      _StepSection(
        stepLabel: isAdmin ? 'Paso 1 - Vendedor' : 'Vendedor asignado',
        title: isAdmin ? '¿Quién realiza esta venta?' : 'Venta a tu nombre',
        required: true,
        child: const SaleSellerSelector(),
      ),
      _StepSection(
        stepLabel: '${step(2)} - Cliente',
        title: 'Cliente',
        required: true,
        child: const SaleClientSelector(),
      ),
      _StepSection(
        stepLabel: '${step(3)} - Productos',
        title: 'Productos',
        required: true,
        trailing: TextButton.icon(
          onPressed: addProduct,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Agregar'),
        ),
        child: SaleCartSection(onAddProduct: addProduct),
      ),
      _StepSection(
        stepLabel: '${step(4)} - Pago y entrega',
        title: 'Pago, entrega y descuento',
        required: true,
        child: deliveryAndPayment(),
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

class _Header extends StatelessWidget {
  final bool isAdmin;

  const _Header({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registrar Venta',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${isAdmin ? '4 pasos' : '3 pasos'} para registrar la venta',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StepSection extends StatelessWidget {
  final String stepLabel;
  final String title;
  final bool required;
  final Widget? trailing;
  final Widget child;

  const _StepSection({
    required this.stepLabel,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stepLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
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
                ],
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
