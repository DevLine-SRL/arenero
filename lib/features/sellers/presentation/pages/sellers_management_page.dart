import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../domain/entities/seller.dart';
import '../providers/sellers_controller_provider.dart';
import '../providers/sellers_selection_provider.dart';
import '../widgets/edit_seller_dialog.dart';
import '../widgets/sellers_actions_bar.dart';
import '../widgets/sellers_empty_state.dart';
import '../widgets/sellers_table.dart';
import '../widgets/sellers_status_filter.dart';
import '../widgets/create_seller_dialog.dart';

class SellersManagementPage extends ConsumerStatefulWidget {
  const SellersManagementPage({super.key});

  @override
  ConsumerState<SellersManagementPage> createState() =>
      _SellersManagementPageState();
}

class _SellersManagementPageState extends ConsumerState<SellersManagementPage> {
  SellerStatusFilter _filter = SellerStatusFilter.active;

  void _onFilterChanged(SellerStatusFilter filter) {
    setState(() => _filter = filter);
    ref.read(sellersSelectionProvider.notifier).clear();
  }

  Future<void> _setActive(bool active) async {
    final selected = ref.read(sellersSelectionProvider);
    if (selected.isEmpty) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: active ? 'Habilitar vendedores' : 'Deshabilitar vendedores',
      content: active
          ? '¿Estás seguro de que deseas habilitar ${selected.length == 1 ? 'el vendedor seleccionado' : 'los ${selected.length} vendedores seleccionados'}?'
          : '¿Estás seguro de que deseas deshabilitar ${selected.length == 1 ? 'el vendedor seleccionado' : 'los ${selected.length} vendedores seleccionados'}?',
      confirmLabel: active ? 'Si, habilitar' : 'si, deshabilitar',
    );
    if (!confirmed) return;

    await ref
        .read(sellersControllerProvider.notifier)
        .setActive(selected, active);
    ref.read(sellersSelectionProvider.notifier).clear();
  }

  Future<void> _editSeller(Seller seller, List<Seller> sellers) async {
    final saved = await EditSellerDialog.show(
      context,
      seller: seller,
      sellers: sellers,
    );

    if (saved != true || !mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Vendedor guardado')));
    ref.invalidate(sellersControllerProvider);
  }

  Future<void> _editSelected(List<Seller> sellers) async {
    final selected = ref.read(sellersSelectionProvider);
    if (selected.length != 1) return;

    final seller = sellers.firstWhere((s) => s.id == selected.first);
    await _editSeller(seller, sellers);
  }

  Future<void> _openCreateDialog() async {
    final created = await CreateSellerDialog.show(context);
    if (created == true) {
      ref.invalidate(sellersControllerProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellersAsync = ref.watch(sellersControllerProvider);
    final selection = ref.watch(sellersSelectionProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: sellersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error is Failure ? error.message : 'Error inesperado.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(sellersControllerProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (sellers) {
            final activeCount = sellers.where((s) => s.active).length;
            final inactiveCount = sellers.length - activeCount;

            final visibleSellers = switch (_filter) {
              SellerStatusFilter.active =>
                sellers.where((s) => s.active).toList(),
              SellerStatusFilter.inactive =>
                sellers.where((s) => !s.active).toList(),
              SellerStatusFilter.all => sellers,
            };

            final emptyMessage = sellers.isEmpty
                ? 'Aún no hay vendedores registrados'
                : switch (_filter) {
                    SellerStatusFilter.active => 'No hay vendedores activos',
                    SellerStatusFilter.inactive =>
                      'No hay vendedores inactivos',
                    SellerStatusFilter.all => 'No hay vendedores',
                  };

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Gestión de Vendedores',
                  description: 'Usuarios registrados en el sistema',
                  icon: Icons.groups_rounded,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SellersStatusFilter(
                        value: _filter,
                        activeCount: activeCount,
                        inactiveCount: inactiveCount,
                        total: sellers.length,
                        onChanged: _onFilterChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _openCreateDialog,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Agregar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SellersActionsBar(
                  filter: _filter,
                  selectedCount: selection.length,
                  onEnable: selection.isEmpty ? null : () => _setActive(true),
                  onDisable: selection.isEmpty ? null : () => _setActive(false),
                  onEdit: () => _editSelected(sellers),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: visibleSellers.isEmpty
                      ? SellersEmptyState(message: emptyMessage)
                      : SellersTable(sellers: visibleSellers),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
