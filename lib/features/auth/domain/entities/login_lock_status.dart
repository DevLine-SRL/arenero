class LoginLockStatus {
  final bool locked;
  final Duration remaining;
  final int attemptsLeft;
  final int maxAttempts;
  final int lockMinutes;

  const LoginLockStatus({
    required this.locked,
    required this.remaining,
    required this.attemptsLeft,
    required this.maxAttempts,
    required this.lockMinutes,
  });

  factory LoginLockStatus.fromMap(Map<String, dynamic> map) {
    final remainingSeconds =
        (map['remaining_seconds'] as num?)?.toInt() ?? 0;

    final attemptsLeft =
        (map['attempts_left'] as num?)?.toInt() ?? 0;

    final maxAttempts =
        (map['max_attempts'] as num?)?.toInt() ?? 5;

    final lockMinutes =
        (map['lock_minutes'] as num?)?.toInt() ?? 15;

    return LoginLockStatus(
      locked: map['locked'] == true,
      remaining: Duration(
        seconds: remainingSeconds < 0 ? 0 : remainingSeconds,
      ),
      attemptsLeft: attemptsLeft < 0 ? 0 : attemptsLeft,
      maxAttempts: maxAttempts < 1 ? 5 : maxAttempts,
      lockMinutes: lockMinutes < 1 ? 15 : lockMinutes,
    );
  }

  bool get isNotLocked => !locked;

  bool get hasRemainingTime => remaining.inSeconds > 0;

  bool get hasAttemptsAvailable => attemptsLeft > 0;
}