import 'package:dio/dio.dart';
import 'package:gt/gt.dart';
import 'package:gt/src/net/http_base.dart';

class VersionHeaderInterceptor extends InterceptorsWrapper {
  final md5 = 'md5';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if ((Gt.headerExceptUri != null && !options.path.contains(Gt.headerExceptUri!)) || Gt.headerExceptUri==null) {
      // 添加版管理 如果版本与服务端相同的情况下 不返回数据
      if (options.extra.containsKey(HttpBase.versionKey)) {
        if (!options.headers.containsKey(md5)) {
          options.headers[md5] = options.extra[HttpBase.versionKey] ?? '-1';
        }
      }
    }
    super.onRequest(options, handler);
  }
}
