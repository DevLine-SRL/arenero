import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/logout_provider.dart';
import '../config/app_config.dart';

part 'session_timeout_provider.g.dart';

@Riverpod(keepAlive: true)
class SessionTimeoutController extends _$SessionTimeoutController {
  Timer? _timer;

  @override
  void build() {
    ref.onDispose(_cancelTimer);

    ref.listen(authSessionProvider, (previous, next) {
      if (next.value != null) {
        _startTimer();
      } else {
        _cancelTimer();
      }
    });
  }

  void onActivity() {
    if (ref.read(authSessionProvider).value == null) return;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(AppConfig.sessionTimeout, _onTimeout);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _onTimeout() async {
    _cancelTimer();
    await ref.read(logoutProvider.notifier)();
  }
}
