## 初始化
```dart
main() async {
  // 初始化
  await Gt.setUp(
      config: MyProcessor(),
      interceptors: [LangHeaderInterceptor(), DeviceInfoHeaderInterceptor(), VersionHeaderInterceptor()],
      headerExceptUri: getBaseDomainUrl,
      lang: fallbackLocale.languageCode
  );
  
  runApp(const MyApp());
}
```

## 自定义实现类
```dart
class MyProcessor extends BaseProcessor {
  @override
  void handleError(dynamic response, ResultData<dynamic>? result) async {
    if (response?.statusCode == 401 && AuthService.to.hasAuth) {
      AccessUtils.handleLogout(passive: true);
    }
  }

  @override
  startLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      EasyLoading.show();
    });
  }

  @override
  endLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      EasyLoading.dismiss();
    });
  }

  @override
  showErrorMessage(String message, {required ResultData res}) {
    Future.delayed(const Duration(seconds: 0), () {
      MyToastUtils.showErrorMessage(message);
    });
  }

  @override
  showSuccessMessage(String message) {
    Future.delayed(const Duration(seconds: 0), () {
      MyToastUtils.showSuccessMessage(message);
    });
  }

  static Type typeOf<T>() => T;

  @override
  T? serialize<T>(payload) {
    if (payload != null) {
      if (payload is List || payload is Map) {
        if (typeOf<T>() == typeOf<dynamic>()) {
          return payload as T;
        }
        if (typeOf<T>() == typeOf<List<String>>()) {
          return (payload as List).map((e) => e as String).toList() as T;
        }
        if (typeOf<T>() == typeOf<List<num>>()) {
          return (payload as List).map((e) => e as num).toList() as T;
        }
        if (typeOf<T>() == typeOf<List<int>>()) {
          return (payload as List).map((e) => e as int).toList() as T;
        }
        return JsonConvert.fromJsonAsT<T>(payload);
      } else {
        return payload as T;
      }
    } else {
      return null;
    }
  }

}
```
