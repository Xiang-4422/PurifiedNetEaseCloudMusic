import 'package:audio_service/audio_service.dart';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/bujuan_audio_handler.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/constants/platform_utils.dart';
import 'package:bujuan/pages/album/controller.dart';
import 'package:bujuan/pages/home/home_binding.dart';
import 'package:bujuan/pages/index/cound_controller.dart';
import 'package:bujuan/pages/index/index_controller.dart';
import 'package:bujuan/pages/play_list/playlist_controller.dart';
import 'package:bujuan/pages/playlist_manager/playlist_manager_controller.dart';
import 'package:bujuan/pages/playlist_manager/playlist_manager_view.dart';
import 'package:bujuan/pages/user/user_controller.dart';
import 'package:bujuan/routes/router.gr.dart';
import 'package:bujuan/widget/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:window_manager/window_manager.dart';

import 'common/constants/colors.dart';
import 'common/netease_api/src/netease_api.dart';

main() async {
  // mac/windows/pad为横屏
  bool island = PlatformUtils.isMacOS || PlatformUtils.isWindows || OtherUtils.isPad();

  await _initSingleton();
  await _initAudioServer();
  await _initUI(island);

  runApp(
      AppWidget(isLandscape: island)
     );
}

class MyObserver extends AutoRouterObserver {
  _clearOrPutController(String name, {bool del = false}) {
    if (name.isEmpty) return;
    switch (name) {
      case 'AlbumView':
        del ? Get.delete<CloudController>() : Get.lazyPut<CloudController>(() => CloudController());
        break;
      case 'MainView':
        del ? Get.delete<IndexController>() : Get.lazyPut<IndexController>(() => IndexController());
        break;
      case 'UserView':
        del ? Get.delete<UserController>() : Get.lazyPut<UserController>(() => UserController());
        break;
      case 'PlayListView':
        del ? Get.delete<PlayListController>() : Get.lazyPut<PlayListController>(() => PlayListController());
        break;
      case 'AlbumDetails':
        del ? Get.delete<AlbumController>() : Get.lazyPut<AlbumController>(() => AlbumController());
        break;
      case 'PlaylistManagerView':
        del ? Get.delete<PlaylistManager>() : Get.lazyPut<PlaylistManager>(() => PlaylistManager());
        break;
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _clearOrPutController(route.settings.name ?? '');
    print('New route pushed: ${route.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    // TODO: implement didRemove
    super.didRemove(route, previousRoute);
    _clearOrPutController(route.settings.name ?? '', del: true);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // TODO: implement didPop
    super.didPop(route, previousRoute);
    _clearOrPutController(route.settings.name ?? '', del: true);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  // only override to observer tab routes
  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {}

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {}
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
