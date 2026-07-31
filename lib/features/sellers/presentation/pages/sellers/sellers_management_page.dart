import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sellers_providers.dart';
import '../../widgets/active_accounts_badge.dart';
import '../../widgets/seller_list_item.dart';
import '../../widgets/sellers_actions_bar.dart';
import '../../widgets/sellers_empty_state.dart';
import '../../widgets/sellers_header.dart';

class SellersManagementPage extends ConsumerStatefulWidget {
  const SellersManagementPage({super.key});

  @override
  ConsumerState<SellersManagementPage> createState() =>
      _SellersManagementPageState();
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

  void _setActive(bool active) {
    if (_selected.isEmpty) return;

    ref.read(sellersControllerProvider.notifier).setActive(_selected, active);
    setState(_selected.clear);
  }

  @override
  Widget build(BuildContext context) {
    final sellers = ref.watch(sellersControllerProvider);
    final activeCount = sellers.where((s) => s.active).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SellersHeader(onAddPressed: () {}),
            const SizedBox(height: 12),
            ActiveAccountsBadge(
              activeCount: activeCount,
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
    );
  }
}
