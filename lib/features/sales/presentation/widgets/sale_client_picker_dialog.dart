import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clients_picker_provider.dart';

class SaleClientPickerDialog extends ConsumerStatefulWidget {
  const SaleClientPickerDialog({super.key});

  @override
  ConsumerState<SaleClientPickerDialog> createState() =>
      _SaleClientPickerDialogState();
}

class _SaleClientPickerDialogState
    extends ConsumerState<SaleClientPickerDialog> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _query.trim();
    final clientsAsync = ref.watch(clientsPickerResultsProvider(query));

    return AlertDialog(
      title: const Text('Seleccionar cliente'),
      constraints: const BoxConstraints(
        minWidth: 400,
        maxWidth: 480,
        minHeight: 320,
        maxHeight: 460,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre o carnet',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: clientsAsync.maybeWhen(
                data: (clients) => Text(
                  query.isEmpty
                      ? '${clients.length} clientes'
                      : '${clients.length} resultado${clients.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: clientsAsync.when(
                data: (clients) => clients.isEmpty
                    ? _ClientEmptyState(query: query)
                    : ListView.builder(
                        itemCount: clients.length,
                        itemBuilder: (context, index) {
                          final client = clients[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.person_outline_rounded),
                            title: Text(client.name),
                            subtitle: Text('CI: ${client.ci}'),
                            onTap: () => Navigator.of(context).pop(client),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    _ClientEmptyState(query: query, isError: true),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _ClientEmptyState extends StatelessWidget {
  final String query;
  final bool isError;

  const _ClientEmptyState({required this.query, this.isError = false});

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
        ],
      ),
    );
  }
}
