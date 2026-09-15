import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/widgets/create_client_dialog.dart';
import '../providers/clients_picker_provider.dart';
import '../providers/register_sale_controller_provider.dart';

class SaleClientSelector extends ConsumerWidget {
  const SaleClientSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      registerSaleControllerProvider.select((state) => state.client),
    );

    return _ClientDropdownField(
      selected: selected,
      onSelect: (client) => ref
          .read(registerSaleControllerProvider.notifier)
          .onClientSelected(client),
      onClear: () =>
          ref.read(registerSaleControllerProvider.notifier).onClearClient(),
    );
  }
}

class _ClientDropdownField extends StatelessWidget {
  final Client? selected;
  final ValueChanged<Client> onSelect;
  final VoidCallback onClear;

  const _ClientDropdownField({
    required this.selected,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPicker(context),
      child: InputDecorator(
        isEmpty: selected == null,
        decoration: InputDecoration(
          hintText: 'Seleccionar cliente',
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          prefixIcon: selected != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.person_outline_rounded),
                ),
          suffixIcon: selected != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Quitar cliente',
                    onPressed: onClear,
                  ),
                )
              : const Padding(
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
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selected!.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'CI: ${selected!.ci}${selected!.phone == null ? '' : ' · ${selected!.phone}'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
      builder: (_) => _ClientPickerSheet(
        selected: selected,
        onSelect: (client) {
          Navigator.of(context).pop();
          onSelect(client);
        },
      ),
    );
  }
}

class _ClientPickerSheet extends ConsumerStatefulWidget {
  final Client? selected;
  final ValueChanged<Client> onSelect;

  const _ClientPickerSheet({required this.selected, required this.onSelect});

  @override
  ConsumerState<_ClientPickerSheet> createState() => _ClientPickerSheetState();
}

class _ClientPickerSheetState extends ConsumerState<_ClientPickerSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  bool _hasExactMatch(List<Client> clients) {
    final normalized = _normalized(_query);
    return clients.any((c) => _normalized(c.name) == normalized);
  }

  String _normalized(String text) =>
      text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<void> _registerClient() async {
    final normalizedName = _query.trim();
    final client = await CreateClientDialog.showForSelection(
      context,
      initialName: normalizedName,
    );
    if (!mounted || client == null) return;

    ref.invalidate(clientsPickerResultsProvider(normalizedName));
    widget.onSelect(client);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clientsAsync = ref.watch(clientsPickerResultsProvider(_query));

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
                  hintText: 'Buscar por nombre, CI o teléfono...',
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
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: clientsAsync.when(
                data: (clients) {
                  if (clients.isEmpty) {
                    return _EmptyState(
                      query: _query,
                      onRegister: _registerClient,
                    );
                  }

                  final showRegister =
                      _query.isNotEmpty && !_hasExactMatch(clients);

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: clients.length + (showRegister ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == clients.length) {
                        return ListTile(
                          leading: const Icon(Icons.person_add_alt_rounded),
                          title: Text('Registrar "$_query"'),
                          subtitle: const Text(
                            'Crear cliente y usarlo en esta venta',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: _registerClient,
                        );
                      }

                      final client = clients[index];
                      final isSelected = client.id == widget.selected?.id;

                      return ListTile(
                        leading: Icon(
                          Icons.person_outline_rounded,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                        title: Text(
                          client.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          'CI: ${client.ci}${client.phone == null ? '' : ' · ${client.phone}'}',
                          overflow: TextOverflow.ellipsis,
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
                        onTap: () => widget.onSelect(client),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => _EmptyState(
                  query: _query,
                  isError: true,
                  onRegister: _query.isNotEmpty ? _registerClient : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final bool isError;
  final VoidCallback? onRegister;

  const _EmptyState({
    required this.query,
    this.isError = false,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.search_off_rounded,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            isError
                ? 'No se pudieron cargar los clientes'
                : query.isEmpty
                ? 'No hay clientes registrados'
                : 'Sin resultados para "$query"',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (onRegister != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRegister,
              icon: const Icon(Icons.person_add_alt_rounded),
              label: const Text('Registrar nuevo cliente'),
            ),
          ],
        ],
      ),
    );
  }
}
