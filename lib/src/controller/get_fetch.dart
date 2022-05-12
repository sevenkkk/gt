import 'package:get/get.dart';
import 'package:gt/gt.dart';

abstract class GetFetch<R> extends GetFetchState<R> {
  // 返回值
  late final Rx<R> _data = Rx<R>(initialData());

  R initialData();

  String? cacheKey;

  set data(R data) {
    _data.value = data;
  }

  R get data => _data.value;

  Rx<R> get obsData => _data;

  void onFetchSuccess(R? data) {}

  void onFetchFail(ResultData res) {}

  // 数据变化回调
  void onDataUpdateCallback(R? data, bool cache) {}

  @override
  Future<ResultData<R>> refreshData({
    bool setState = false,
    bool loading = false,
    bool showMessage = false,
    bool successMessage = false,
    bool errorMessage = false,
  }) {
    return load(setState: setState, loading: loading);
  }

  @override
  Future<ResultData<R>> load({
    Map<String, dynamic>? params,
    bool merge = true, // 是否合并参数，当params 有值时才生效
    bool cache = false,
    String? cacheID,
    bool defaultSet = true,
    bool setState = true,
    bool loading = false,
    bool showMessage = false,
    bool successMessage = false,
    bool errorMessage = false,
    Function(R data, bool cache)? dataCallback,
    Function(ResultData<R> res)? successCallback,
    Function(ResultData res)? errorCallback,
    Function(StoreCacheManage<R> cache)? cacheCallback,
  }) async {
    if (params != null) {
      if (merge) {
        mergeMapParams(params);
      } else {
        setMapParams(params);
      }
    }
    if (cache == true || cacheID != null) {
      cacheKey = createCacheKey((this).runtimeType.toString(), id: cacheID, lang: Gt.lang);
    }
    // 是否有本地数据
    bool _hasCache = false;
    return HttpUtils.request<R>(
      (http, {version}){
        this.version = version;
        return request(http);
      },
      loading: loading,
      showMessage: showMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      cacheKey: cacheKey,
      hasCacheCallback: (bool hasCache) {
        _hasCache = hasCache;
        if (!_hasCache && setState) {
          setBusy();
        }
      },
      cacheCallback: (StoreCacheManage<R> cache) {
        if (cacheCallback != null) {
          cacheCallback(cache);
        }
        // 如果存在缓存数据，先进行赋值
        if (defaultSet && cache.data != null) {
          data = cache.data!;
        }
      },
      dataUpdateCallback: (R data, bool cache) {
        if (dataCallback != null) {
          dataCallback(data, cache);
        }
        onDataUpdateCallback(data, cache);
      },
      errorCallback: (ResultData res) {
        if (setState) {
          setError();
        }
        if (errorCallback != null) {
          errorCallback(res);
        }
        onFetchFail(res);
      },
      successCallback: (ResultData<R> res) {
        if (setState) {
          setIdle();
        }
        // 如果是更新之后的数据，进行赋值
        if (!res.cache) {
          if (defaultSet && res.payload != null) {
            data = res.payload!;
          }
        }
        if (successCallback != null) {
          successCallback(res);
        }
        onFetchSuccess(res.payload);
      },
    );
  }
}
