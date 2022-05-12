import 'package:get/get.dart';
import 'package:gt/gt.dart';

abstract class GetFetchList<R> extends GetFetchState<List<R>> {
  // 返回值
  final RxList<R> _list = <R>[].obs;

  set list(List<R> list) {
    _list.value = list;
  }

  RxList<R> get obsList => _list;

  List<R> get list => _list;

  String? cacheKey;

  // 请求数据成功回调
  void onFetchSuccess(List<R> list) {}

  // 请求数据失败回调
  void onFetchFail(ResultData res) {}

  // 设置数据回调
  void onDataUpdateCallback(List<R> list, bool cache) {}

  @override
  Future<ResultData<List<R>>> refreshData({
    bool setState = false,
    bool loading = false,
    bool showMessage = false,
    bool successMessage = false,
    bool errorMessage = false,
  }) {
    return load(
      setState: setState,
      loading: loading,
      showMessage: showMessage,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  Future<ResultData<List<R>>> load({
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
    Function(List<R> list, bool cache)? dataUpdateCallback,
    Function(ResultData<List<R>> res)? successCallback,
    Function(ResultData<List<R>> res, StoreCacheManage<List<R>>? cache)? successCacheCallback,
    Function(ResultData res)? errorCallback,
    Function(StoreCacheManage<List<R>> cache)? cacheCallback,
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
    return HttpUtils.request(
      (http, {version}) {
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
      cacheCallback: (StoreCacheManage<List<R>> cache) {
        if (cacheCallback != null) {
          cacheCallback(cache);
        }
        if (defaultSet && list.length != (cache.data ?? []).length) {
          list = cache.data ?? [];
        }
      },
      dataUpdateCallback: (List<R> list, bool cache) {
        if (dataUpdateCallback != null) {
          dataUpdateCallback(list, cache);
        }
        onDataUpdateCallback(list, cache);
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
      successCallback: (ResultData<List<R>> res) {
        if (successCallback != null) {
          successCallback(res);
        }
        onFetchSuccess(res.payload ?? []);
      },
      successCacheCallback: (ResultData<List<R>> res, StoreCacheManage<List<R>>? cache) {
        if (!res.cache) {
          if (res.payload == null || (res.payload != null && res.payload!.isEmpty)) {
            setEmpty();
          } else {
            setIdle();
          }
        } else {
          if (cache != null && cache.data != null && cache.data!.isEmpty) {
            setEmpty();
          } else {
            setIdle();
          }
        }
        // 如果是更新之后的数据，进行赋值
        if (!res.cache) {
          if (defaultSet) {
            list = res.payload ?? [];
          }
        }
        if (successCacheCallback != null) {
          successCacheCallback(res, cache);
        }
      },
    );
  }
}
