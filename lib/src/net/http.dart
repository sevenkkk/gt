import 'package:dio/dio.dart';
import 'package:gt/src/config/gt.dart';
import 'package:gt/src/net/http_base.dart';

class Http extends HttpBase {
  @override
  String get baseUrl => Gt.baseUrl;

  @override
  List<Interceptor>? get interceptors => Gt.interceptors;
}
