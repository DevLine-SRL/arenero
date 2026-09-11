import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../sellers/domain/entities/seller.dart';
import '../../../sellers/presentation/providers/sellers_controller_provider.dart';
import '../providers/register_sale_controller_provider.dart';

class SaleSellerSelector extends ConsumerWidget {
  const SaleSellerSelector({super.key});

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

    return _SellerDropdownField(
      selected: selected,
      sellersAsync: sellersAsync,
      onSelected: (seller) => ref
          .read(registerSaleControllerProvider.notifier)
          .onSellerSelected(seller),
    );
  }
}

class _SellerDropdownField extends StatelessWidget {
  final Seller? selected;
  final AsyncValue<List<Seller>> sellersAsync;
  final ValueChanged<Seller> onSelected;

  const _SellerDropdownField({
    required this.selected,
    required this.sellersAsync,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = selected != null
        ? _displayName(selected!.name, selected!.email)
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPicker(context),
      child: InputDecorator(
        isEmpty: displayName == null,
        decoration: InputDecoration(
          hintText: 'Seleccionar vendedor',
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          prefixIcon: selected != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: _SellerAvatar(
                    name: displayName!,
                    color: _sellerColor(selected!.id, theme.colorScheme),
                    size: 28,
                    fontSize: 12,
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.person_outline_rounded),
                ),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.arrow_drop_down_rounded),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        child: selected != null
            ? Text(
                displayName!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SellerPickerSheet(
        sellersAsync: sellersAsync,
        selected: selected,
        onSelected: (seller) {
          Navigator.of(context).pop();
          onSelected(seller);
        },
      ),
    );
  }
}

class _SellerPickerSheet extends StatefulWidget {
  final AsyncValue<List<Seller>> sellersAsync;
  final Seller? selected;
  final ValueChanged<Seller> onSelected;

  const _SellerPickerSheet({
    required this.sellersAsync,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_SellerPickerSheet> createState() => _SellerPickerSheetState();
}

class _SellerPickerSheetState extends State<_SellerPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Seller> get _filtered {
    final sellers = widget.sellersAsync.value ?? const <Seller>[];
    final active = sellers.where((s) => s.active).toList();
    if (_query.isEmpty) return active;
    final q = _query.toLowerCase();
    return active.where((seller) {
      final name = _displayName(seller.name, seller.email).toLowerCase();
      final email = seller.email.toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Buscar vendedor...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 8),
            if (widget.sellersAsync.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (widget.sellersAsync.hasError)
              Expanded(
                child: Center(
                  child: Text(
                    'No se pudieron cargar los vendedores.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _query.isEmpty
                        ? 'No hay vendedores activos.'
                        : 'No se encontraron vendedores.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final seller = _filtered[index];
                    final name = _displayName(seller.name, seller.email);
                    final isSelected = seller.id == widget.selected?.id;

                    return ListTile(
                      leading: _SellerAvatar(
                        name: name,
                        color: _sellerColor(seller.id, theme.colorScheme),
                        size: 36,
                        fontSize: 14,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        seller.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () => widget.onSelected(seller),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SellerAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  final double fontSize;

  const _SellerAvatar({
    required this.name,
    required this.color,
    required this.size,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

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
