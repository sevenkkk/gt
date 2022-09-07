import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:gt/src/config/gt_config_processor.dart';
import 'package:gt/src/enum/active.dart';
import 'package:gt/src/net/http.dart';
import 'package:gt/src/utils/log_utils.dart';
import 'package:gt/src/utils/platform_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Gt {
  Gt._internal();

  static final Gt instance = Gt._internal();

  static BaseProcessor _config = BaseProcessor();

  static BaseProcessor get config => _config;

  static late Http http;
  static late String _baseUrl;

  static String get baseUrl => _baseUrl;

  static late String _auth = '';

  static String get auth => _auth;

  static late String _lang = '';

  static String get lang => _lang;

  static List<Interceptor>? _interceptors;
  static List<Interceptor>? get interceptors => _interceptors;

  static String? _headerExceptUri;

  static String? get headerExceptUri => _headerExceptUri;

  static setUp({
    BaseProcessor? config,
    String? baseUrl,
    List<Interceptor>? interceptors,
    String? headerExceptUri,
    String? lang,
  }) async {
    await deviceInfoInit();
    await sharedPreferencesInit();
    await connectivityInit();
    _baseUrl = baseUrl ?? '';
    _interceptors = interceptors;
    _headerExceptUri = headerExceptUri;
    if (lang != null) {
      _lang = lang;
    }
    http = Http();
    if (config != null) {
      _config = config;
    }
  }

  static setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  static setAuth(String auth) {
    _auth = auth;
  }

  static setLang(String lang) {
    _lang = lang;
  }

  /// 是否是生产环境
  static bool inProduction = const bool.fromEnvironment("dart.vm.product");

  /// ########################Connectivity#########################

  static Connectivity connectivityInstance = Connectivity();

  // 上一次网络状态
  static ConnectivityResult? _lastResult;

  static final _activeNetwork = StreamController<Active>.broadcast();

  static Stream<Active> get activeNetworkChange => _activeNetwork.stream;

  static bool get connectHasActive => !(_lastResult == ConnectivityResult.none || _lastResult == ConnectivityResult.ethernet);

  static connectivityInit() async {
    _lastResult = await connectivityInstance.checkConnectivity();
    connectivityInstance.onConnectivityChanged.listen((ConnectivityResult result) {
      // 从无网络到有网络
      if ((_lastResult == ConnectivityResult.none || _lastResult == ConnectivityResult.bluetooth) &&
          (result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi ||
              result == ConnectivityResult.ethernet)) {
        _activeNetwork.add(Active.yes);
        // 从有网络到无网络
      } else if ((result == ConnectivityResult.none || result == ConnectivityResult.bluetooth) &&
          (_lastResult == ConnectivityResult.mobile ||
              _lastResult == ConnectivityResult.wifi ||
              _lastResult == ConnectivityResult.ethernet)) {
        _activeNetwork.add(Active.no);
      }
      _lastResult = result;
    });
  }

  /// ########################Connectivity End#########################
  /// ########################DeviceInfo Start#########################
  // 设备信息
  static late String deviceInfo;

  // 设备id
  static late String deviceID;

  // 版本号
  static late String version;

  // 平台
  static late String platform;

  // 初始化设备信息
  static deviceInfoInit() async {
    if (kIsWeb) {
      deviceInfo = '';
      deviceID = '';
      version = '';
      platform = 'web';
    } else {
      // 获取设备信息
      deviceInfo = await PlatformUtils.getDeviceInfoStr();
      // 设备id
      deviceID = await PlatformUtils.getDeviceId();
      // 版本号
      version = await PlatformUtils.getAppVersion();
      // 平台
      platform = Platform.operatingSystem;
    }
  }

  /// ########################DeviceInfo End#########################

  /// ########################EventBus Start#########################

  static EventBus eventBus = EventBus();

  //返回某事件的订阅者
  static StreamSubscription<T> eventListen<T extends Event>(Function(T event) onData,
      {bool Function(T event)? condition}) {
    //内部流属于广播模式，可以有多个订阅者
    return eventBus.on<T>().listen((event) {
      if (condition != null) {
        if (condition(event)) {
          onData(event);
        }
      } else {
        onData(event);
      }
    });
  }

  //发送事件
  static void eventFire<T extends Event>(T e) {
    eventBus.fire(e);
  }

  /// ########################EventBus End#########################

  /// ########################SharedPreferences Start#########################

  /// 初始化必备操作 eg:user数据
  static late SharedPreferences prefs;

  static createCacheKey(String key, {String? id, String? lang, int version = 1}) {
    String prefix = 'key_${inProduction ? 'prod' : 'dev'}';
    if (id != null && lang != null) {
      return '${prefix}_${key}_${id}_${lang}_v$version';
    } else if (id != null) {
      return '${prefix}_${key}_${id}_v$version';
    } else if (lang != null) {
      return '${prefix}_${key}_${lang}_v$version';
    } else {
      return '${prefix}_${key}_v$version';
    }
  }

  /// 存储本地对象
  static Future<bool> setCacheItem<T>(String key, T? data) {
    if (data != null) {
      return prefs.setString(key, jsonEncode(data));
    } else {
      return delCacheItem(key);
    }
  }

  /// 获取本地对象
  static T? getCacheItem<T>(String key) {
    try {
      String? value = prefs.getString(key);
      if (value != null && value.isNotEmpty) {
        return Gt.config.serialize<T>(jsonDecode(value));
      }
    } catch (e) {
      LogUtils.tLog(e.toString());
    }
    return null;
  }

  /// 删除本地对象
  static Future<bool> delCacheItem<T>(String key) {
    return prefs.remove(key);
  }

  /// 获取本地列表
  static List<T> getCacheList<T>(String key) {
    return getCacheItem<List<T>>(key) ?? [];
  }

  /// 设置本地列表
  static Future<void> setCacheList<T>(String key, List<T> list) {
    return prefs.setString(key, jsonEncode(list));
  }

  /// 带有版本管理的存储
  /// 设置缓存对象
  static Future<bool> setCacheItemByVersion<T>(String key, T? data, {int? count, String? version, int? date}) {
    if (data != null) {
      final store = StoreCacheManage<T>(data: data, count: count, version: version, date: date);
      return prefs.setString(key, jsonEncode(store));
    } else {
      return delCacheItem(key);
    }
  }

  /// 带有版本管理的存储
  /// 获取缓存对象
  static StoreCacheManage<T>? getCacheItemByVersion<T>(String key) {
    try {
      String? value = prefs.getString(key);
      if (value != null && value.isNotEmpty) {
        return StoreCacheManage<T>.fromJson(jsonDecode(value));
      }
    } catch (e) {
      LogUtils.tLog('getCacheItem error:' + e.toString());
    }
    return null;
  }

  /// 带有版本管理的存储
  /// 设置缓存list
  static Future<bool> setCacheListByVersion<T>(String key, List<T> list, {int? count, String? version, int? date}) {
    return setCacheItemByVersion<List<T>>(key, list, count: count, version: version, date: date);
  }

  /// 带有版本管理的存储
  /// 获取缓存list
  static StoreCacheManage<List<T>>? getCacheListByVersion<T>(String key) {
    return getCacheItemByVersion<List<T>>(key);
  }

  /// 由于是同步操作会导致阻塞,所以应尽量减少存储容量
  static sharedPreferencesInit() async {
    prefs = await SharedPreferences.getInstance();
  }
}

abstract class Event {}

class StoreCacheManage<T> {
  T? data;
  int? count;
  String? version;
  int? milliseconds;

  StoreCacheManage({required this.data, this.version, this.count, int? date}) {
    milliseconds = date ?? DateTime.now().millisecondsSinceEpoch;
  }

  StoreCacheManage.fromJson(Map<String, dynamic> map) {
    data = Gt.config.serialize<T>(jsonDecode(map["data"]));
    count = map["count"];
    version = map["version"];
    milliseconds = map["milliseconds"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = jsonEncode(this.data);
    data['count'] = count;
    data['version'] = version;
    data['milliseconds'] = milliseconds;
    return data;
  }
}
