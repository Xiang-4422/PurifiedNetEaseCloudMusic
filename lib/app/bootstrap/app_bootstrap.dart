import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/controllers/explore_page_controller.dart';
import 'package:bujuan/core/database/app_database.dart';
import 'package:bujuan/core/database/local_database_config.dart';
import 'package:bujuan/core/database/pending_app_database.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/sources/local/local_music_source.dart';
import 'package:bujuan/data/sources/music_source_registry_impl.dart';
import 'package:bujuan/data/sources/netease/netease_music_source.dart';
import 'package:bujuan/domain/sources/music_source_registry.dart';
import 'package:bujuan/features/library/repository/library_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../common/netease_api/src/netease_api.dart';

Future<void> bootstrapApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  debugProfileBuildsEnabled = true;
  debugProfilePaintsEnabled = true;
  await _initUi();
  await _initInfrastructure();
  _registerControllers();
}

Future<void> _initUi() async {
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
  final appDatabase =
      PendingAppDatabase(databaseName: LocalDatabaseConfig.databaseName);
  await appDatabase.init();
  getIt.registerSingleton<AppDatabase>(appDatabase);
  getIt.registerSingleton<LocalLibraryDataSource>(
    appDatabase.localLibraryDataSource,
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
  Get.lazyPut<AppController>(() => AppController());
  Get.lazyPut<ExplorePageController>(() => ExplorePageController());
}
