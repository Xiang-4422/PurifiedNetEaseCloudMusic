import 'dart:async';

import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
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
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/explore/explore_cache_store.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/library/library_preference_store.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_artwork_cache_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_artwork_presenter.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/application/playback_mode_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/application/playlist_playback_action.dart';
import 'package:bujuan/features/playlist/playlist_cache_store.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_cache_store.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
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

    _registerInfrastructure(
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
    _registerRepositories(
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

  static void _registerInfrastructure({
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

  static void _registerRepositories({
    required LibraryRepository libraryRepository,
    required UserScopedDataSource userScopedDataSource,
    required PlaylistCacheStore playlistCacheStore,
    required LocalLibraryDataSource localLibraryDataSource,
    required SearchCacheStore searchCacheStore,
    required ExploreCacheStore exploreCacheStore,
    required LocalResourceIndexRepository localResourceIndexRepository,
    required DownloadRepository downloadRepository,
    required PlaybackRepository playbackRepository,
  }) {
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
        cacheStore: playlistCacheStore,
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
        cacheStore: searchCacheStore,
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
    Get.put<ExploreRepository>(
      ExploreRepository(cacheStore: exploreCacheStore),
      permanent: true,
    );
    Get.put<PlaylistPlaybackAction>(
      PlaylistPlaybackAction(repository: Get.find<PlaylistRepository>()),
      permanent: true,
    );
  }

  @override
  void dependencies() {
    _registerPlaybackApplication();
    _registerUserApplication();
    _registerControllers();
    _registerFeatureFactories();
  }

  void _registerPlaybackApplication() {
    Get.put<PlaybackQueueStore>(
      PlaybackQueueStore(repository: Get.find<PlaybackRepository>()),
      permanent: true,
    );
    Get.put<PlaybackSourceResolver>(
      PlaybackSourceResolver(repository: Get.find<PlaybackRepository>()),
      permanent: true,
    );
    Get.put<PlaybackRestoreCoordinator>(
      PlaybackRestoreCoordinator(
        repository: Get.find<PlaybackRepository>(),
        queueStore: Get.find<PlaybackQueueStore>(),
      ),
      permanent: true,
    );
    Get.put(
      PlaybackService(
        queueStore: Get.find<PlaybackQueueStore>(),
        restoreCoordinator: Get.find<PlaybackRestoreCoordinator>(),
        sourceResolver: Get.find<PlaybackSourceResolver>(),
      ),
      permanent: true,
    );
    Get.put<PlaybackUserContentPort>(
      PlaybackUserContentPort(
        toggleLikeStatus: (item) =>
            Get.find<UserLibraryController>().toggleLikeStatus(item),
        likedSongIds: () =>
            Get.find<UserLibraryController>().likedSongIds.toList(),
        ensureLikedSongsLoaded: () =>
            Get.find<UserLibraryController>().ensureLikedSongsLoaded(),
        likedSongs: () => Get.find<UserLibraryController>().likedSongs.toList(),
        loadFmSongs: () => Get.find<RecommendationController>().getFmSongs(),
        loadHeartBeatSongs: (startSongId, randomLikedSongId, fromPlayAll) =>
            Get.find<UserLibraryController>().getHeartBeatSongs(
          startSongId,
          randomLikedSongId,
          fromPlayAll,
        ),
        randomLikedSongId: () =>
            Get.find<UserLibraryController>().randomLikedSongId.value,
      ),
      permanent: true,
    );
    Get.put<PlaybackQueueCoordinator>(
      PlaybackQueueCoordinator(
        playbackService: Get.find<PlaybackService>(),
      ),
      permanent: true,
    );
    Get.put<PlaybackModeCoordinator>(
      PlaybackModeCoordinator(
        playbackService: Get.find<PlaybackService>(),
        userContentPort: Get.find<PlaybackUserContentPort>(),
      ),
      permanent: true,
    );
    Get.put<PlaybackLyricsPresenter>(
      PlaybackLyricsPresenter(repository: Get.find<PlaybackRepository>()),
      permanent: true,
    );
    Get.put<PlaybackArtworkPresenter>(
      PlaybackArtworkPresenter(repository: Get.find<PlaybackRepository>()),
      permanent: true,
    );
    Get.put<CurrentTrackDownloadUseCase>(
      CurrentTrackDownloadUseCase(
        downloadRepository: Get.find<DownloadRepository>(),
        playbackRepository: Get.find<PlaybackRepository>(),
        userContentPort: Get.find<PlaybackUserContentPort>(),
      ),
      permanent: true,
    );
  }

  void _registerUserApplication() {
    Get.lazyPut(() => HomeShellController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(
      () => UserSessionController(
        repository: Get.find<UserRepository>(),
        box: CacheBox.instance,
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => UserLibraryController(
        repository: Get.find<UserRepository>(),
        sessionController: Get.find<UserSessionController>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => RecommendationController(
        repository: Get.find<UserRepository>(),
        sessionController: Get.find<UserSessionController>(),
        libraryController: Get.find<UserLibraryController>(),
        validateLoginStateInBackground: () =>
            Get.find<AuthController>().validateLoginStateInBackgroundIfNeeded(),
      ),
      fenix: true,
    );
  }

  void _registerControllers() {
    Get.lazyPut(
      () => PlayerController(
        playbackService: Get.find<PlaybackService>(),
        queueStore: Get.find<PlaybackQueueStore>(),
        queueCoordinator: Get.find<PlaybackQueueCoordinator>(),
        modeCoordinator: Get.find<PlaybackModeCoordinator>(),
        userContentPort: Get.find<PlaybackUserContentPort>(),
        lyricsPresenter: Get.find<PlaybackLyricsPresenter>(),
        artworkPresenter: Get.find<PlaybackArtworkPresenter>(),
        downloadUseCase: Get.find<CurrentTrackDownloadUseCase>(),
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

  void _registerFeatureFactories() {
    Get.put<FeatureControllerFactory>(
      FeatureControllerFactory(
        albumRepository: Get.find<AlbumRepository>(),
        artistRepository: Get.find<ArtistRepository>(),
        cloudRepository: Get.find<CloudRepository>(),
        commentRepository: Get.find<CommentRepository>(),
        downloadRepository: Get.find<DownloadRepository>(),
        libraryRepository: Get.find<LibraryRepository>(),
        localMediaRepository: Get.find<LocalMediaRepository>(),
        playlistRepository: Get.find<PlaylistRepository>(),
        radioRepository: Get.find<RadioRepository>(),
        searchRepository: Get.find<SearchRepository>(),
        userRepository: Get.find<UserRepository>(),
        userSessionController: Get.find<UserSessionController>(),
        userLibraryController: Get.find<UserLibraryController>(),
      ),
      permanent: true,
    );
  }
}
