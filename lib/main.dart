import 'package:audio_service/audio_service.dart';

import 'package:bujuan/common/bujuan_audio_handler.dart';
import 'package:bujuan/common/constants/platform_utils.dart';
import 'package:bujuan/pages/user/user_controller.dart';
import 'package:bujuan/widget/app_widget.dart';
import 'package:bujuan/widget/custom_zoom_drawer/src/drawer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:window_manager/window_manager.dart';

import 'common/netease_api/src/netease_api.dart';

main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // 启用显示 widget 尺寸和边界
  debugPaintSizeEnabled = false;

  await _initUI();
  // 在runApp前必须完成的初始化操作
  await _initSingleton();
  Get.lazyPut<UserController>(() => UserController());

  runApp(
      AppWidget()
     );
}

Future<void> _initUI() async {
  // 安卓平台配置
  if (PlatformUtils.isAndroid) {
    // 高刷
    await FlutterDisplayMode.setHighRefreshRate();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // 状态栏透明
      statusBarColor: Colors.transparent,
      // 底部导航栏透明
      systemNavigationBarColor: Colors.transparent,
      // 关闭底部导航栏的阴影
      systemNavigationBarContrastEnforced: false,
    ));
  }
  // 应用全屏（UI延伸到状态栏和导航栏下）
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

Future<void> _initSingleton() async {
  final getIt = GetIt.instance;
  // 注册侧边抽屉控制器
  getIt.registerSingleton<ZoomDrawerController>(ZoomDrawerController());
  // 注册PageView控制器
  getIt.registerSingleton<PageController>(PageController(viewportFraction: 0.8));
  // 初始化Hive存储
  await Hive.initFlutter('BuJuan');
  getIt.registerSingleton<Box>(await Hive.openBox('cache'));
  // 注册音频播放器
  getIt.registerSingleton<AudioPlayer>(AudioPlayer());
  // 初始化网易云API
  await NeteaseMusicApi.init(debug: false);
  // 初始化音频后台服务
  getIt.registerSingleton<BujuanAudioHandler>(await AudioService.init<BujuanAudioHandler>(
    builder: () => BujuanAudioHandler(),
    config: const AudioServiceConfig(
      androidStopForegroundOnPause: false,
      androidNotificationChannelId: 'com.sixbugs.bujuan.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationIcon: 'drawable/audio_service_icon',
    ),
  ));
}
