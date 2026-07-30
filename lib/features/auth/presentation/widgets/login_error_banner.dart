import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/login_form_provider.dart';

class LoginErrorBanner extends ConsumerWidget {
  const LoginErrorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitError = ref.watch(
      loginFormProvider.select((state) => state.submitError),
    );

    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: submitError == null
        ? const SizedBox.shrink(key: ValueKey('no-error'))
        : Container(
            key: const ValueKey('error'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onErrorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.errorContainer,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    submitError,
                    style: TextStyle(
                      color: theme.colorScheme.errorContainer,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
