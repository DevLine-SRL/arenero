import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../domain/entities/client.dart';
import '../providers/clients_search_provider.dart';
import '../providers/clients_search_query_provider.dart';
import '../providers/clients_selection_provider.dart';
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
  void _onFilterChanged(ClientStatusFilter filter) {
    ref.read(clientsSearchQueryProvider.notifier).onStatusChanged(filter);
    ref.read(clientsSelectionProvider.notifier).clear();
  }

  Future<void> _setActive(bool active) async {
    final selected = ref.read(clientsSelectionProvider);
    if (selected.isEmpty) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: active ? 'Habilitar clientes' : 'Deshabilitar clientes',
      content: active
          ? '¿Estás seguro de que deseas habilitar ${selected.length == 1 ? 'el cliente seleccionado' : 'los ${selected.length} clientes seleccionados'}?'
          : '¿Estás seguro de que deseas deshabilitar ${selected.length == 1 ? 'el cliente seleccionado' : 'los ${selected.length} clientes seleccionados'}?',
      confirmLabel: active ? 'Si, habilitar' : 'Si, deshabilitar',
    );
    if (!confirmed) return;

    await ref.read(clientsSearchProvider.notifier).setActive(selected, active);
    ref.read(clientsSelectionProvider.notifier).clear();
  }

  Future<void> _editClient(Client client) async {
    final saved = await EditClientDialog.show(context, client: client);

    if (saved != true || !mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Cliente guardado')));
  }

  Future<void> _editSelected() async {
    final selected = ref.read(clientsSelectionProvider);
    if (selected.length != 1) return;

    final clients = ref.read(clientsSearchProvider).value;
    if (clients == null) return;

    final client = clients.firstWhere((c) => c.id == selected.first);
    await _editClient(client);
  }

  Future<void> _openCreateDialog() async {
    final created = await CreateClientDialog.show(context);
    if (created == true) {
      ref.invalidate(clientsSearchProvider);
    }
  }

  List<Client> _filterClients(
    List<Client> clients, {
    required ClientStatusFilter status,
    required String text,
  }) {
    final normalizedText = text.trim().toLowerCase();

    return clients.where((client) {
      final matchesStatus = switch (status) {
        ClientStatusFilter.active => client.active,
        ClientStatusFilter.inactive => !client.active,
        ClientStatusFilter.all => true,
      };
      if (!matchesStatus) return false;

      if (normalizedText.isEmpty) return true;

      final haystack = [
        client.name,
        client.ci,
        client.nit ?? '',
        client.phone ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsSearchProvider);
    final selection = ref.watch(clientsSelectionProvider);

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

            final visibleClients = _filterClients(
              clients,
              status: filter,
              text: query.text,
            );

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
                  description: 'Clientes registrados',
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
                  selectedCount: selection.length,
                  onEnable: selection.isEmpty ? null : () => _setActive(true),
                  onDisable: selection.isEmpty ? null : () => _setActive(false),
                  onEdit: _editSelected,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: visibleClients.isEmpty
                      ? ClientsEmptyState(message: emptyMessage)
                      : ClientsTable(clients: visibleClients),
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
