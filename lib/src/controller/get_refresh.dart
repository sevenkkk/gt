import 'package:gt/gt.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

abstract class GetRefresh<R> extends GetFetchList<R> {
  /// 分页第一页页码
  static const int pageNumFirst = 1;

  /// 分页条目数量
  int pageSize = 30;

  /// 返回数据总数
  int count = 0;

  /// 是否可以分页
  bool enablePullUp = false;

  /// 当前页码
  int _currentPageNum = pageNumFirst;

  late final RefreshController refreshController;

  @override
  void onInit() {
    refreshController = RefreshController(initialRefresh: false);
    super.onInit();
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
    return pullRefresh(
      params: params,
      merge: merge,
      cacheID: cacheID,
      cache: cache,
      setState: true,
      loading: loading,
      showMessage: showMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      dataUpdateCallback: dataUpdateCallback,
      successCallback: successCallback,
      successCacheCallback: successCacheCallback,
      errorCallback: errorCallback,
      cacheCallback: cacheCallback,
    );
  }

  @override
  Future<ResultData<List<R>>> refreshData({
    bool setState = false,
    bool loading = false,
    bool showMessage = false,
    bool successMessage = false,
    bool errorMessage = false,
  }) async {
    return pullRefresh(
      setState: setState,
      loading: loading,
      showMessage: showMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      refresh: true,
    );
  }

  Future<ResultData<List<R>>> pullRefresh({
    Map<String, dynamic>? params,
    bool merge = true, // 是否合并参数，当params 有值时才生效
    bool cache = false,
    String? cacheID,
    bool setState = false,
    bool loading = false,
    bool showMessage = false,
    bool successMessage = false,
    bool errorMessage = false,
    bool refresh = false,
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
    enablePullUp = false;
    update();
    _currentPageNum = pageNumFirst;
    refreshController.resetNoData();
    // 是否有本地数据
    bool _hasCache = false;
    ResultData<List<R>> res = await HttpUtils.request(
      (http, {version}) {
        this.version = version;
        return request(http);
      },
      loading: loading,
      showMessage: showMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      cacheKey: refresh ? null : cacheKey,
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
        if (list.length != (cache.data ?? []).length) {
          list = cache.data ?? [];
          count = cache.count ?? 0;
          refreshController.refreshCompleted();
          // 可以上拉加载更多
          if (count > list.length) {
            enablePullUp = true;
            update();
            // 防止上次上拉加载更多失败,需要重置状态
            refreshController.loadComplete();
          }
        }
      },
      dataUpdateCallback: (List<R> list, bool cache) {
        if (dataUpdateCallback != null) {
          dataUpdateCallback(list, cache);
        }
        onDataUpdateCallback(list, cache);
      },
      errorCallback: (ResultData res) {
        if (!_hasCache && setState) {
          setError();
        }
        if (errorCallback != null) {
          errorCallback(res);
        }
        refreshController.refreshFailed();
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
          if (res.payload!.isEmpty) {
            refreshController.refreshCompleted(resetFooterState: true);
            setEmpty();
          } else {
            setIdle();
          }
        } else {
          if (cache != null && cache.data != null && cache.data!.isEmpty) {
            refreshController.refreshCompleted(resetFooterState: true);
            setEmpty();
          } else {
            setIdle();
          }
        }
        // 如果是更新之后的数据，进行赋值
        if (!res.cache) {
          list = res.payload ?? [];
          count = res.count ?? 0;
          refreshController.refreshCompleted();
          // 可以上拉加载更多
          if (count > list.length) {
            enablePullUp = true;
            update();
            // 防止上次上拉加载更多失败,需要重置状态
            refreshController.loadComplete();
          }
        }
        if (successCacheCallback != null) {
          successCacheCallback(res, cache);
        }
      },
    );
    return res;
  }

  /// 上拉加载更多
  Future<ResultData> loadMore() async {
    ++_currentPageNum;
    ResultData<List<R>> res = await HttpUtils.request((http, {version}) => request(http));
    if (res.success) {
      if (res.payload!.isEmpty) {
        _currentPageNum--;
        refreshController.loadNoData();
      } else {
        list.addAll(res.payload!);
        onFetchSuccess(res.payload!);
        onDataUpdateCallback(list, false);
        count = res.count ?? 0;
        if (list.length == count) {
          refreshController.loadNoData();
        } else {
          refreshController.loadComplete();
        }
      }
    } else {
      _currentPageNum--;
      refreshController.loadFailed();
    }
    return res;
  }

  Map<String, dynamic> getPageParams() {
    return {}..addAll({'page': _currentPageNum, 'pageSize': pageSize});
  }

  @override
  void onClose() {
    refreshController.dispose();
  }
}
