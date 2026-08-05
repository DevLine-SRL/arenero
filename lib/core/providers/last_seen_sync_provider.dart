import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/logout_provider.dart';
import '../config/app_config.dart';
import '../errors/failures.dart';

part 'last_seen_sync_provider.g.dart';

@Riverpod(keepAlive: true)
class LastSeenSync extends _$LastSeenSync {
  Timer? _timer;

  @override
  void build() {
    ref.onDispose(_cancelTimer);

    ref.listen(authSessionProvider, (previous, next) async {
      final user = next.value;
      if (user == null) {
        _cancelTimer();
        return;
      }
      await _handleLoggedIn(user);
    });
  }

  Future<void> _handleLoggedIn(User user) async {
    final lastSeenAt = user.lastSeenAt;
    if (lastSeenAt != null &&
        DateTime.now().toUtc().difference(lastSeenAt) >
            AppConfig.sessionMaxAbsence) {
      await _forceLogout();
      return;
    }

    if (await _touch()) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(AppConfig.lastSeenTouchInterval, (_) {
      _touch();
    });
  }

  Future<bool> _touch() async {
    if (ref.read(authSessionProvider).value == null) return false;

    final result = await ref.read(touchLastSeenUseCaseProvider)();
    if (!ref.mounted) return false;

    var keepGoing = true;
    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) keepGoing = false;
      },
      (lastSeenAt) {
        if (lastSeenAt == null) keepGoing = false;
      },
    );

    if (!keepGoing) {
      await _forceLogout();
      return false;
    }
    return true;
  }

  Future<void> _forceLogout() {
    _cancelTimer();
    return ref.read(logoutProvider.notifier)();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
