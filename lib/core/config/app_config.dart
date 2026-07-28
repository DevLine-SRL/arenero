abstract final class AppConfig {
  static String get supabaseUrl => _require(
    const String.fromEnvironment('SUPABASE_URL'),
    'SUPABASE_URL',
  );

  static String get supabasePublishableKey => _require(
    const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static String _require(String value, String name) {
    if (value.isEmpty) {
      throw ArgumentError('Missing --dart-define=$name=<value>');
    }
    return value;
  }
}
