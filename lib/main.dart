import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/bujuan_audio_handler.dart';
import 'package:bujuan/common/constants/platform_utils.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/user/personal_page_controller.dart';
import 'package:bujuan/widget/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

import 'common/netease_api/src/netease_api.dart';

/// 应用启动入口
main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // 启用显示 widget 尺寸和边界
  debugPaintSizeEnabled = false;
  await _initUI();
  // 在runApp前必须完成的初始化操作
  await _initSingleton();
  Get.lazyPut<PersonalPageController>(() => PersonalPageController());

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
  // 初始化Hive本地存储
  await Hive.initFlutter('BuJuan');
  getIt.registerSingleton<Box>(await Hive.openBox('cache'));
  // 注册音频播放器（要在 BujuanAudioHandler 前注册）
  getIt.registerSingleton<AudioPlayer>(AudioPlayer());
  // 初始化网易云API
  await NeteaseMusicApi.init(debug: false);
  // 初始化音频后台服务
  getIt.registerSingleton<BujuanAudioHandler>(
      await AudioService.init<BujuanAudioHandler>(
        builder: () => BujuanAudioHandler(),
        config: const AudioServiceConfig(
          androidStopForegroundOnPause: false,
          androidNotificationChannelId: 'com.yu4422.purrr.channel.audio',
          androidNotificationChannelName: 'Music playback',
          androidNotificationIcon: 'drawable/audio_service_icon',
        ),
      )
  );
}
