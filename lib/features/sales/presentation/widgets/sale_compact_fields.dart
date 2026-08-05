import 'package:flutter/material.dart';

class ReadOnlyAmount extends StatelessWidget {
  final String label;
  final String value;

  const ReadOnlyAmount({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}

class QuantityStepper extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<double> onChanged;

  const QuantityStepper({
    super.key,
    required this.controller,
    required this.onDecrement,
    required this.onIncrement,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: onDecrement,
          ),
          SizedBox(
            width: 56,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
              ),
              style: theme.textTheme.bodyMedium,
              onChanged: (raw) {
                final value = double.tryParse(raw.replaceAll(',', '.'));
                if (value != null) onChanged(value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}