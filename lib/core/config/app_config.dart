abstract final class AppConfig {
  static String get supabaseUrl =>
      _require(const String.fromEnvironment('SUPABASE_URL'), 'SUPABASE_URL');

  static String get supabasePublishableKey => _require(
    const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static Duration get sessionMaxAbsence {
    const raw = String.fromEnvironment('SESSION_MAX_ABSENCE_HOURS');
    if (raw.isEmpty) return const Duration(hours: 72);
    final hours = int.tryParse(raw);
    if (hours == null || hours <= 0) {
      throw ArgumentError(
        'Invalid session max absence hours. '
        'It must be a positive number of hours.',
      );
    }
    return Duration(hours: hours);
  }

  static Duration get lastSeenTouchInterval => const Duration(minutes: 5);

  static Duration get historyRetention => const Duration(days: 90);

  static Duration get outboxBackoffBase => const Duration(minutes: 1);

  static int get outboxMaxAttempts => 5;

  static String _require(String value, String name) {
    if (value.isEmpty) {
      throw ArgumentError('Missing --dart-define=$name=<value>');
    }
    return value;
  }
}
