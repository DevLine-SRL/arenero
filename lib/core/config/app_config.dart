abstract final class AppConfig {
  static String get supabaseUrl =>
      _require(const String.fromEnvironment('SUPABASE_URL'), 'SUPABASE_URL');

  static String get supabasePublishableKey => _require(
    const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static Duration get sessionTimeout {
    const raw = String.fromEnvironment('SESSION_TIMEOUT_SECONDS');
    if (raw.isEmpty) return const Duration(minutes: 5);
    final seconds = int.tryParse(raw);
    if (seconds == null || seconds <= 0) {
      throw ArgumentError(
        'Invalid sessuib timeout seconds. '
        'It must be a positive number of seconds.',
      );
    }
    return Duration(seconds: seconds);
  }

  static String _require(String value, String name) {
    if (value.isEmpty) {
      throw ArgumentError('Missing --dart-define=$name=<value>');
    }
    return value;
  }
}
