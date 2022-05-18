import 'package:gt/gt.dart';
import 'package:gt/src/utils/log_utils.dart';

class HttpUtils {
  HttpUtils._();

  /// 请求封装
  static Future<ResultData<T>> request<T>(
    Future<dynamic> Function(Http http, {String? version}) fetch, {
    bool loading = false,
    bool showMessage = false,
    bool successMessage = false,
    bool errorMessage = false,
    String? cacheKey,
    // 是否有本地缓存回调
    Function(bool hasCache)? hasCacheCallback,
    // 本地缓存回调
    Function(StoreCacheManage<T> cache)? cacheCallback,
    // 数据变化回调, 如果有本地缓存先触发，如果数据有更新再会执行一次
    Function(T data, bool cache)? dataUpdateCallback,
    // 请求成功回调
    Function(ResultData<T> res)? successCallback,
    // 请求成功回调 附加缓存对象
    Function(ResultData<T> res, StoreCacheManage<T>? cache)? successCacheCallback,
    // 失败回调
    Function(ResultData res)? errorCallback,
  }) async {
    // 是否存在本地数据
    bool hasCache = false;
    try {
      // 如果有本地缓存的情况
      String? version;
      StoreCacheManage<T>? cacheStore;
      if (cacheKey != null) {
        cacheStore = Gt.getCacheItemByVersion<T>(cacheKey);
        if (cacheStore != null) {
          bool getHasCache() {
            if (cacheStore!.data != null) {
              if ((cacheStore.data is List && (cacheStore.data as List).isEmpty)) {
                return false;
              }
              return true;
            }
            return false;
          }

          hasCache = getHasCache();
          if (hasCacheCallback != null) {
            hasCacheCallback(hasCache);
          }
          version = cacheStore.version??'xxxxxxxx-xxxxx-xxxxxx';
          if (cacheCallback != null) {
            cacheCallback(cacheStore);
          }
          if (dataUpdateCallback != null) {
            dataUpdateCallback(cacheStore.data!, true);
          }
        } else {
          version = '-1';
          if (hasCacheCallback != null) {
            hasCacheCallback(hasCache);
          }
        }
      } else {
        if (hasCacheCallback != null) {
          hasCacheCallback(hasCache);
        }
      }
      if (loading && !hasCache) {
        Gt.config.startLoading();
      }
      var resp = await fetch(Gt.http, version: version);
      if (loading && !hasCache) {
        Gt.config.endLoading();
      }
      ResultData<T> result = ResultData<T>.fromJson(resp);
      if (dataUpdateCallback != null && result.payload != null) {
        dataUpdateCallback(result.payload!, false);
      }
      if (successCallback != null) {
        successCallback(result);
      }
      if (successCacheCallback != null) {
        successCacheCallback(result, cacheStore);
      }
      // 本地存储处理
      if (cacheKey != null && result.payload != null) {
        Gt.setCacheItemByVersion<T>(cacheKey, result.payload, count: result.count, version: result.version);
      }
      if (showMessage && successMessage) {
        if (result.payload is String) {
          Gt.config.showSuccessMessage(result.payload as String);
        } else {
          LogUtils.tLog('The return value is not of type string');
        }
      }
      return result;
    } catch (e, s) {
      if (loading && !hasCache) {
        Gt.config.endLoading();
      }

      final result = Gt.config.handleResError<T>(e, s, errorCallback: errorCallback);
      if (showMessage && errorMessage) {
        if (result.message != null && result.message!.isNotEmpty) {
          Gt.config.showErrorMessage(result.message!, res: result);
        } else {
          LogUtils.tLog('The error message is empty');
        }
      }
      return result;
    }
  }

  static Future<ResultData<T>> getCacheData<T>(
      {required String cacheKey, Future<dynamic> Function(Http http, {String? version})? fetch, refresh = true}) {
    final cache = Gt.getCacheItemByVersion<T>(cacheKey);
    if (cache != null && cache.data != null) {
      if (refresh && fetch != null) {
        HttpUtils.request<T>((http, {version}) => fetch(http, version: version), cacheKey: cacheKey);
      }
      return Future.value(ResultData<T>(success: true)..payload = cache.data);
    } else if (fetch != null) {
      return HttpUtils.request<T>((http, {version}) => fetch(http, version: version), cacheKey: cacheKey);
    }
    return Future.value(ResultData<T>(success: false));
  }

  /// 提交时使用
  static Future<ResultData<T>> submit<T>(
    Future<dynamic> Function(Http http) fetch, {
    Function(ResultData<T> res)? successCallback,
    Function(ResultData res)? errorCallback,
    bool loading = true,
    bool showMessage = true,
    bool successMessage = true,
    bool errorMessage = true,
  }) {
    return request<T>((http, {version}) => fetch(http),
        successCallback: successCallback,
        errorCallback: errorCallback,
        loading: loading,
        showMessage: showMessage,
        successMessage: successMessage,
        errorMessage: errorMessage);
  }
}
