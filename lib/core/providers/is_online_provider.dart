import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connectivity_provider.dart';

part 'is_online_provider.g.dart';

@Riverpod(keepAlive: true)
bool isOnline(Ref ref) {
  final status = ref.watch(connectionStatusProvider).value;
  if (status == null) return true;
  return status == ConnectionStatus.online;
}
