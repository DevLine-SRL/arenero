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
    return LoginLockStatus(
      locked: map['locked'] == true,
      remaining: Duration(
        seconds: (map['remaining_seconds'] as num?)?.toInt() ?? 0,
      ),
      attemptsLeft: (map['attempts_left'] as num?)?.toInt() ?? 0,
      maxAttempts: (map['max_attempts'] as num?)?.toInt() ?? 5,
      lockMinutes: (map['lock_minutes'] as num?)?.toInt() ?? 15,
    );
  }
}
