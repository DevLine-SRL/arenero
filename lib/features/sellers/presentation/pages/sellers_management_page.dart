import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/sellers_controller_provider.dart';
import '../widgets/active_accounts_badge.dart';
import '../widgets/seller_list_item.dart';
import '../widgets/sellers_actions_bar.dart';
import '../widgets/sellers_empty_state.dart';
import '../widgets/sellers_header.dart';

class SellersManagementPage extends ConsumerStatefulWidget {
  const SellersManagementPage({super.key});

  @override
  ConsumerState<SellersManagementPage> createState() => _SellersManagementPageState();
}

class _SellersManagementPageState extends ConsumerState<SellersManagementPage> {
  final Set<String> _selected = {};

  void _toggleSelected(String id, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
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

    await ref.read(sellersControllerProvider.notifier).setActive(_selected, active);
    setState(_selected.clear);
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
          data: (sellers) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SellersHeader(),
              const SizedBox(height: 12),
              ActiveAccountsBadge(
                activeCount: sellers.where((s) => s.active).length,
                total: sellers.length,
              ),
              const SizedBox(height: 16),
              SellersActionsBar(
                selectedCount: _selected.length,
                onEnable: _selected.isEmpty ? null : () => _setActive(true),
                onDisable: _selected.isEmpty ? null : () => _setActive(false),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: sellers.isEmpty
                  ? const SellersEmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: sellers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final seller = sellers[index];
                        return SellerListItem(
                          seller: seller,
                          isSelected: _selected.contains(seller.id),
                          onToggle: (selected) => _toggleSelected(seller.id, selected),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
