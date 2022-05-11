import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gt/src/net/result_data.dart';
import 'package:gt/src/config/gt.dart';
import 'package:gt/src/utils/log_utils.dart';

abstract class AbstractProcessor {
  ResponseData transformResData(dynamic resp);

  ResultData<T> handleResError<T>(e, stackTrace, {Function(ResultData res)? errorCallback});

  void handleError(dynamic response, ResultData? result);

  String systemErrorMessage() {
    return 'The request failed. Please check the network!';
  }

  /// 开始loading
  startLoading();

  /// 结束loading
  endLoading();

  /// 错误提示
  showErrorMessage(String message, {required ResultData res});

  /// 成功提示
  showSuccessMessage(String message);

  /// 解析
  T? serialize<T>(dynamic payload);
}

class BaseProcessor extends AbstractProcessor {
  @override
  ResponseData transformResData(dynamic resp) {
    Map<String, dynamic> json = resp?.data ?? {};
    int? errorCode = json['errorCode'];
    String? errorMessage = json['errorMessage'];
    dynamic payload = json['payload'];
    bool success = json['success'] ?? false;
    int? count = json['count'];
    String? version = json['md5'];
    bool cache = json['cached'] ?? false;

    return ResponseData(
      errorCode: errorCode,
      message: errorMessage,
      payload: payload,
      success: success,
      count: count,
      version: version,
      cache: cache,
    );
  }

  @override
  void handleError(dynamic response, ResultData<dynamic>? result) {}

  @override
  ResultData<T> handleResError<T>(e, stackTrace, {Function(ResultData res)? errorCallback}) {
    int? errorCode;
    String? message;
    ResultData<T>? result;
    debugPrint(stackTrace.toString());
    if (e != null && e is DioError) {
      if (e.type == DioErrorType.response) {
        if (e.response?.statusCode == 400) {
          if (e.response?.data is Map) {
            result = ResultData<T>.fromError(e.response);
            message = result.message;
            errorCode = result.code;
            Gt.config.handleError(e.response, result);
          } else if (e.response?.data is String) {
            message = e.response?.data;
            errorCode = e.response?.statusCode;
          }
        } else if (e.response?.statusCode == 500) {
          errorCode = 500;
          message = Gt.config.systemErrorMessage();
        } else {
          errorCode = e.response?.statusCode;
        }
        Gt.config.handleError(e.response, result);
      } else {
        if (!const bool.fromEnvironment("dart.vm.product")) {
          throw e;
        }
      }
    } else if (e.type == DioErrorType.connectTimeout ||
        e.type == DioErrorType.sendTimeout ||
        e.type == DioErrorType.receiveTimeout) {
      message = 'Connection timeout';
    } else if (e.type == DioErrorType.other) {
      message = 'Unknown error';
    }

    result = ResultData(success: false, code: errorCode ?? -1000, message: message);
    LogUtils.tLog(result.toString());
    if (errorCallback != null) {
      errorCallback(result);
    }
    return result;
  }

  @override
  startLoading() {}

  @override
  endLoading() {}

  /// 错误提示
  @override
  showErrorMessage(String message, {required ResultData res}) {}

  /// 成功提示
  @override
  showSuccessMessage(String message) {}

  @override
  T? serialize<T>(payload) {
    return null;
  }
}
