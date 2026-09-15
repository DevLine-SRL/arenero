import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeInputField extends StatefulWidget {
  final String? errorText;
  final ValueChanged<String> onChanged;

  const CodeInputField({super.key, required this.onChanged, this.errorText});

  @override
  State<CodeInputField> createState() => _CodeInputFieldState();
}

class _CodeInputFieldState extends State<CodeInputField> {
  static const _digitCount = 6;

  final _controllers = List.generate(
    _digitCount,
    (_) => TextEditingController(),
  );
  final _focusNodes = List.generate(_digitCount, (_) => FocusNode());

  late final _pasteFormatter = _PasteDistributorFormatter(
    onPaste: _schedulePaste,
  );

  bool _isPasting = false;
  String _pendingPaste = '';

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _notifyChange() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code);
  }

  void _schedulePaste(String digits) {
    if (digits.isEmpty) return;
    _pendingPaste = digits;
    _isPasting = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePaste(_pendingPaste);
    });
  }

  void _handlePaste(String digits) {
    if (digits.isEmpty) return;
    final code = digits.substring(0, digits.length.clamp(0, _digitCount));
    for (var i = 0; i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    final nextIndex = code.length.clamp(0, _digitCount - 1);
    _focusNodes[nextIndex].requestFocus();
    _notifyChange();
    _isPasting = false;
  }

  void _onDigitChanged(int index, String value) {
    if (_isPasting) return;
    if (value.isNotEmpty && index < _digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _notifyChange();
  }

  KeyEventResult _onKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isBackspace = event.logicalKey == LogicalKeyboardKey.backspace;
    final isEmpty = _controllers[index].text.isEmpty;

    if (isBackspace && isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      _notifyChange();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_digitCount, (index) {
            return SizedBox(
              width: 48,
              height: 60,
              child: Focus(
                skipTraversal: true,
                onKeyEvent: (node, event) => _onKeyEvent(index, event),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: theme.textTheme.headlineSmall,
                  inputFormatters: [
                    _pasteFormatter,
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: hasError
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: hasError
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => _onDigitChanged(index, value),
                ),
              ),
            );
          }),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _PasteDistributorFormatter extends TextInputFormatter {
  final void Function(String)? onPaste;

  _PasteDistributorFormatter({this.onPaste});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length > 1) {
      final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
      onPaste?.call(digits);
      return oldValue;
    }
    return newValue;
  }
}
