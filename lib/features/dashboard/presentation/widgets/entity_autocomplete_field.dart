import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../reports/domain/entities/report_suggestion.dart';

const _maxOverlayWidth = 420.0;
const _overlayVerticalOffset = 8.0;

class EntityAutocompleteField extends ConsumerStatefulWidget {
  final FutureOr<List<ReportSuggestion>> Function(Ref ref, String query)
  loadSuggestions;
  final String labelText;
  final String hintText;
  final ValueChanged<ReportSuggestion> onSelected;
  final VoidCallback onCleared;

  const EntityAutocompleteField({
    super.key,
    required this.loadSuggestions,
    required this.labelText,
    required this.hintText,
    required this.onSelected,
    required this.onCleared,
  });

  @override
  ConsumerState<EntityAutocompleteField> createState() =>
      _EntityAutocompleteFieldState();
}

class _EntityAutocompleteFieldState
    extends ConsumerState<EntityAutocompleteField> {
  static const _debounceDuration = Duration(milliseconds: 300);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();
  Timer? _debounce;
  String _query = '';
  ReportSuggestion? _selected;

  late final _suggestionsProvider =
      FutureProvider.family<List<ReportSuggestion>, String>(
        (ref, query) => widget.loadSuggestions(ref, query),
      );

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_overlayPortalController.isShowing) {
      _overlayPortalController.show();
    }
    if (mounted) setState(() {});
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _onSuggestionTapped(ReportSuggestion suggestion) {
    _debounce?.cancel();
    _overlayPortalController.hide();
    setState(() {
      _selected = suggestion;
      _query = '';
      _controller.clear();
    });
    _focusNode.unfocus();
    widget.onSelected(suggestion);
  }

  void _dismissOverlay() {
    _overlayPortalController.hide();
    _focusNode.unfocus();
  }

  void _onClearSelection() {
    setState(() => _selected = null);
    widget.onCleared();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return _SelectedEntityChip(
        name: _selected!.name,
        onClear: _onClearSelection,
      );
    }

    final suggestionsAsync = _overlayPortalController.isShowing
        ? ref.watch(_suggestionsProvider(_query))
        : null;

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayPortalController,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onTextChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search_rounded),
        ),
      ),
      overlayChildBuilder: (context, info) => _SuggestionsOverlay(
        info: info,
        suggestionsAsync: suggestionsAsync,
        onSuggestionTapped: _onSuggestionTapped,
        onDismiss: _dismissOverlay,
      ),
    );
  }
}

class _SuggestionsOverlay extends StatelessWidget {
  final OverlayChildLayoutInfo info;
  final AsyncValue<List<ReportSuggestion>>? suggestionsAsync;
  final ValueChanged<ReportSuggestion> onSuggestionTapped;
  final VoidCallback onDismiss;

  const _SuggestionsOverlay({
    required this.info,
    required this.suggestionsAsync,
    required this.onSuggestionTapped,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final fieldBottomLeft = MatrixUtils.transformPoint(
      info.childPaintTransform,
      Offset(0, info.childSize.height),
    );
    final overlayWidth = info.childSize.width < _maxOverlayWidth
        ? info.childSize.width
        : _maxOverlayWidth;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        Positioned(
          left: fieldBottomLeft.dx,
          top: fieldBottomLeft.dy + _overlayVerticalOffset,
          width: overlayWidth,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: _buildBody(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final async = suggestionsAsync;
    if (async == null) return const SizedBox.shrink();

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No se pudo completar la búsqueda.',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (suggestions) => suggestions.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin coincidencias'),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final suggestion in suggestions)
                  ListTile(
                    dense: true,
                    title: Text(
                      suggestion.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSuggestionTapped(suggestion),
                  ),
              ],
            ),
    );
  }
}

class _SelectedEntityChip extends StatelessWidget {
  final String name;
  final VoidCallback onClear;

  const _SelectedEntityChip({required this.name, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_rounded, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          IconButton(
            onPressed: onClear,
            tooltip: 'Quitar selección',
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
