// ignore_for_file: empty_catches, avoid_print, constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bujuan/core/platform/platform_utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../endpoints/dj/api.dart';
import '../endpoints/event/api.dart';
import '../endpoints/login/api.dart';
import '../endpoints/play/api.dart';
import '../endpoints/search/api.dart';
import '../endpoints/uncategorized/api.dart';
import '../endpoints/user/api.dart';
import '../models/common/bean.dart';
import 'dio_ext.dart';
import 'netease_bean.dart';
import 'netease_handler.dart';

/// 网易云音乐 SDK 入口，组合登录、播放、搜索、用户等接口 mixin。
class NeteaseMusicApi
    with
        ApiPlay,
        ApiDj,
        ApiLogin,
        ApiUser,
        ApiEvent,
        ApiSearch,
        ApiUncategorized {
  static NeteaseMusicApi? _neteaseMusicApi;

  /// 当前全局 Cookie 管理器。
  static late CookieManager cookieManager;

  /// SDK 文件路径提供器。
  static late PathProvider pathProvider;

  /// 登录状态控制器。
  UserLoginStateController usc = UserLoginStateController();

  /// 初始化 SDK 存储路径、Cookie 和 Dio 拦截器。
  static Future<bool> init({
    PathProvider? provider,
    bool debug = false,
    bool logResponseBody = false,
  }) async {
    // 初始化 pathProvider
    pathProvider = provider ?? PathProvider();
    await pathProvider.init();
    // 初始化 cookieManager
    cookieManager = CookieManager(PersistCookieJar(
        storage: FileStorage(pathProvider.getCookieSavedPath())));
    // 初始化 dio
    _initDio(Https.dio, debug, true, logResponseBody);
    return true;
  }

  static Dio _initDio(
    Dio dio,
    bool debug,
    bool refreshToken,
    bool logResponseBody,
  ) {
    dio.interceptors.add(cookieManager);
    // Dio日志拦截器
    if (debug) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: logResponseBody,
        error: true,
        compact: true,
        maxWidth: 100,
      ));
    }
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: neteaseInterceptor,
        onResponse:
            (Response response, ResponseInterceptorHandler handler) async {
          var requestOptions = response.requestOptions;

          if (response.data is String) {
            try {
              response.data = jsonDecode(response.data);
            } catch (e) {}
          }
          if (refreshToken &&
              NeteaseMusicApi().usc.isLogined &&
              response.data is Map) {
            var result = ServerStatusBean.fromJson(response.data);
            // 1. token已经更新，请求重试
            // 2. token未更新
            //    刷新token
            //    1. 刷新成功，请求重试
            //    2. 刷新失败，登录态切换
            if (result.code == RET_CODE_NEED_LOGIN) {
              try {
                if (requestOptions.extra['cookiesHash'] !=
                    await loadCookiesHash()) {
                  var newResponse = await dio.fetch(requestOptions);
                  handler.next(newResponse);
                  return;
                }
                // dio.lock();
                var refreshResult = await NeteaseMusicApi().loginRefresh(
                    dio: _initDio(
                  Dio(),
                  debug,
                  false,
                  logResponseBody,
                ));
                // dio.unlock();
                if (refreshResult.code == RET_CODE_OK) {
                  var newResponse = await dio.fetch(requestOptions);
                  handler.next(newResponse);
                  return;
                }
              } finally {
                // dio.unlock();
              }
              await NeteaseMusicApi().usc.onLogout();
            }
          }

          handler.next(response);
        }));

    return dio;
  }

  NeteaseMusicApi._internal() {
    usc.init();
  }

  /// 获取全局 SDK 单例。
  factory NeteaseMusicApi() {
    return _neteaseMusicApi ??= NeteaseMusicApi._internal();
  }
}

/// SDK 内部登录态控制器，负责缓存账号信息并广播登录态变化。
class UserLoginStateController {
  LoginState? _curLoginState;

  StreamController? _controller;

  /// 创建登录态控制器。
  UserLoginStateController();

  /// 初始化本地账号缓存和登录态。
  Future<void> init() async {
    _checkCreateSavePath();
    await _readAccountInfo();
    _refreshLoginState((await loadCookies()).isNotEmpty && _accountInfo != null
        ? LoginState.Logined
        : LoginState.Logout);
  }

  NeteaseAccountInfoWrap? _accountInfo;

  /// 当前缓存的账号信息。
  NeteaseAccountInfoWrap? get accountInfo {
    return _accountInfo;
  }

  AnonimousLoginRet? _anonimousLoginRet;

  /// 匿名登录结果；正式账号登录后会自动清空。
  AnonimousLoginRet? get anonimousLoginInfo {
    if (accountInfo != null) {
      _anonimousLoginRet = null;
    }
    return _anonimousLoginRet;
  }

  /// 当前是否处于正式登录态。
  bool get isLogined {
    return _curLoginState == LoginState.Logined;
  }

  /// 监听登录态变化并携带当前账号信息。
  StreamSubscription listenLoginState(
      void Function(LoginState event, NeteaseAccountInfoWrap? accountInfoWrap)
          onChange) {
    var controller = _controller;
    if (controller == null) {
      _controller = controller = StreamController.broadcast(sync: true);
    }
    return controller.stream.listen((t) {
      onChange(t, accountInfo);
    });
  }

  /// 标记账号已登录并持久化账号信息。
  void onLogined(NeteaseAccountInfoWrap infoWrap) {
    _accountInfo = infoWrap;
    _refreshLoginState(LoginState.Logined);
    _saveAccountInfo(infoWrap);
  }

  /// 标记匿名登录信息。
  void onAnonimousLogined(AnonimousLoginRet anonimousLoginRet) {
    _anonimousLoginRet = anonimousLoginRet;
  }

  /// 清理 Cookie 和账号缓存并切换到登出态。
  Future<void> onLogout() async {
    await deleteAllCookie();
    _accountInfo = null;
    _saveAccountInfo(null);
    _refreshLoginState(LoginState.Logout);
  }

  void _saveAccountInfo(NeteaseAccountInfoWrap? infoWrap) {
    _saveFile().writeAsString(jsonEncode(infoWrap), flush: true);
  }

  Future<void> _readAccountInfo() async {
    try {
      var accountInfo = _saveFile().readAsStringSync();

      _accountInfo = NeteaseAccountInfoWrap.fromJson(jsonDecode(accountInfo));
    } catch (e) {
      print('login info error');
      await onLogout();
    }
  }

  File _saveFile() => File(
      "${NeteaseMusicApi.pathProvider.getDataSavedPath()}_accountInfo.json");

  _checkCreateSavePath() {
    var file = _saveFile();
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
  }

  void _refreshLoginState(LoginState state) {
    var controller = _controller;
    if (controller != null && _curLoginState != state) {
      controller.add(state);
    }
    _curLoginState = state;
  }

  /// 关闭登录态广播流。
  void destroy() {
    _controller?.close();
  }
}

/// SDK 存储路径提供器，集中提供 Cookie 和账号缓存目录。
class PathProvider {
  var _cookiePath = '';
  var _dataPath = '';

  /// 初始化平台相关存储目录。
  init() async {
    if (PlatformUtils.isWeb) return;
    _cookiePath =
        "${(await getApplicationSupportDirectory()).absolute.path}/zmusic/.cookies/";
    _dataPath =
        "${(await getApplicationSupportDirectory()).absolute.path}/zmusic/.data/";
  }

  /// Cookie 持久化目录。
  String getCookieSavedPath() {
    return _cookiePath;
  }

  /// SDK 数据持久化目录。
  String getDataSavedPath() {
    return _dataPath;
  }
}

/// SDK 登录状态。
enum LoginState {
  /// 已登录。
  Logined,

  /// 未登录。
  Logout,
}
