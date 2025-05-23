import 'package:audio_service/audio_service.dart';

import 'package:bujuan/common/bujuan_audio_handler.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/constants/platform_utils.dart';
import 'package:bujuan/widget/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:window_manager/window_manager.dart';

import 'common/netease_api/src/netease_api.dart';

main() async {
  // mac/windows/pad为横屏
  bool island = PlatformUtils.isMacOS || PlatformUtils.isWindows || OtherUtils.isPad();

  // 在runApp前必须完成的初始化操作
  await _initSingleton();
  await _initAudioServer();
  await _initUI(island);

  runApp(
      AppWidget(isLandscape: island)
     );
}

Future<void> _initUI(island) async {
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

  if (island) {
    // 强制只能横屏显示
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  // 应用全屏（UI延伸到状态栏和导航栏下）
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

Future<void> _initSingleton() async {
  final getIt = GetIt.instance;
  // 注册侧边抽屉控制器
  getIt.registerSingleton<ZoomDrawerController>(ZoomDrawerController());
  // 初始化Hive存储
  await Hive.initFlutter('BuJuan');
  getIt.registerSingleton<Box>(await Hive.openBox('cache'));
}

Future<void> _initAudioServer() async {
  final getIt = GetIt.instance;
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

Future<void> _initWindowManager() async {
  if (PlatformUtils.isWindows || PlatformUtils.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1080, 720),
      minimumSize: Size(1080, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
