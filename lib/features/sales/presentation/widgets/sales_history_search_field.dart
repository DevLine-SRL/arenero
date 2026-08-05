import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sales_history_search_query_provider.dart';

class SalesHistorySearchField extends ConsumerStatefulWidget {
  static const debounce = Duration(milliseconds: 350);

  const SalesHistorySearchField({super.key});

  @override
  ConsumerState<SalesHistorySearchField> createState() =>
      _SalesHistorySearchFieldState();
}

class _SalesHistorySearchFieldState
    extends ConsumerState<SalesHistorySearchField> {
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
    _debounce = Timer(SalesHistorySearchField.debounce, () {
      ref.read(salesHistorySearchQueryProvider.notifier).onTextChanged(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(salesHistorySearchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = ref.watch(
      salesHistorySearchQueryProvider.select((text) => text.isNotEmpty),
    );

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Buscar por cliente o cédula',
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
