import 'package:gt/src/controller/get_fetch_list.dart';
import 'package:gt/src/net/http_util.dart';
import 'package:gt/src/net/result_data.dart';

mixin LoadMoreMixin<R> on GetFetchList<R> {
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

  Map<String, dynamic> getPageParams() {
    return {}..addAll({'page': _currentPageNum, 'pageSize': pageSize});
  }

  pullRefresh(){
    
  }

  /// 上拉加载更多
  Future<ResultData> loadMore({Function? loadNoData, Function? loadComplete, Function? loadFailed}) async {
    ++_currentPageNum;
    ResultData<List<R>> res = await HttpUtils.request((http, {version}) => request(http));
    if (res.success) {
      if (res.payload!.isEmpty) {
        _currentPageNum--;
        if (loadNoData != null) loadNoData();
      } else {
        list.addAll(res.payload!);
        count = res.count ?? 0;
        if (list.length == count) {
          if (loadNoData != null) loadNoData();
        } else {
          if (loadComplete != null) loadComplete();
        }
      }
    } else {
      _currentPageNum--;
      if (loadFailed != null) loadFailed();
    }
    return res;
  }

}
