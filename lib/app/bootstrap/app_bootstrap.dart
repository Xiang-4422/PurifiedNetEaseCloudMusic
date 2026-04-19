import 'package:bujuan/core/database/app_database.dart';
import 'package:bujuan/core/database/local_database_config.dart';
import 'package:bujuan/core/database/pending_app_database.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/data/sources/local/local_music_source.dart';
import 'package:bujuan/data/sources/music_source_registry_impl.dart';
import 'package:bujuan/data/sources/netease/netease_music_source.dart';
import 'package:bujuan/domain/sources/music_source_registry.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../common/netease_api/src/netease_api.dart';

/// 统一收口应用启动依赖，避免初始化逻辑继续散落到 `main.dart`
/// 或页面侧，破坏本地优先链路对单例视图的一致性假设。
Future<void> bootstrapApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  debugProfileBuildsEnabled = true;
  debugProfilePaintsEnabled = true;
  await _initUi();
  // 这里必须在 runApp 前完成注册，否则页面和控制器会各自 new 出
  // 分裂的本地库与 source 视图，后面的本地优先链路就不再可信。
  await _initInfrastructure();
  _registerControllers();
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
  final getIt = GetIt.instance;
  // 当前仍处在旧入口和新入口并存阶段，基础设施必须全部经由同一组
  // 单例注册出去，否则 repository、source 和本地库会各自持有不同实例。
  final appDatabase =
      PendingAppDatabase(databaseName: LocalDatabaseConfig.databaseName);
  await appDatabase.init();
  getIt.registerSingleton<AppDatabase>(appDatabase);
  getIt.registerSingleton<LocalLibraryDataSource>(
    appDatabase.localLibraryDataSource,
  );
  getIt.registerSingleton<PlaybackRestoreDataSource>(
    appDatabase.playbackRestoreDataSource,
  );
  await Hive.initFlutter('BuJuan');
  getIt.registerSingleton<Box>(await Hive.openBox('cache'));
  await NeteaseMusicApi.init(debug: true);

  final sourceRegistry = MusicSourceRegistryImpl(
    sources: [
      LocalMusicSource(localDataSource: appDatabase.localLibraryDataSource),
      NeteaseMusicSource(),
    ],
  );
  getIt.registerSingleton<MusicSourceRegistry>(sourceRegistry);
  getIt.registerSingleton<LibraryRepository>(
    LibraryRepository(
      localDataSource: appDatabase.localLibraryDataSource,
      sourceRegistry: sourceRegistry,
    ),
  );
}

void _registerControllers() {
  // 现阶段仍有旧页面直接依赖 GetX 全局控制器，先把注册收口到入口层，
  // 避免迁移期出现多处重复 lazyPut。
  Get.put(PlaybackService(), permanent: true);
  Get.lazyPut<AppController>(() => AppController());
  Get.lazyPut<ExplorePageController>(() => ExplorePageController());
}
