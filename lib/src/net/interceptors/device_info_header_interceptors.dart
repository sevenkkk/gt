import 'package:dio/dio.dart';
import 'package:gt/gt.dart';

class DeviceInfoHeaderInterceptor extends InterceptorsWrapper {
  final version = 'version';
  final platform = 'platform';
  final deviceID = 'udid';
  final deviceInfo = 'device_info';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if ((Gt.headerExceptUri != null && !options.path.contains(Gt.headerExceptUri!)) || Gt.headerExceptUri==null) {
      options.headers[version] = Gt.version;
      options.headers[platform] = Gt.platform;
      options.headers[deviceID] = Gt.deviceID;
      options.headers[deviceInfo] = Gt.deviceInfo;
    }
    super.onRequest(options, handler);
  }
}
