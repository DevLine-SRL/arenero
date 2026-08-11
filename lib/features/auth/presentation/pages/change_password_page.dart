import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../widgets/login_header.dart';
import '../widgets/change_password_form_widget.dart';
import '../widgets/change_password_button.dart';
import '../widgets/skip_change_password_button.dart';
import '../providers/change_password_form_provider.dart';

class ChangePasswordPage extends ConsumerWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitError = ref.watch(
      changePasswordFormProvider.select((state) => state.submitError),
    );

    ref.listen(changePasswordFormProvider, (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        context.goNamed(RouteNames.dashboard);
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
                  const LoginHeader(subtitle: 'Cambiar contraseña'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        const Text(
                          'Crea una nueva contraseña para mantener tu cuenta segura. ',
                        ),
                        const ChangePasswordFormWidget(),
                        if (submitError != null)
                          Text(
                            submitError,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        const ChangePasswordButton(),
                        const SkipChangePasswordButton(),
                      ],
                    ),
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
