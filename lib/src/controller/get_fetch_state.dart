import 'package:get/get.dart';
import 'package:gt/src/config/gt.dart';
import 'package:gt/src/controller/mixin/get_http_state_mixin.dart';
import 'package:gt/src/net/http.dart';
import 'package:gt/src/net/result_data.dart';

abstract class GetFetchState<R> extends GetxController with GetHttpStateMixin {
  String? version;

  // 请求定义
  Future request(Http http);

  // 加载数据
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
  });

  // 刷新数据
  Future refreshData({bool setState});

  // 创建key
  createCacheKey(String key, {String? id, String? lang}) {
    return Gt.createCacheKey(key, id: id, lang: lang);
  }
}
