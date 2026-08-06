import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/login_form_provider.dart';

class LoginErrorBanner extends ConsumerWidget {
  const LoginErrorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitError = ref.watch(
      loginFormProvider.select(
        (state) => state.submitError,
      ),
    );

    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 300,
      ),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: submitError == null
          ? const SizedBox.shrink(
              key: ValueKey('no-login-error'),
            )
          : Semantics(
              key: const ValueKey('login-error'),
              liveRegion: true,
              label: submitError,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        submitError,
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}