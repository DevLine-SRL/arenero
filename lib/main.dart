import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/providers/app_database_provider.dart';
import 'core/providers/last_seen_sync_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseUrl = AppConfig.supabaseUrl;
  final supabasePublishableKey = AppConfig.supabasePublishableKey;

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
    headers: {'apikey': supabasePublishableKey},
  );

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.watch(lastSeenSyncProvider);
    ref.watch(appDatabaseProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Arenero',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
