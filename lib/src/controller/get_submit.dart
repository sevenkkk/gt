import 'package:get/get.dart';
import 'package:gt/gt.dart';

abstract class GetSubmitResult<R> extends GetxController with GetHttpStateMixin {
  R initialData();

  // 返回值
  late final Rx<R> _data = Rx<R>(initialData());

  set data(R data) {
    _data.value = data;
  }

  R get data => _data.value;

  Future request(Http http);

  void onFetchSuccess(R? data) {}

  void onFetchFail(ResultData res) {}

  Future<ResultData<R>> submit({
    Map<String, dynamic>? params,
    bool merge = true, // 是否合并参数，当params 有值时才生效
    bool showMessage = true,
    bool loading = true,
    bool successMessage = true,
    bool errorMessage = true,
    Function(ResultData<R> res)? successCallback,
    Function(ResultData res)? errorCallback,
  }) async {
    if (params != null) {
      if (merge) {
        mergeMapParams(params);
      } else {
        setMapParams(params);
      }
    }

    return HttpUtils.submit(
      (http) => request(http),
      loading: loading,
      showMessage: showMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      errorCallback: (ResultData res) {
        onFetchFail(res);
        if (errorCallback != null) {
          errorCallback(res);
        }
      },
      successCallback: (ResultData<R> res) {
        if (res.payload != null) {
          data = res.payload!;
        }
        onFetchSuccess(res.payload);
        if (successCallback != null) {
          successCallback(res);
        }
      },
    );
  }
}

abstract class GetSubmit extends GetxController with GetHttpStateMixin {

  Future request(Http http);

  void onFetchSuccess(String? data) {}

  void onFetchFail(ResultData res) {}

  Future<ResultData<String>> submit({
    Map<String, dynamic>? params,
    bool merge = true, // 是否合并参数，当params 有值时才生效
    bool showMessage = true,
    bool loading = true,
    bool successMessage = true,
    bool errorMessage = true,
    Function(ResultData<String> res)? successCallback,
    Function(ResultData res)? errorCallback,
  }) async {
    if (params != null) {
      if (merge) {
        mergeMapParams(params);
      } else {
        setMapParams(params);
      }
    }
    return HttpUtils.submit(
      (http) => request(http),
      loading: loading,
      showMessage: showMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      errorCallback: (ResultData res) {
        onFetchFail(res);
        if (errorCallback != null) {
          errorCallback(res);
        }
      },
      successCallback: (ResultData<String> res) {
        onFetchSuccess(res.payload);
        if (successCallback != null) {
          successCallback(res);
        }
      },
    );
  }
}
