import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clients_search_query_provider.dart';
import 'create_client_dialog.dart';

class ClientsActionsBar extends ConsumerWidget {
  const ClientsActionsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final includeInactive = ref.watch(
      clientsSearchQueryProvider.select((query) => query.includeInactive),
    );

    return Row(
      children: [
        Expanded(
          child: FilterChip(
            label: const Text('Incluir inactivos'),
            selected: includeInactive,
            onSelected: ref
                .read(clientsSearchQueryProvider.notifier)
                .onIncludeInactiveChanged,
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: () => CreateClientDialog.show(context),
          icon: const Icon(Icons.person_add_alt_rounded),
          label: const Text('Registrar cliente'),
        ),
      ],
    );
  }
}
