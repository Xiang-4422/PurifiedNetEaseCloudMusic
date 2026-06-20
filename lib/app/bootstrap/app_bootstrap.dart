import 'package:bujuan/app/bootstrap/bootstrap_ui.dart';
import 'package:bujuan/app/bootstrap/data_bootstrap.dart';
import 'package:bujuan/app/bootstrap/feature_bootstrap.dart';
import 'package:bujuan/app/bootstrap/playback_bootstrap.dart';
import 'package:bujuan/app/bootstrap/presentation_bootstrap.dart';
import 'package:bujuan/app/bootstrap/sdk_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netease_music_api/netease_music_api.dart';

/// 统一收口应用启动依赖，避免初始化逻辑继续散落到 `main.dart`
/// 或页面侧，破坏本地优先链路对单例视图的一致性假设。
Future<void> bootstrapApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBootstrapUi();
  final neteaseApi = await initializeSdk(
    debug: kDebugMode && const bool.fromEnvironment('enable_verbose_network_logs'),
  );
  await AppBinding.initInfrastructure(neteaseApi: neteaseApi);
}

/// 应用级 GetX 组合根，统一注册基础设施、应用服务和控制器。
class AppBinding extends Bindings {
  /// 创建应用级依赖装配实例。
  AppBinding();

  /// 在 Flutter 首帧前初始化数据库、Hive 和 repository 基础设施。
  static Future<void> initInfrastructure({
    required NeteaseMusicApi neteaseApi,
  }) {
    return initializeDataInfrastructure(neteaseApi: neteaseApi);
  }

  @override
  void dependencies() {
    registerUserControllers();
    registerPlaybackDependencies();
    registerPresentationAdapters();
    registerFeatureApplications();
    registerFeatureControllers();
  }
}
