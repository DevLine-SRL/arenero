import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

enum ConnectionStatus { online, noInternet, offline }

@Riverpod(keepAlive: true)
Stream<ConnectionStatus> connectionStatus(Ref _) async* {
  final connectivity = Connectivity();
  final internetChecker = InternetConnection.createInstance(
    checkInterval: const Duration(seconds: 1),
  );

  var hasNetwork = _hasNetwork(await connectivity.checkConnectivity());
  var hasInternet = await internetChecker.hasInternetAccess;
  final initial = _resolve(hasNetwork, hasInternet);
  developer.log('Connectivity: $initial', name: 'offline');
  yield initial;

  final controller = StreamController<ConnectionStatus>();

  void compute({bool? network, bool? internet}) {
    hasNetwork = network ?? hasNetwork;
    hasInternet = internet ?? hasInternet;
    final status = _resolve(hasNetwork, hasInternet);
    developer.log('Connectivity: $status', name: 'offline');
    controller.add(status);
  }

  late final StreamSubscription<List<ConnectivityResult>> networkSub;
  late final StreamSubscription<InternetStatus> internetSub;

  try {
    networkSub = connectivity.onConnectivityChanged.listen(
      (results) => compute(network: _hasNetwork(results)),
    );
    internetSub = internetChecker.onStatusChange.listen(
      (status) => compute(internet: status == InternetStatus.connected),
    );

    await for (final status in controller.stream) {
      yield status;
    }
  } finally {
    await networkSub.cancel();
    await internetSub.cancel();
    await controller.close();
  }
}

ConnectionStatus _resolve(bool hasNetwork, bool hasInternet) {
  if (hasInternet) return ConnectionStatus.online;
  if (hasNetwork) return ConnectionStatus.noInternet;
  return ConnectionStatus.offline;
}

bool _hasNetwork(List<ConnectivityResult> results) {
  return results.any(
    (result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet,
  );
}
