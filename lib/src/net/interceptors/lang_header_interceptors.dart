import 'package:dio/dio.dart';
import 'package:gt/gt.dart';
import 'package:gt/src/net/http_base.dart';

class LangHeaderInterceptor extends InterceptorsWrapper {
  final lang = 'lang';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (Gt.headerExceptUri != null && !options.path.contains(Gt.headerExceptUri!)) {
      options.headers[lang] = options.extra.containsKey(HttpBase.langKey) ? options.extra[HttpBase.langKey] : Gt.lang;
    }
    super.onRequest(options, handler);
  }
}
