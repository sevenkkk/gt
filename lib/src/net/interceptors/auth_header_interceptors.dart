import 'package:dio/dio.dart';
import 'package:gt/gt.dart';
import 'package:gt/src/net/http_base.dart';

class AuthHeaderInterceptor extends InterceptorsWrapper {
  final authorization = 'Authorization';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 权限
    if (options.extra.containsKey(HttpBase.needAuthorizationKey) &&
        options.extra[HttpBase.needAuthorizationKey] == true) {
      if (!options.headers.containsKey(authorization)) {
        options.headers[authorization] = Gt.auth;
      }
    }
    super.onRequest(options, handler);
  }

}
