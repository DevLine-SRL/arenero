import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client_provider.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref _) => Supabase.instance.client;
