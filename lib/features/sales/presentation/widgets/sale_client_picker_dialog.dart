import 'package:flutter/material.dart';

import '../providers/mock_sales_data.dart';
import '../utils/sale_formatters.dart';

class SaleClientPickerDialog extends StatefulWidget {
  const SaleClientPickerDialog({super.key});

  @override
  State<SaleClientPickerDialog> createState() => _SaleClientPickerDialogState();
}

class _SaleClientPickerDialogState extends State<SaleClientPickerDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClientEntry> get _filteredClients {
    final query = normalizeSearchText(_query.trim());
    if (query.isEmpty) return MockCatalog.clients;

    return MockCatalog.clients.where((client) {
      return normalizeSearchText(client.name).contains(query) ||
          normalizeSearchText(client.ci).contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clients = _filteredClients;

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
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _query.trim().isEmpty
                    ? '${MockCatalog.clients.length} clientes'
                    : '${clients.length} resultado${clients.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: clients.isEmpty
                  ? _ClientEmptyState(query: _query.trim())
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

  const _ClientEmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            query.isEmpty
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