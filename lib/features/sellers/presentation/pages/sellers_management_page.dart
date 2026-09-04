import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../domain/entities/seller.dart';
import '../providers/sellers_controller_provider.dart';
import '../widgets/edit_seller_dialog.dart';
import '../widgets/seller_list_item.dart';
import '../widgets/sellers_actions_bar.dart';
import '../widgets/sellers_empty_state.dart';
import '../widgets/sellers_status_filter.dart';
import '../widgets/create_seller_dialog.dart';

class SellersManagementPage extends ConsumerStatefulWidget {
  const SellersManagementPage({super.key});

  @override
  ConsumerState<SellersManagementPage> createState() =>
      _SellersManagementPageState();
}

class _SellersManagementPageState extends ConsumerState<SellersManagementPage> {
  final Set<String> _selected = {};
  SellerStatusFilter _filter = SellerStatusFilter.active;

  void _toggleSelected(String id, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }

  void _onFilterChanged(SellerStatusFilter filter) {
    setState(() {
      _filter = filter;
      _selected.clear();
    });
  }

  Future<void> _setActive(bool active) async {
    if (_selected.isEmpty) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: active ? 'Habilitar vendedores' : 'Deshabilitar vendedores',
      content: active
          ? '¿Estás seguro de que deseas habilitar ${_selected.length == 1 ? 'el vendedor seleccionado' : 'los ${_selected.length} vendedores seleccionados'}?'
          : '¿Estás seguro de que deseas deshabilitar ${_selected.length == 1 ? 'el vendedor seleccionado' : 'los ${_selected.length} vendedores seleccionados'}?',
      confirmLabel: active ? 'Si, habilitar' : 'si, deshabilitar',
    );
    if (!confirmed) return;

    await ref
        .read(sellersControllerProvider.notifier)
        .setActive(_selected, active);
    setState(_selected.clear);
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
      ..showSnackBar(
        const SnackBar(content: Text('Vendedor guardado')),
      );
    ref.invalidate(sellersControllerProvider);
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
                  selectedCount: _selected.length,
                  onEnable: _selected.isEmpty ? null : () => _setActive(true),
                  onDisable: _selected.isEmpty ? null : () => _setActive(false),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: visibleSellers.isEmpty
                      ? SellersEmptyState(message: emptyMessage)
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: visibleSellers.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final seller = visibleSellers[index];
                            return SellerListItem(
                              seller: seller,
                              isSelected: _selected.contains(seller.id),
                              onToggle: (selected) =>
                                  _toggleSelected(seller.id, selected),
                              onEdit: () => _editSeller(seller, sellers),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
