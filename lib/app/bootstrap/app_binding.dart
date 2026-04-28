import 'dart:async';

import 'package:bujuan/core/database/app_database.dart';
import 'package:bujuan/core/database/drift_app_database.dart';
import 'package:bujuan/core/database/local_database_config.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/local_music_source.dart';
import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/netease_music_source.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/library/library_preference_store.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_artwork_cache_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/user_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppBinding extends Bindings {
  AppBinding();

  static Future<void> initInfrastructure() async {
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

    Get.put<AppDatabase>(appDatabase, permanent: true);
    Get.put<LocalLibraryDataSource>(
      localLibraryDataSource,
      permanent: true,
    );
    Get.put<PlaybackRestoreDataSource>(
      playbackRestoreDataSource,
      permanent: true,
    );
    Get.put<LocalResourceIndexDataSource>(
      localResourceIndexDataSource,
      permanent: true,
    );
    Get.put<DownloadTaskDataSource>(downloadTaskDataSource, permanent: true);
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
    Get.put<LibraryRepository>(libraryRepository, permanent: true);
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<UserRepository>(
      UserRepository(
        libraryRepository: libraryRepository,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<PlaylistRepository>(
      PlaylistRepository(
        libraryRepository: libraryRepository,
        localLibraryDataSource: localLibraryDataSource,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<AlbumRepository>(
      AlbumRepository(libraryRepository: libraryRepository),
      permanent: true,
    );
    Get.put<ArtistRepository>(
      ArtistRepository(libraryRepository: libraryRepository),
      permanent: true,
    );
    Get.put<CloudRepository>(
      CloudRepository(
        libraryRepository: libraryRepository,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<RadioRepository>(
      RadioRepository(userScopedDataSource: userScopedDataSource),
      permanent: true,
    );
    Get.put<SearchRepository>(
      SearchRepository(
        libraryRepository: libraryRepository,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<LocalMediaRepository>(
      LocalMediaRepository(
        libraryRepository: libraryRepository,
        resourceIndexRepository: localResourceIndexRepository,
      ),
      permanent: true,
    );
    Get.put<DownloadRepository>(downloadRepository, permanent: true);
    Get.put<PlaybackRepository>(playbackRepository, permanent: true);
    Get.put<CommentRepository>(CommentRepository(), permanent: true);
    Get.put<ExploreRepository>(ExploreRepository(), permanent: true);

    unawaited(downloadRepository.recoverInterruptedTasks());
  }

  @override
  void dependencies() {
    Get.put(
      PlaybackService(playbackRepository: Get.find<PlaybackRepository>()),
      permanent: true,
    );
    Get.lazyPut(() => HomeShellController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(
      () => UserController(
        repository: Get.find<UserRepository>(),
        box: CacheBox.instance,
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => PlayerController(
        repository: Get.find<PlaybackRepository>(),
        playbackService: Get.find<PlaybackService>(),
        downloadRepository: Get.find<DownloadRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => AuthController(repository: Get.find<AuthRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => ExplorePageController(
        repository: Get.find<ExploreRepository>(),
        playlistRepository: Get.find<PlaylistRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(() => ShellController(), fenix: true);
  }
}
