import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../sellers/presentation/providers/sellers_controller_provider.dart';
import '../providers/register_sale_controller_provider.dart';

class SaleSellerSelector extends ConsumerWidget {
  const SaleSellerSelector({super.key});

  Color _sellerColor(String id, ColorScheme scheme) {
    final colors = [
      scheme.primary,
      scheme.tertiary,
      const Color(0xFF0F766E),
      const Color(0xFFB45309),
      const Color(0xFF7C3AED),
    ];
    final index = id.hashCode.abs() % colors.length;
    return colors[index];
  }

  String _displayName(String? name, String fallback) {
    final trimmed = name?.trim();
    return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authSessionProvider).value;

    if (user == null) {
      return Text(
        'No se pudo identificar el usuario actual.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }

    if (user.role != 'admin') {
      final name = _displayName(user.name, user.email);
      return _SelectedSellerBanner(
        name: name,
        subtitle: 'Esta venta se registrará a tu nombre',
        locked: true,
      );
    }

    final selected = ref.watch(
      registerSaleControllerProvider.select((state) => state.seller),
    );
    final sellersAsync = ref.watch(sellersControllerProvider);

    return sellersAsync.when(
      data: (sellers) {
        final activeSellers = sellers.where((seller) => seller.active).toList();
        final selectedFromList = selected == null
            ? null
            : activeSellers
                  .where((seller) => seller.id == selected.id)
                  .firstOrNull;
        if (activeSellers.isEmpty) {
          return Text(
            'No hay vendedores activos para atribuir la venta.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'El administrador puede atribuir esta venta a cualquier vendedor activo.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth >= 620 ? 190.0 : 168.0;

                return SizedBox(
                  height: 116,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 2),
                    itemCount: activeSellers.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final seller = activeSellers[index];
                      final name = _displayName(seller.name, seller.email);

                      return SizedBox(
                        width: cardWidth,
                        child: _SellerChoiceCard(
                          name: name,
                          email: seller.email,
                          color: _sellerColor(seller.id, theme.colorScheme),
                          initials: _initials(name),
                          selected: selectedFromList?.id == seller.id,
                          onTap: () => ref
                              .read(registerSaleControllerProvider.notifier)
                              .onSellerSelected(seller),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => Text(
        'No se pudieron cargar los vendedores.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

class _SellerChoiceCard extends StatelessWidget {
  final String name;
  final String email;
  final String initials;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SellerChoiceCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.72)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.22),
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (selected)
              Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color,
                  child: Text(
                    initials,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedSellerBanner extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool locked;

  const _SelectedSellerBanner({
    required this.name,
    required this.subtitle,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(
                name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (locked)
              const Tooltip(
                message: 'El vendedor no puede cambiarse',
                child: Icon(Icons.lock_outline_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
