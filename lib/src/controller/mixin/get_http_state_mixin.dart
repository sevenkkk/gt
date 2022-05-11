import 'package:gt/src/controller/model/view_state.dart';

mixin GetHttpStateMixin {
  /// 当前的页面状态,默认为busy,可在viewModel的构造方法中指定;
  ViewState _viewState = ViewState.idle;

  ViewState get viewState => _viewState;

  set viewState(ViewState viewState) {
    _viewState = viewState;
    update();
  }

  void update([List<Object>? ids, bool condition = true]);

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
}
