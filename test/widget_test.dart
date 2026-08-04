import 'package:flutter_test/flutter_test.dart';

import 'package:arenero/core/config/app_config.dart';

void main() {
  test('AppConfig throws when SUPABASE_URL is missing', () {
    expect(() => AppConfig.supabaseUrl, throwsArgumentError);
  });

  test('AppConfig throws when SUPABASE_PUBLISHABLE_KEY is missing', () {
    expect(() => AppConfig.supabasePublishableKey, throwsArgumentError);
  });
}
