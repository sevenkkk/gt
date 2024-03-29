import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gt/gt.dart';
import 'package:gt/src/net/interceptors/auth_header_interceptors.dart';
import 'package:gt/src/net/interceptors/custom_log_interceptors.dart';

abstract class HttpBase {
  static const needAuthorizationKey = "needAuthorization";
  static const authorization = "authorization";
  static const needEncrypt = "needEncrypt";
  static const langKey = "lang";
  static const versionKey = "version";

  late Dio _dio;
  CancelToken cancelToken = CancelToken();
  CancelToken downloadCancelToken = CancelToken();

  List<Interceptor>? get interceptors;

  String get baseUrl;

  HttpBase() {
    _dio = Dio();
    _dio.options.connectTimeout = 20000;
    _dio.options.receiveTimeout = 20000;
    if (!kIsWeb) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) {
          return true;
        };
      };
    }
    _addInterceptor();
  }

  void cancelAll() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel();
    }
  }

  /// 添加拦截器
  void _addInterceptor() {
    if (interceptors != null && interceptors!.isNotEmpty) {
      interceptors?.forEach((element) {
        _dio.interceptors.add(element);
      });
    }
    _dio.interceptors.add(AuthHeaderInterceptor());
    if (!Gt.inProduction) {
      _dio.interceptors.add(CustomLogInterceptor());
    }
  }

  Response _process(Response response) {
    //如果需要在解析前处理数据，则在这处理
    return response;
  }

  Future<Response?> get(
    String path, {
    String? baseUrl,
    Map<String, dynamic>? params,
    Options? options,
    bool needRethrow = true,
    bool needAuth = false,
    String? auth,
    bool encrypt = false,
    bool cancel = true,
    String? lang,
    String? version,
  }) async {
    final finalOptions = options ?? Options();
    finalOptions.extra ??= {};
    finalOptions.extra?[needAuthorizationKey] = needAuth;
    finalOptions.extra?[authorization] = auth;
    finalOptions.extra?[needEncrypt] = encrypt;
    if (lang != null) {
      finalOptions.extra?[langKey] = lang;
    }
    if (version != null) {
      finalOptions.extra?[versionKey] = version;
    }
    try {
      var url = (baseUrl ?? this.baseUrl) + (path.substring(0, 1) == '/' ? path : '/' + path);
      Response response = await _dio.get(
        url,
        queryParameters: params,
        options: finalOptions,
        cancelToken: cancel ? cancelToken : null,
      );

      return _process(response);
    } on DioError catch (e, _) {
      if (needRethrow) {
        rethrow;
      } else {
        return null;
      }
    }
  }

  Future<Response?> post(
    String path, {
    String? baseUrl,
    dynamic data,
    Options? options,
    bool needRethrow = true,
    bool needAuth = false,
    String? auth,
    bool encrypt = false,
    bool cancel = true,
    String? lang,
    String? version,
  }) async {
    final finalOptions = options ?? Options();
    finalOptions.extra ??= {};
    finalOptions.extra?[needAuthorizationKey] = needAuth;
    finalOptions.extra?[authorization] = auth;
    finalOptions.extra?[needEncrypt] = encrypt;
    if (lang != null) {
      finalOptions.extra?[langKey] = lang;
    }
    if (version != null) {
      finalOptions.extra?[versionKey] = version;
    }
    try {
      var url = (baseUrl ?? this.baseUrl) + (path.substring(0, 1) == '/' ? path : '/' + path);
      var response = await _dio.post(
        url,
        data: data,
        options: finalOptions,
        cancelToken: cancel ? cancelToken : null,
      );

      return _process(response);
    } on DioError catch (e, _) {
      if (needRethrow) {
        rethrow;
      } else {
        return null;
      }
    }
  }

  Future<Response?> put(
    String path, {
    String? baseUrl,
    dynamic data,
    Options? options,
    bool needRethrow = true,
    bool needAuth = false,
    String? auth,
    bool encrypt = false,
    String? lang,
    String? version,
  }) async {
    final finalOptions = options ?? Options();
    finalOptions.extra ??= {};
    finalOptions.extra?[needAuthorizationKey] = needAuth;
    finalOptions.extra?[authorization] = auth;
    finalOptions.extra?[needEncrypt] = encrypt;
    if (lang != null) {
      finalOptions.extra?[langKey] = lang;
    }
    if (version != null) {
      finalOptions.extra?[versionKey] = version;
    }
    try {
      var url = (baseUrl ?? this.baseUrl) + (path.substring(0, 1) == '/' ? path : '/' + path);
      var response = await _dio.put(
        url,
        data: data,
        options: finalOptions,
        cancelToken: cancelToken,
      );

      return _process(response);
    } on DioError catch (e, _) {
      if (needRethrow) {
        rethrow;
      } else {
        return null;
      }
    }
  }

  Future<Response?> delete(
    String path, {
    String? baseUrl,
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? options,
    bool needRethrow = true,
    bool needAuth = false,
    String? auth,
    bool encrypt = false,
    String? lang,
    String? version,
  }) async {
    final finalOptions = options ?? Options();
    finalOptions.extra ??= {};
    finalOptions.extra?[needAuthorizationKey] = needAuth;
    finalOptions.extra?[authorization] = auth;
    finalOptions.extra?[needEncrypt] = encrypt;
    if (lang != null) {
      finalOptions.extra?[langKey] = lang;
    }
    if (version != null) {
      finalOptions.extra?[versionKey] = version;
    }
    try {
      var url = (baseUrl ?? this.baseUrl) + (path.substring(0, 1) == '/' ? path : '/' + path);
      Response response = await _dio.delete(
        url,
        queryParameters: params,
        data: data,
        options: finalOptions,
        cancelToken: cancelToken,
      );
      return _process(response);
    } on DioError catch (e, _) {
      if (needRethrow) {
        rethrow;
      } else {
        return null;
      }
    }
  }

  Future<Response?> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool needRethrow = true,
    bool needAuth = false,
    String? auth,
    bool cancel = true,
  }) async {
    final finalOptions = options ?? Options();
    finalOptions.extra ??= {};
    finalOptions.extra?[needAuthorizationKey] = needAuth;
    finalOptions.extra?[authorization] = auth;
    try {
      var response = await Dio().download(
        url,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );

      return _process(response);
    } on DioError catch (e, _) {
      if (needRethrow) {
        rethrow;
      } else {
        return null;
      }
    }
  }
}
