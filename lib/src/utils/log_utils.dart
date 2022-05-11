import 'dart:developer';

class LogUtils {
  static void tLog(String content) {
    log(content, name: "gt", time: DateTime.now());
  }
}
