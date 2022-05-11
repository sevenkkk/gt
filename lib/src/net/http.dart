import 'package:dio/dio.dart';
import 'package:gt/src/config/gt.dart';
import 'package:gt/src/net/http_base.dart';

class Http extends HttpBase {

  Http({List<Interceptor>? interceptors}) {
    super.interceptors = interceptors;
  }

  @override
  String get baseUrl => Gt.baseUrl;

}
