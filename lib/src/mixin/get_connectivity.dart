import 'dart:async';

import 'package:get/get.dart';
import 'package:gt/gt.dart';

mixin GetConnectivity on DisposableInterface {
  StreamSubscription<Active>? _connectivitySub;

  void networkConnect() {}

  void networkDisconnect() {}

  @override
  void onInit() {
    _connectivitySub = Gt.activeNetworkChange.listen((Active active) {
      if (active == Active.yes) {
        networkConnect();
      } else {
        networkDisconnect();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }
}
