import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clients_search_query_provider.dart';

/// Campo de búsqueda de la tarea #37. El rebote de teclado vive aquí y no en
/// el provider, para que el provider siga siendo puro y fácil de probar.
class ClientsSearchField extends ConsumerStatefulWidget {
  const ClientsSearchField({super.key});

  static const debounce = Duration(milliseconds: 350);

  @override
  ConsumerState<ClientsSearchField> createState() => _ClientsSearchFieldState();
}

class _ClientsSearchFieldState extends ConsumerState<ClientsSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(ClientsSearchField.debounce, () {
      ref.read(clientsSearchQueryProvider.notifier).onTextChanged(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(clientsSearchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = ref.watch(
      clientsSearchQueryProvider.select((query) => query.text.isNotEmpty),
    );

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, cédula o NIT',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: hasText
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Limpiar búsqueda',
                onPressed: _clear,
              )
            : null,
      ),
      textInputAction: TextInputAction.search,
      onChanged: _onChanged,
    );
  }
}
