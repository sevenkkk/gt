import 'package:gt/src/config/gt.dart';

class ResultData<T> {
  int? code;
  String? message;
  bool success = true;
  T? payload;
  int? count;
  String? version;
  late bool cache;

  ResultData({
    required this.success,
    this.code = 0,
    this.message = '',
    this.cache = false,
  });

  ResultData.fromJson(dynamic resp) {
    ResponseData resData = Gt.config.transformResData(resp);
    code = resData.errorCode;
    message = resData.message;
    payload = Gt.config.serialize<T>(resData.payload);
    success = resData.success;
    count = resData.count;
    version = resData.version;
    cache = resData.cache;
  }

  ResultData.fromError(dynamic resp) {
    ResponseData resData = Gt.config.transformResData(resp);
    code = resData.errorCode;
    message = resData.message;
    success = resData.success;
    version = null;
    cache = false;
  }

  @override
  String toString() {
    return '{success: $success, code: $code, message: $message, count: $count, version: $version, payload: ${payload.toString()}}';
  }
}

class ResponseData {
  int? errorCode;
  String? message;
  bool success;
  dynamic payload;
  int? count;
  String? version;
  bool cache;

  ResponseData({
    required this.errorCode,
    required this.message,
    required this.success,
    required this.payload,
    this.count,
    this.version,
    required this.cache,
  });
}
