import 'dart:async';

import 'package:bujuan/app/bootstrap/registrars/repository_registrar.dart';
import 'package:bujuan/core/database/app_database.dart';
import 'package:bujuan/core/database/drift_app_database.dart';
import 'package:bujuan/core/database/local_database_config.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/local_music_source.dart';
import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/netease_music_source.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/explore/explore_cache_store.dart';
import 'package:bujuan/features/library/library_preference_store.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_artwork_cache_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playlist/playlist_cache_store.dart';
import 'package:bujuan/features/search/search_cache_store.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InfrastructureRegistrar {
  const InfrastructureRegistrar._();

  static Future<void> init() async {
    final appDatabase =
        DriftAppDatabase(databaseName: LocalDatabaseConfig.databaseName);
    await appDatabase.init();

    await Hive.initFlutter('BuJuan');
    final cacheBox = await Hive.openBox('cache');
    CacheBox.init(cacheBox);

    final localLibraryDataSource = appDatabase.localLibraryDataSource;
    final localResourceIndexDataSource =
        appDatabase.localResourceIndexDataSource;
    final userScopedDataSource = appDatabase.userScopedDataSource;
    final downloadTaskDataSource = appDatabase.downloadTaskDataSource;
    final playbackRestoreDataSource = appDatabase.playbackRestoreDataSource;
    final appCacheDataSource = appDatabase.appCacheDataSource;
    final playlistCacheStore = PlaylistCacheStore(
      cacheDataSource: appCacheDataSource,
    );
    final searchCacheStore = SearchCacheStore(
      cacheDataSource: appCacheDataSource,
    );
    final exploreCacheStore = ExploreCacheStore(
      cacheDataSource: appCacheDataSource,
    );
    final localMusicSource =
        LocalMusicSource(localDataSource: localLibraryDataSource);
    final localResourceIndexRepository = LocalResourceIndexRepository(
      dataSource: localResourceIndexDataSource,
      localLibraryDataSource: localLibraryDataSource,
    );
    final sharedDio = Dio();
    final localArtworkCacheRepository = LocalArtworkCacheRepository(
      dio: sharedDio,
      resourceIndexRepository: localResourceIndexRepository,
    );
    final libraryRepository = LibraryRepository(
      localDataSource: localLibraryDataSource,
      localMusicSource: localMusicSource,
      neteaseSource: NeteaseMusicSource(),
      preferenceStore: const LibraryPreferenceStore(),
      resourceIndexRepository: localResourceIndexRepository,
      artworkCacheRepository: localArtworkCacheRepository,
    );
    final downloadRepository = DownloadRepository(
      libraryRepository: libraryRepository,
      taskDataSource: downloadTaskDataSource,
      resourceIndexRepository: localResourceIndexRepository,
      dio: sharedDio,
    );
    final playbackRepository = PlaybackRepository(
      libraryRepository: libraryRepository,
      playbackRestoreDataSource: playbackRestoreDataSource,
    );

    registerInfrastructure(
      appDatabase: appDatabase,
      localLibraryDataSource: localLibraryDataSource,
      playbackRestoreDataSource: playbackRestoreDataSource,
      localResourceIndexDataSource: localResourceIndexDataSource,
      downloadTaskDataSource: downloadTaskDataSource,
      appCacheDataSource: appCacheDataSource,
      userScopedDataSource: userScopedDataSource,
      localMusicSource: localMusicSource,
      localResourceIndexRepository: localResourceIndexRepository,
      localArtworkCacheRepository: localArtworkCacheRepository,
    );
    RepositoryRegistrar.register(
      libraryRepository: libraryRepository,
      userScopedDataSource: userScopedDataSource,
      playlistCacheStore: playlistCacheStore,
      localLibraryDataSource: localLibraryDataSource,
      searchCacheStore: searchCacheStore,
      exploreCacheStore: exploreCacheStore,
      localResourceIndexRepository: localResourceIndexRepository,
      downloadRepository: downloadRepository,
      playbackRepository: playbackRepository,
    );

    unawaited(downloadRepository.recoverInterruptedTasks());
  }

  static void registerInfrastructure({
    required AppDatabase appDatabase,
    required LocalLibraryDataSource localLibraryDataSource,
    required PlaybackRestoreDataSource playbackRestoreDataSource,
    required LocalResourceIndexDataSource localResourceIndexDataSource,
    required DownloadTaskDataSource downloadTaskDataSource,
    required AppCacheDataSource appCacheDataSource,
    required UserScopedDataSource userScopedDataSource,
    required LocalMusicSource localMusicSource,
    required LocalResourceIndexRepository localResourceIndexRepository,
    required LocalArtworkCacheRepository localArtworkCacheRepository,
  }) {
    Get.put<AppDatabase>(appDatabase, permanent: true);
    Get.put<LocalLibraryDataSource>(localLibraryDataSource, permanent: true);
    Get.put<PlaybackRestoreDataSource>(
      playbackRestoreDataSource,
      permanent: true,
    );
    Get.put<LocalResourceIndexDataSource>(
      localResourceIndexDataSource,
      permanent: true,
    );
    Get.put<DownloadTaskDataSource>(downloadTaskDataSource, permanent: true);
    Get.put<AppCacheDataSource>(appCacheDataSource, permanent: true);
    Get.put<UserScopedDataSource>(userScopedDataSource, permanent: true);
    Get.put<LocalMusicSource>(localMusicSource, permanent: true);
    Get.put<LocalResourceIndexRepository>(
      localResourceIndexRepository,
      permanent: true,
    );
    Get.put<LocalArtworkCacheRepository>(
      localArtworkCacheRepository,
      permanent: true,
    );
  }
}
