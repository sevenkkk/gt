import 'package:get/get_rx/src/rx_types/rx_types.dart';

mixin GetParamMixin<P> {
  P intParams();

  // 请求参数
  late final Rx<P> _params = Rx<P>(intParams());

  set params(P params) {
    _params.value = params;
  }

  setParams(P params) {
    this.params = params;
    return this;
  }

  P get params => _params.value;

  Rx<P> get obsParams => _params;
}
