
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/app_root_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'common/netease_api/src/netease_api.dart';
import 'controllers/explore_page_controller.dart';

/// 应用启动入口
main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // 启用显示 widget 尺寸和边界
  debugPaintSizeEnabled = false;
  debugProfileBuildsEnabled = true;
  debugProfilePaintsEnabled = true;
  await _initUI();
  // 在runApp前必须完成的初始化操作
  await _initSingleton();

  Get.lazyPut<ExplorePageController>(() => ExplorePageController());
  Get.lazyPut<AppController>(() => AppController());

  runApp(AppRootRouter());
}

Future<void> _initUI() async {
  // 应用全屏（UI延伸到状态栏和导航栏下）
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // 状态栏透明
      statusBarColor: Colors.transparent,
      // 底部导航栏透明
      systemNavigationBarColor: Colors.transparent,
      // 关闭底部导航栏的阴影
      systemNavigationBarContrastEnforced: false,
    ));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // 高刷
  await FlutterDisplayMode.setHighRefreshRate();
}

Future<void> _initSingleton() async {
  final getIt = GetIt.instance;
  // 初始化Hive本地存储
  await Hive.initFlutter('BuJuan');
  getIt.registerSingleton<Box>(await Hive.openBox('cache'));
  // 初始化网易云API
  await NeteaseMusicApi.init(debug: true);
}
