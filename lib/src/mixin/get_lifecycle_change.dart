import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

mixin GetLifecycleChange on DisposableInterface, WidgetsBindingObserver {
  void paused() {}

  void resumed() {}

  @override
  void onInit() {
    // 从后台切换前台，列表更新
    WidgetsBinding.instance.addObserver(this);
    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      resumed();
    } else if (state == AppLifecycleState.paused) {
      // 从前台切换后台，取消心跳
      paused();
    }
    super.didChangeAppLifecycleState(state);
  }
}
