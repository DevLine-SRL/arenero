import 'package:flutter/material.dart';

class SaleSectionCard extends StatelessWidget {
  final String title;
  final bool required;
  final Widget? trailing;
  final Widget child;

  const SaleSectionCard({
    super.key,
    required this.title,
    this.required = false,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: title,
                      style: theme.textTheme.titleMedium,
                      children: [
                        if (required)
                          TextSpan(
                            text: ' *',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
