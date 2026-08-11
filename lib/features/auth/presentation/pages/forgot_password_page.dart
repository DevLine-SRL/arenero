import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../widgets/login_header.dart';
import '../widgets/forgot_password_email_step.dart';
import '../widgets/forgot_password_code_step.dart';
import '../providers/forgot_password_form_provider.dart';
import '../providers/forgot_password_state.dart';

class ForgotPasswordPage extends ConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordFormProvider);
    final isCodeStep = state.step == ForgotPasswordStep.code;

    ref.listen(forgotPasswordFormProvider, (previous, next) {
      if (next.isVerified && !(previous?.isVerified ?? false)) {
        context.goNamed(RouteNames.changePassword);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginHeader(
                    subtitle: isCodeStep
                        ? 'Ingresa el código'
                        : 'Recuperar contraseña',
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isCodeStep
                        ? const ForgotPasswordCodeStep()
                        : const ForgotPasswordEmailStep(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
