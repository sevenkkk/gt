import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

class CustomLogInterceptor extends InterceptorsWrapper {
  void _log(String content) {
    log(content, name: "http", time: DateTime.now());
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data is! FormData) {
      _log('''
>>>>>>>>>>>>>> Req uri: ${options.uri.toString()} header：${options.headers} params：${options.data} <<<<<<<<<<<<<<''');
    } else {
      FormData data = options.data;
      _log('''
>>>>>>>>>>>>>> Req uri: ${options.uri.toString()} header：${options.headers} params：${data.fields} files：${data.files.map((e) => e.key).join(", ")} <<<<<<<<<<<<<<''');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('''
>>>>>>>>>>>>>> Res uri: ${response.realUri} <<<<<<<<<<<<<<
${json.encode(response.data)}
>>>>>>>>>>>>>> Res end <<<<<<<<<<<<<<
        ''');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError e, ErrorInterceptorHandler handler) {
    _log('''
<<<<<<<<<<<<error<<<<<<<<<<<<<<
   ${e.requestOptions.uri}, ${e.message}, ${e.stackTrace?.toString()}
<<<<<<<<<<<<error<<<<<<<<<<<<<<
        ''');
    super.onError(e, handler);
  }
}
