import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/sale.dart';
import '../providers/sale_detail_provider.dart';
import '../widgets/sale_detail_delivery_card.dart';
import '../widgets/sale_detail_header.dart';
import '../widgets/sale_detail_line_item.dart';
import '../widgets/sale_detail_notes.dart';
import '../widgets/sale_detail_top_bar.dart';
import '../widgets/sale_detail_totals.dart';
import '../widgets/sale_section_card.dart';

class SaleDetailPage extends ConsumerWidget {
  final String saleId;

  const SaleDetailPage({super.key, required this.saleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleDetailProvider(saleId));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: saleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: error is Failure
                ? error.message
                : 'Error inesperado al cargar el detalle de la venta.',
            onRetry: () => ref.invalidate(saleDetailProvider(saleId)),
          ),
          data: (sale) => _Content(sale: sale),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Sale sale;

  const _Content({required this.sale});

  @override
  Widget build(BuildContext context) {
    final notes = sale.notes;
    final hasNotes = notes != null && notes.trim().isNotEmpty;
    // Una venta con retiro en tienda también puede traer placa o fecha, así
    // que la tarjeta se muestra si hay algo que mostrar.
    final isDelivery =
        sale.deliveryMode == SaleDeliveryMode.companyDelivery ||
        sale.delivery != null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SaleDetailTopBar(sale: sale),
        const SizedBox(height: 16),
        SaleDetailHeader(sale: sale),
        const SizedBox(height: 12),
        SaleSectionCard(
          title: 'Productos',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final detail in sale.details)
                SaleDetailLineItem(detail: detail),
              const Divider(height: 24),
              SaleDetailTotals(sale: sale),
            ],
          ),
        ),
        if (isDelivery) ...[
          const SizedBox(height: 12),
          SaleDetailDeliveryCard(sale: sale),
        ],
        if (hasNotes) ...[
          const SizedBox(height: 12),
          SaleDetailNotes(notes: notes),
        ],
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
