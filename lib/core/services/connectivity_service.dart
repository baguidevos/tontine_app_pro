import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  var isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      isConnected.value = results.any(
        (result) => result != ConnectivityResult.none,
      );
    });
  }
}
