import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final InternetConnection _checker = InternetConnection();
  final Connectivity _connectivity  = Connectivity();

  Stream<bool> get onConnectivityChanged async* {
    await for (final status in _checker.onStatusChange) {
      yield status == InternetStatus.connected;
    }
  }

  Future<bool> get isConnected async {
    return await _checker.hasInternetAccess;
  }
}
