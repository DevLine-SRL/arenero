import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../domain/entities/client.dart';
import '../providers/clients_search_provider.dart';
import '../providers/clients_search_query_provider.dart';
import '../widgets/client_status_filter.dart';
import '../widgets/clients_actions_bar.dart';
import '../widgets/clients_empty_state.dart';
import '../widgets/clients_table.dart';
import '../widgets/clients_search_field.dart';
import '../widgets/create_client_dialog.dart';
import '../widgets/edit_client_dialog.dart';

class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends ConsumerState<ClientsPage> {
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

  void _onFilterChanged(ClientStatusFilter filter) {
    ref.read(clientsSearchQueryProvider.notifier).onStatusChanged(filter);
    setState(_selected.clear);
  }

  Future<void> _setActive(bool active) async {
    if (_selected.isEmpty) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: active ? 'Habilitar clientes' : 'Deshabilitar clientes',
      content: active
          ? '¿Estás seguro de que deseas habilitar ${_selected.length == 1 ? 'el cliente seleccionado' : 'los ${_selected.length} clientes seleccionados'}?'
          : '¿Estás seguro de que deseas deshabilitar ${_selected.length == 1 ? 'el cliente seleccionado' : 'los ${_selected.length} clientes seleccionados'}?',
      confirmLabel: active ? 'Si, habilitar' : 'Si, deshabilitar',
    );
    if (!confirmed) return;

    await ref.read(clientsSearchProvider.notifier).setActive(_selected, active);
    setState(_selected.clear);
  }

  Future<void> _editClient(Client client) async {
    final saved = await EditClientDialog.show(context, client: client);

    if (saved != true || !mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Cliente guardado')));
  }

  Future<void> _openCreateDialog() async {
    final created = await CreateClientDialog.show(context);
    if (created == true) {
      ref.invalidate(clientsSearchProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsSearchProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: clientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: error is Failure
                ? error.message
                : 'Error inesperado al cargar los clientes.',
            onRetry: () => ref.invalidate(clientsSearchProvider),
          ),
          data: (clients) {
            final query = ref.watch(clientsSearchQueryProvider);
            final filter = query.status;
            final activeCount = clients.where((c) => c.active).length;
            final inactiveCount = clients.length - activeCount;

            final visibleClients = switch (filter) {
              ClientStatusFilter.active =>
                clients.where((c) => c.active).toList(),
              ClientStatusFilter.inactive =>
                clients.where((c) => !c.active).toList(),
              ClientStatusFilter.all => clients,
            };

            final emptyMessage = clients.isEmpty
                ? 'Aún no hay clientes registrados'
                : visibleClients.isEmpty && query.text.trim().isNotEmpty
                ? 'Ningún cliente coincide con "${query.text.trim()}"'
                : switch (filter) {
                    ClientStatusFilter.active => 'No hay clientes activos',
                    ClientStatusFilter.inactive => 'No hay clientes inactivos',
                    ClientStatusFilter.all => 'No hay clientes',
                  };

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHeader(
                  title: 'Gestión de Clientes',
                  description: 'Base de datos de clientes',
                  icon: Icons.people_rounded,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClientsSearchField(
                        value: filter,
                        activeCount: activeCount,
                        inactiveCount: inactiveCount,
                        total: clients.length,
                        onFilterChanged: _onFilterChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _openCreateDialog,
                      icon: const Icon(Icons.person_add_alt_rounded),
                      label: const Text('Registrar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClientsActionsBar(
                  filter: filter,
                  selectedCount: _selected.length,
                  onEnable: _selected.isEmpty ? null : () => _setActive(true),
                  onDisable: _selected.isEmpty ? null : () => _setActive(false),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: visibleClients.isEmpty
                      ? ClientsEmptyState(message: emptyMessage)
                      : ClientsTable(
                          clients: visibleClients,
                          selectedIds: _selected,
                          onToggle: _toggleSelected,
                          onEdit: _editClient,
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
