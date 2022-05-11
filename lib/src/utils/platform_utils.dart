import 'dart:io';
import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';

/// 是否是生产环境
const bool inProduction = bool.fromEnvironment("dart.vm.product");

class PlatformUtils {
  static Future<PackageInfo> getAppPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String> getBuildNum() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  static Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      return '';
    }
  }

  static Future getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      return await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      return await deviceInfo.iosInfo;
    } else {
      return null;
    }
  }

  static Future<String> getDeviceInfoStr() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await deviceInfo.androidInfo;
      return '${android.brand} ${android.model} ${android.device} ${android.version.release}';
    } else if (Platform.isIOS) {
      IosDeviceInfo ios = await deviceInfo.iosInfo;
      return '${ios.utsname.machine} ${ios.systemName} ${ios.model} ${ios.systemVersion}';
    } else {
      return '';
    }
  }
}
