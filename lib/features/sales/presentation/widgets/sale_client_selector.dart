import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/widgets/create_client_dialog.dart';
import '../providers/clients_picker_provider.dart';
import '../providers/register_sale_controller_provider.dart';
import '../utils/sale_formatters.dart';

class SaleClientSelector extends ConsumerStatefulWidget {
  const SaleClientSelector({super.key});

  @override
  ConsumerState<SaleClientSelector> createState() => _SaleClientSelectorState();
}

class _SaleClientSelectorState extends ConsumerState<SaleClientSelector> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) setState(() => _open = true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _query = value.trim();
          _open = true;
        });
      }
    });
  }

  void _select(Client client) {
    ref.read(registerSaleControllerProvider.notifier).onClientSelected(client);
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _query = '';
      _open = false;
    });
  }

  Future<void> _registerClient(String initialName) async {
    final normalizedName = initialName.trim();
    final client = await CreateClientDialog.showForSelection(
      context,
      initialName: normalizedName,
    );
    if (!mounted || client == null) return;

    ref.invalidate(clientsPickerResultsProvider(normalizedName));
    _select(client);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = ref.watch(
      registerSaleControllerProvider.select((state) => state.client),
    );
    final clientsAsync = ref.watch(clientsPickerResultsProvider(_query));

    if (selected != null && !_open) {
      return _SelectedClientCard(
        client: selected,
        onChange: () {
          setState(() => _open = true);
          _focusNode.requestFocus();
        },
        onClear: () =>
            ref.read(registerSaleControllerProvider.notifier).onClearClient(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: false,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Buscar cliente',
            hintText: 'Escribe el nombre, CI o NIT',
            prefixIcon: Icon(Icons.search_rounded),
            isDense: true,
          ),
          onChanged: _onSearchChanged,
        ),
        if (_open) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.18),
              ),
            ),
            child: clientsAsync.when(
              data: (clients) => _ClientResultsList(
                clients: clients.take(6).toList(),
                query: _query,
                onSelect: _select,
                onClose: () {
                  _focusNode.unfocus();
                  setState(() => _open = false);
                },
                onRegister: _query.isNotEmpty || clients.isEmpty
                    ? () => _registerClient(_query)
                    : null,
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
              error: (_, _) => _ClientPickerMessage(
                icon: Icons.error_outline_rounded,
                message: 'No se pudieron cargar los clientes.',
                actionLabel: _query.isEmpty ? null : 'Registrar nuevo cliente',
                onAction: _query.isEmpty ? null : () => _registerClient(_query),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ClientResultsList extends StatelessWidget {
  final List<Client> clients;
  final String query;
  final ValueChanged<Client> onSelect;
  final VoidCallback onClose;
  final VoidCallback? onRegister;

  const _ClientResultsList({
    required this.clients,
    required this.query,
    required this.onSelect,
    required this.onClose,
    required this.onRegister,
  });

  bool get _hasExactMatch {
    final normalizedQuery = normalizeSearchText(query.trim());
    return clients.any(
      (client) => normalizeSearchText(client.name) == normalizedQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return _ClientPickerMessage(
        icon: Icons.search_off_rounded,
        message: query.isEmpty
            ? 'No hay clientes registrados.'
            : 'Sin resultados para "$query".',
        actionLabel: onRegister == null ? null : 'Registrar nuevo cliente',
        onAction: onRegister,
      );
    }

    return Column(
      children: [
        for (final client in clients)
          ListTile(
            dense: true,
            leading: const Icon(Icons.person_outline_rounded),
            title: Text(client.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              'CI: ${client.ci}${client.phone == null ? '' : ' - ${client.phone}'}',
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onSelect(client),
          ),
        if (onRegister != null && !_hasExactMatch)
          ListTile(
            dense: true,
            leading: const Icon(Icons.person_add_alt_rounded),
            title: Text('Registrar "$query"'),
            subtitle: const Text('Crear cliente y usarlo en esta venta'),
            onTap: onRegister,
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: onClose, child: const Text('Cerrar')),
        ),
      ],
    );
  }
}

class _SelectedClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onChange;
  final VoidCallback onClear;

  const _SelectedClientCard({
    required this.client,
    required this.onChange,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.person_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'CI: ${client.ci}${client.phone == null ? '' : ' - ${client.phone}'}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onChange, child: const Text('Cambiar')),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Quitar cliente',
              onPressed: onClear,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientPickerMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ClientPickerMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.person_add_alt_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
