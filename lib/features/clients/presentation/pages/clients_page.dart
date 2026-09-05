import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/page_header.dart';
import '../providers/clients_search_provider.dart';
import '../providers/clients_search_query_provider.dart';
import '../widgets/client_list_item.dart';
import '../widgets/client_status_filter.dart';
import '../widgets/clients_empty_state.dart';
import '../widgets/clients_search_field.dart';
import '../widgets/create_client_dialog.dart';

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsSearchProvider);
    final query = ref.watch(clientsSearchQueryProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                    value: query.status,
                    onFilterChanged: ref
                        .read(clientsSearchQueryProvider.notifier)
                        .onStatusChanged,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => CreateClientDialog.show(context),
                  icon: const Icon(Icons.person_add_alt_rounded),
                  label: const Text('Registrar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: clientsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorState(
                  message: error is Failure
                      ? error.message
                      : 'Error inesperado al cargar los clientes.',
                  onRetry: () => ref.invalidate(clientsSearchProvider),
                ),
                data: (clients) {
                  if (clients.isEmpty) {
                    return ClientsEmptyState(
                      message: query.text.isNotEmpty
                          ? 'Ningún cliente coincide con "${query.text}"'
                          : switch (query.status) {
                              ClientStatusFilter.active =>
                                'No hay clientes activos',
                              ClientStatusFilter.inactive =>
                                'No hay clientes inactivos',
                              ClientStatusFilter.all =>
                                'Aún no hay clientes registrados',
                            },
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: clients.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        ClientListItem(client: clients[index]),
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
