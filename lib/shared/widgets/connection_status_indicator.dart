import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/connectivity_provider.dart';

class ConnectionStatusIndicator extends ConsumerWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionStatusProvider).value;

    final (icon, color, tooltip) = switch (status) {
      ConnectionStatus.online => (
        Icons.wifi_rounded,
        Colors.green,
        'Conectado con datos o WiFi',
      ),
      ConnectionStatus.noInternet => (
        Icons.wifi_tethering_error_rounded,
        Colors.orange,
        'Conectado a una red, pero sin acceso a internet',
      ),
      ConnectionStatus.offline || null => (
        Icons.wifi_off_rounded,
        Colors.red,
        'Sin red WiFi ni datos',
      ),
    };

    return Tooltip(
      message: tooltip,
      child:  Icon(icon, size: 22, color: color),
    );
  }
}
