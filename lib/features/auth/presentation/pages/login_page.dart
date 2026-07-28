import 'package:flutter/material.dart';

import '../widgets/login_button.dart';
import '../widgets/login_form.dart';
import '../widgets/login_error_banner.dart';
import '../widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const LoginHeader(),
                  const SizedBox(height: 48),
                  const LoginErrorBanner(),
                  const SizedBox(height: 24),
                  const LoginFormWidget(),
                  const SizedBox(height: 24),
                  const LoginButton(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
