import 'dart:async';

import 'package:bujuan/app/presentation_adapters/playback_artwork_presenter.dart';
import 'package:bujuan/app/presentation_adapters/playback_selection_ui_effect_coordinator.dart';
import 'package:bujuan/app/services/toast_service.dart';
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
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/netease_remote_bootstrap.dart';
import 'package:bujuan/data/netease/netease_music_source.dart';
import 'package:bujuan/data/netease/remote/netease_album_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_artist_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_auth_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_cloud_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_comment_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_explore_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_playlist_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_radio_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_search_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_user_remote_data_source.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/auth/auth_state_store.dart';
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
import 'package:bujuan/features/playback/application/confirmed_playback_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/application/playback_lyric_ui_state_controller.dart';
import 'package:bujuan/features/playback/application/playback_mode_command_service.dart';
import 'package:bujuan/features/playback/application/playback_mode_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_preference_port.dart';
import 'package:bujuan/features/playback/application/playback_queue_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_selection_navigator.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_source_prefetcher.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/application/playback_state_synchronizer.dart';
import 'package:bujuan/features/playback/application/playback_switch_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_toast_port.dart';
import 'package:bujuan/features/playback/application/playback_ui_command_service.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_cache_store.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/settings/cache_analysis_service.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/settings/settings_repository.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/features/user/user_session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 统一收口应用启动依赖，避免初始化逻辑继续散落到 `main.dart`
/// 或页面侧，破坏本地优先链路对单例视图的一致性假设。
Future<void> bootstrapApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  debugProfileBuildsEnabled = kDebugMode && const bool.fromEnvironment('profile_flutter_builds');
  debugProfilePaintsEnabled = kDebugMode && const bool.fromEnvironment('profile_flutter_paints');
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
    debug: kDebugMode && const bool.fromEnvironment('enable_verbose_network_logs'),
  );
  await AppBinding.initInfrastructure();
}

/// 应用级 GetX 组合根，统一注册基础设施、应用服务和控制器。
class AppBinding extends Bindings {
  /// 创建应用级依赖装配实例。
  AppBinding();

  /// 在 Flutter 首帧前初始化数据库、Hive 和 repository 基础设施。
  static Future<void> initInfrastructure() {
    return _initAppInfrastructure();
  }

  @override
  void dependencies() {
    _registerUserControllers();
    _registerPlayback();
    _registerPresentationAdapters();
    _registerFeatureApplications();
    _registerFeatureControllers();
  }
}

Future<void> _initAppInfrastructure() async {
  final appDatabase = DriftAppDatabase(databaseName: LocalDatabaseConfig.databaseName);
  await appDatabase.init();

  await Hive.initFlutter('BuJuan');
  final cacheBox = await Hive.openBox('cache');
  CacheBox.init(cacheBox);

  final localLibraryDataSource = appDatabase.localLibraryDataSource;
  final localResourceIndexDataSource = appDatabase.localResourceIndexDataSource;
  final userScopedDataSource = appDatabase.userScopedDataSource;
  final downloadTaskDataSource = appDatabase.downloadTaskDataSource;
  final playbackRestoreDataSource = appDatabase.playbackRestoreDataSource;
  final appCacheDataSource = appDatabase.appCacheDataSource;
  final searchCacheStore = SearchCacheStore(
    cacheDataSource: appCacheDataSource,
  );
  final exploreCacheStore = ExploreCacheStore(
    cacheDataSource: appCacheDataSource,
  );
  final neteaseApi = NeteaseMusicApi();
  final localMusicSource = LocalMusicSource(localDataSource: localLibraryDataSource);
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
    neteaseSource: NeteaseMusicSource(api: neteaseApi),
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
    appCacheDataSource: appCacheDataSource,
    localLibraryDataSource: localLibraryDataSource,
    searchCacheStore: searchCacheStore,
    exploreCacheStore: exploreCacheStore,
    localResourceIndexRepository: localResourceIndexRepository,
    downloadRepository: downloadRepository,
    playbackRepository: playbackRepository,
    neteaseApi: neteaseApi,
  );

  unawaited(downloadRepository.recoverInterruptedTasks());
}

void _registerInfrastructure({
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

void _registerRepositories({
  required LibraryRepository libraryRepository,
  required UserScopedDataSource userScopedDataSource,
  required AppCacheDataSource appCacheDataSource,
  required LocalLibraryDataSource localLibraryDataSource,
  required SearchCacheStore searchCacheStore,
  required ExploreCacheStore exploreCacheStore,
  required LocalResourceIndexRepository localResourceIndexRepository,
  required DownloadRepository downloadRepository,
  required PlaybackRepository playbackRepository,
  required NeteaseMusicApi neteaseApi,
}) {
  final authRemoteDataSource = NeteaseAuthRemoteDataSource(api: neteaseApi);
  final userRemoteDataSource = NeteaseUserRemoteDataSource(api: neteaseApi);
  final playlistRemoteDataSource = NeteasePlaylistRemoteDataSource(api: neteaseApi);
  final albumRemoteDataSource = NeteaseAlbumRemoteDataSource(api: neteaseApi);
  final artistRemoteDataSource = NeteaseArtistRemoteDataSource(api: neteaseApi);
  final cloudRemoteDataSource = NeteaseCloudRemoteDataSource(api: neteaseApi);
  final radioRemoteDataSource = NeteaseRadioRemoteDataSource(api: neteaseApi);
  final searchRemoteDataSource = NeteaseSearchRemoteDataSource(api: neteaseApi);
  final commentRemoteDataSource = NeteaseCommentRemoteDataSource(api: neteaseApi);
  final exploreRemoteDataSource = NeteaseExploreRemoteDataSource(api: neteaseApi);

  Get.put<LibraryRepository>(libraryRepository, permanent: true);
  Get.put<AuthRepository>(
    AuthRepository(
      stateStore: const AuthStateStore(),
      remoteDataSource: authRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<SettingsRepository>(const SettingsRepository(), permanent: true);
  Get.put<UserRepository>(
    UserRepository(
      libraryRepository: libraryRepository,
      remoteDataSource: userRemoteDataSource,
      userScopedDataSource: userScopedDataSource,
    ),
    permanent: true,
  );
  Get.put<PlaylistRepository>(
    PlaylistRepository(
      appCacheDataSource: appCacheDataSource,
      libraryRepository: libraryRepository,
      localLibraryDataSource: localLibraryDataSource,
      remoteDataSource: playlistRemoteDataSource,
      userScopedDataSource: userScopedDataSource,
    ),
    permanent: true,
  );
  Get.put<AlbumRepository>(
    AlbumRepository(
      libraryRepository: libraryRepository,
      remoteDataSource: albumRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<ArtistRepository>(
    ArtistRepository(
      libraryRepository: libraryRepository,
      remoteDataSource: artistRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<CloudRepository>(
    CloudRepository(
      libraryRepository: libraryRepository,
      userScopedDataSource: userScopedDataSource,
      remoteDataSource: cloudRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<RadioRepository>(
    RadioRepository(
      userScopedDataSource: userScopedDataSource,
      remoteDataSource: radioRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<SearchRepository>(
    SearchRepository(
      libraryRepository: libraryRepository,
      remoteDataSource: searchRemoteDataSource,
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
  Get.put<CommentRepository>(
    CommentRepository(remoteDataSource: commentRemoteDataSource),
    permanent: true,
  );
  Get.put<ExploreRepository>(
    ExploreRepository(
      remoteDataSource: exploreRemoteDataSource,
      cacheStore: exploreCacheStore,
    ),
    permanent: true,
  );
}

void _registerUserControllers() {
  Get.lazyPut(() => HomeShellController(), fenix: true);
  Get.lazyPut(
    () => SettingsController(repository: Get.find<SettingsRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => UserSessionController(
      repository: Get.find<UserRepository>(),
      sessionStore: const UserSessionStore(),
      saveLoginFlag: Get.find<AuthRepository>().setLoginFlag,
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
      validateLoginStateInBackground: () => Get.find<AuthController>().validateLoginStateInBackgroundIfNeeded(),
    ),
    fenix: true,
  );
}

void _registerPlayback() {
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
  Get.put<PlaybackService>(
    PlaybackService(
      restoreCoordinator: Get.find<PlaybackRestoreCoordinator>(),
    ),
    permanent: true,
  );
  Get.put<PlaybackUserContentPort>(
    PlaybackUserContentPort(
      toggleLikeStatus: (item) => Get.find<UserLibraryController>().toggleLikeStatus(item),
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
      ensureLikedSongsLoaded: () => Get.find<UserLibraryController>().ensureLikedSongsLoaded(),
      likedSongs: () => Get.find<UserLibraryController>().likedSongs.toList(),
      loadFmSongs: () => Get.find<RecommendationController>().getFmSongs(),
      loadHeartBeatSongs: (startSongId, randomLikedSongId, fromPlayAll) => Get.find<UserLibraryController>().getHeartBeatSongs(
        startSongId,
        randomLikedSongId,
        fromPlayAll,
      ),
      randomLikedSongId: () => Get.find<UserLibraryController>().randomLikedSongId.value,
    ),
    permanent: true,
  );
  Get.put<PlaybackSelectionNavigator>(
    const PlaybackSelectionNavigator(),
    permanent: true,
  );
  Get.put<PlaybackQueueService>(
    PlaybackQueueService(
      queueStore: Get.find<PlaybackQueueStore>(),
      playbackService: Get.find<PlaybackService>(),
    ),
    permanent: true,
  );
  Get.put<PlaybackSourcePrefetcher>(
    PlaybackSourcePrefetcher(
      resolver: Get.find<PlaybackSourceResolver>(),
    ),
    permanent: true,
  );
  Get.put<PlaybackSwitchCoordinator>(
    PlaybackSwitchCoordinator(
      playbackService: Get.find<PlaybackService>(),
      queueService: Get.find<PlaybackQueueService>(),
      sourceResolver: Get.find<PlaybackSourceResolver>(),
      sourcePrefetcher: Get.find<PlaybackSourcePrefetcher>(),
    ),
    permanent: true,
  );
  Get.put<PlaybackSelectionService>(
    PlaybackSelectionService(
      queueService: Get.find<PlaybackQueueService>(),
      navigator: Get.find<PlaybackSelectionNavigator>(),
      switchCoordinator: Get.find<PlaybackSwitchCoordinator>(),
    ),
    permanent: true,
  );
  Get.put<PlaybackQueueCoordinator>(
    PlaybackQueueCoordinator(
      queueService: Get.find<PlaybackQueueService>(),
      selectionService: Get.find<PlaybackSelectionService>(),
    ),
    permanent: true,
  );
  Get.put<PlaybackModeCoordinator>(
    PlaybackModeCoordinator(
      playbackService: Get.find<PlaybackService>(),
      userContentPort: Get.find<PlaybackUserContentPort>(),
      selectionService: Get.find<PlaybackSelectionService>(),
    ),
    permanent: true,
  );
  Get.put<PlaybackUiCommandService>(
    PlaybackUiCommandService(
      playbackService: Get.find<PlaybackService>(),
      modeCoordinator: Get.find<PlaybackModeCoordinator>(),
      queueService: Get.find<PlaybackQueueService>(),
      selectionService: Get.find<PlaybackSelectionService>(),
      switchCoordinator: Get.find<PlaybackSwitchCoordinator>(),
    ),
    permanent: true,
  );
  Get.put<PlaybackPreferencePort>(
    PlaybackPreferencePort(
      isHighQualityEnabled: () => Get.find<SettingsController>().isHighSoundQualityOpen.value,
    ),
    permanent: true,
  );
  Get.put<CurrentTrackSideEffectCoordinator>(
    CurrentTrackSideEffectCoordinator(),
    permanent: true,
  );
  Get.put<ConfirmedPlaybackEffectCoordinator>(
    ConfirmedPlaybackEffectCoordinator(),
    permanent: true,
  );
  Get.put<PlaybackLyricsPresenter>(
    PlaybackLyricsPresenter(repository: Get.find<PlaybackRepository>()),
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

void _registerPresentationAdapters() {
  Get.put<PlaybackToastPort>(
    const PlaybackToastPort(show: ToastService.show),
    permanent: true,
  );
  Get.put<PlaybackArtworkPresenter>(
    PlaybackArtworkPresenter(repository: Get.find<PlaybackRepository>()),
    permanent: true,
  );
  Get.put<PlaybackSelectionUiEffectCoordinator>(
    PlaybackSelectionUiEffectCoordinator(
      sideEffectCoordinator: Get.find<CurrentTrackSideEffectCoordinator>(),
      lyricsPresenter: Get.find<PlaybackLyricsPresenter>(),
      artworkPresenter: Get.find<PlaybackArtworkPresenter>(),
      applyDominantColor: (color) {
        final settingsController = Get.find<SettingsController>();
        settingsController.albumColor.value = color;
        settingsController.panelWidgetColor.value = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
      },
    ),
    permanent: true,
  );
}

void _registerFeatureApplications() {
  Get.put<PlaybackLyricUiStateController>(
    PlaybackLyricUiStateController(),
    permanent: true,
  );
  Get.put<PlaybackModeCommandService>(
    PlaybackModeCommandService(
      commandService: Get.find<PlaybackUiCommandService>(),
      toastPort: Get.find<PlaybackToastPort>(),
    ),
    permanent: true,
  );
  Get.put<PlaybackStateSynchronizer>(
    PlaybackStateSynchronizer(
      playbackService: Get.find<PlaybackService>(),
      queueStore: Get.find<PlaybackQueueStore>(),
      queueService: Get.find<PlaybackQueueService>(),
      queueCoordinator: Get.find<PlaybackQueueCoordinator>(),
      userContentPort: Get.find<PlaybackUserContentPort>(),
      downloadUseCase: Get.find<CurrentTrackDownloadUseCase>(),
      preferencePort: Get.find<PlaybackPreferencePort>(),
      toastPort: Get.find<PlaybackToastPort>(),
      lyricUiStateController: Get.find<PlaybackLyricUiStateController>(),
      selectionService: Get.find<PlaybackSelectionService>(),
      sideEffectCoordinator: Get.find<ConfirmedPlaybackEffectCoordinator>(),
    ),
    permanent: true,
  );
  Get.put<CacheAnalysisService>(
    CacheAnalysisService(
      libraryRepository: Get.find<LibraryRepository>(),
      resourceIndexRepository: Get.find<LocalResourceIndexRepository>(),
    ),
    permanent: true,
  );
}

void _registerFeatureControllers() {
  Get.lazyPut(
    () => PlayerController(
      playbackService: Get.find<PlaybackService>(),
      queueStore: Get.find<PlaybackQueueStore>(),
      queueService: Get.find<PlaybackQueueService>(),
      commandService: Get.find<PlaybackUiCommandService>(),
      modeCommandService: Get.find<PlaybackModeCommandService>(),
      stateSynchronizer: Get.find<PlaybackStateSynchronizer>(),
      selectionService: Get.find<PlaybackSelectionService>(),
      lyricUiStateController: Get.find<PlaybackLyricUiStateController>(),
      userContentPort: Get.find<PlaybackUserContentPort>(),
      artworkPresenter: Get.find<PlaybackArtworkPresenter>(),
      selectionUiEffectCoordinator: Get.find<PlaybackSelectionUiEffectCoordinator>(),
      downloadUseCase: Get.find<CurrentTrackDownloadUseCase>(),
      toastPort: Get.find<PlaybackToastPort>(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => AuthController(repository: Get.find<AuthRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => ExplorePageController(
      exploreRepository: Get.find<ExploreRepository>(),
      playlistRepository: Get.find<PlaylistRepository>(),
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
      currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => SearchPanelController(repository: Get.find<SearchRepository>()),
    fenix: true,
  );
  Get.lazyPut(() => ShellController(), fenix: true);
}
