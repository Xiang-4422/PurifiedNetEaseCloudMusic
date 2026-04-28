import 'dart:async';

import 'package:bujuan/app/bootstrap/app_binding.dart';
import 'package:bujuan/data/netease/netease_remote_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

/// 统一收口应用启动依赖，避免初始化逻辑继续散落到 `main.dart`
/// 或页面侧，破坏本地优先链路对单例视图的一致性假设。
Future<void> bootstrapApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  debugProfileBuildsEnabled =
      kDebugMode && const bool.fromEnvironment('profile_flutter_builds');
  debugProfilePaintsEnabled =
      kDebugMode && const bool.fromEnvironment('profile_flutter_paints');
  await _initUi();
  await _initInfrastructure();
}

Future<void> _initUi() async {
  // 这些 UI 选项必须在首帧前固定，否则状态栏和高刷策略会出现首屏闪动，
  // 后面再改只会让平台表现更不稳定。
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await FlutterDisplayMode.setHighRefreshRate();
}

Future<void> _initInfrastructure() async {
  await NeteaseRemoteBootstrap.initialize(
    debug:
        kDebugMode && const bool.fromEnvironment('enable_verbose_network_logs'),
  );
  await AppBinding.initInfrastructure();
}
