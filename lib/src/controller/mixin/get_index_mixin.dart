import 'package:get/get.dart';

mixin GetIndexMixin<T> {
  List<T> get indexList;

  final Rx<int> _index = 0.obs;

  int get index => _index.value;

  Rx<int> get obsIndex => _index;

  set index(int index) {
    _index.value = index;
  }

  T? get active => indexList.isNotEmpty && index >= 0 && index < indexList.length ? indexList[index] : null;
}
