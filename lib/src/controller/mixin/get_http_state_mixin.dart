import 'package:get/get.dart';
import 'package:gt/src/controller/model/view_state.dart';

mixin GetHttpStateMixin {
  /// 当前的页面状态,默认为busy,可在viewModel的构造方法中指定;
  final Rx<ViewState> _viewState = ViewState.idle.obs;

  ViewState get viewState => _viewState.value;

  set viewState(ViewState viewState) {
    _viewState.value = viewState;
  }

  bool get busy => viewState == ViewState.busy;

  bool get idle => viewState == ViewState.idle;

  bool get empty => viewState == ViewState.empty;

  bool get error => viewState == ViewState.error;

  void setIdle() {
    viewState = ViewState.idle;
  }

  void setBusy() {
    viewState = ViewState.busy;
  }

  void setEmpty() {
    viewState = ViewState.empty;
  }

  void setError() {
    viewState = ViewState.error;
  }

  // 参数
  Map<String, dynamic>? mapParams;

  mergeMapParams(Map<String, dynamic> map) {
    mapParams?.addAll(map);
  }

  setMapParams(Map<String, dynamic> map) {
    mapParams = map;
  }
}
