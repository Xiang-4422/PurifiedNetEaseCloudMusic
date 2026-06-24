import 'dart:developer' as developer;

import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:bujuan/features/album/album_page_controller_factory.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_page_controller_factory.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/auth/auth_controller_bundle.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/cloud/cloud_page_controller_factory.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/comment/comment_controller_factory.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/download/local_song_list_controller_factory.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
import 'package:bujuan/features/music_detail/music_detail_controller_bundle.dart';
import 'package:bujuan/features/music_detail/music_page_playback_actions.dart';
import 'package:bujuan/features/playback/application/confirmed_playback_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_lyric_ui_state_controller.dart';
import 'package:bujuan/features/playback/application/playback_mode_command_service.dart';
import 'package:bujuan/features/playback/application/playback_preference_port.dart';
import 'package:bujuan/features/playback/application/playback_queue_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_state_synchronizer.dart';
import 'package:bujuan/features/playback/application/playback_toast_port.dart';
import 'package:bujuan/features/playback/application/playback_ui_command_service.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_artwork_presenter.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/playback_selection_ui_effect_coordinator.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/features/playlist/playlist_artwork_color_service.dart';
import 'package:bujuan/features/playlist/playlist_page_controller_factory.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_controller_factory.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/settings/cache_analysis_controller.dart';
import 'package:bujuan/features/settings/cache_analysis_service.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/settings/settings_page_controller_bundle.dart';
import 'package:bujuan/features/settings/settings_repository.dart';
import 'package:bujuan/features/settings/utility_page_controller_bundle.dart';
import 'package:bujuan/features/shell/app_home_controller_bundle.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/shell/personal_home_controller_bundle.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/home_content_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_profile_controller_factory.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/features/user/user_session_store.dart';
import 'package:get/get.dart';

/// Registers user/session controllers that playback ports depend on.
void registerUserControllers() {
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
      canRestoreCachedSession: () => Get.find<AuthRepository>().hasCachedSession,
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => UserLibraryController(
      repository: Get.find<UserRepository>(),
      sessionAccess: UserLibrarySessionAccess(
        ensureCacheLoaded: () => Get.find<UserSessionController>().ensureCacheLoaded(),
        currentSession: () => Get.find<UserSessionController>().userInfo.value,
        watchSession: (onChanged) {
          final worker = ever<UserSessionData>(
            Get.find<UserSessionController>().userInfo,
            onChanged,
          );
          return worker.dispose;
        },
      ),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => HomeContentController(
      repository: Get.find<UserRepository>(),
      playlistRepository: Get.find<PlaylistRepository>(),
      sessionAccess: HomeContentSessionAccess(
        ensureCacheLoaded: () => Get.find<UserSessionController>().ensureCacheLoaded(),
        currentSession: () => Get.find<UserSessionController>().userInfo.value,
        watchSession: (onChanged) {
          final worker = ever<UserSessionData>(
            Get.find<UserSessionController>().userInfo,
            onChanged,
          );
          return worker.dispose;
        },
      ),
      libraryAccess: HomeContentLibraryAccess(
        ensureCacheLoaded: () => Get.find<UserLibraryController>().ensureCacheLoaded(),
        loadScopedLocalData: (userId) => Get.find<UserLibraryController>().loadScopedLocalData(userId),
        refreshUserLibrary: () => Get.find<UserLibraryController>().refreshUserLibrary(),
        hasPlaylistData: () => Get.find<UserLibraryController>().hasPlaylistData,
        likedSongIds: _likedSongIdsSnapshot,
        randomLikedSongAlbumUrl: () => Get.find<UserLibraryController>().randomLikedSongAlbumUrl.value,
      ),
      validateLoginStateInBackground: () => Get.find<AuthController>().validateLoginStateInBackgroundIfNeeded(),
    ),
    fenix: true,
  );
}

/// Registers feature application services after playback and presentation adapters exist.
void registerFeatureApplications() {
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
      onBackgroundError: _reportPlaybackBackgroundError,
    ),
    permanent: true,
  );
  Get.put<CacheAnalysisService>(
    CacheAnalysisService(
      musicDataRepository: Get.find<MusicDataRepository>(),
      resourceIndexRepository: Get.find<LocalResourceIndexRepository>(),
    ),
    permanent: true,
  );
  Get.put<CacheAnalysisControllerFactory>(
    CacheAnalysisControllerFactory(
      service: Get.find<CacheAnalysisService>(),
    ),
    permanent: true,
  );
  Get.put<PlaylistArtworkColorService>(
    PlaylistArtworkColorService(
      imageCacheRepository: Get.find<LocalImageCacheRepository>(),
    ),
    permanent: true,
  );
  Get.put<LocalMediaScanRepository>(
    LocalMediaScanRepository(
      localMediaRepository: Get.find<LocalMediaRepository>(),
    ),
    permanent: true,
  );
  Get.put<LocalMediaScanController>(
    LocalMediaScanController(
      scanRepository: Get.find<LocalMediaScanRepository>(),
    ),
    permanent: true,
  );
}

/// Registers lazily-created feature controllers used by pages and shell widgets.
void registerFeatureControllers() {
  Get.lazyPut(
    () => PlayerController(
      playbackService: Get.find<PlaybackService>(),
      queueService: Get.find<PlaybackQueueService>(),
      commandService: Get.find<PlaybackUiCommandService>(),
      modeCommandService: Get.find<PlaybackModeCommandService>(),
      stateSynchronizer: Get.find<PlaybackStateSynchronizer>(),
      selectionService: Get.find<PlaybackSelectionService>(),
      lyricUiStateController: Get.find<PlaybackLyricUiStateController>(),
      preferencePort: Get.find<PlaybackPreferencePort>(),
      userContentPort: Get.find<PlaybackUserContentPort>(),
      artworkPresenter: Get.find<PlaybackArtworkPresenter>(),
      selectionUiEffectCoordinator: Get.find<PlaybackSelectionUiEffectCoordinator>(),
      downloadUseCase: Get.find<CurrentTrackDownloadUseCase>(),
      toastPort: Get.find<PlaybackToastPort>(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => RecentPlaybackController(
      repository: Get.find<PlaybackRepository>(),
      likedSongIds: _likedSongIdsSnapshot,
    ),
    fenix: true,
  );
  Get.lazyPut(() => ShellController(), fenix: true);
  Get.put<PersonalHomeControllerBundle>(
    PersonalHomeControllerBundle(
      playerController: Get.find<PlayerController>(),
      recentPlaybackController: Get.find<RecentPlaybackController>(),
      homeContentController: Get.find<HomeContentController>(),
      userLibraryController: Get.find<UserLibraryController>(),
    ),
    permanent: true,
  );
  Get.lazyPut(
    () => AuthController(
      repository: Get.find<AuthRepository>(),
      sessionAccess: AuthSessionAccess(
        currentSession: () => Get.find<UserSessionController>().userInfo.value,
        saveCurrentSession: (session) {
          Get.find<UserSessionController>().userInfo.value = session;
        },
        clearCurrentUser: () => Get.find<UserSessionController>().clearUser(),
        expireCurrentSession: () => Get.find<UserSessionController>().expireLoginSession(),
      ),
    ),
    fenix: true,
  );
  Get.put<AuthControllerBundle>(
    AuthControllerBundle(
      authController: Get.find<AuthController>(),
    ),
    permanent: true,
  );
  Get.lazyPut(
    () => AlbumPageControllerFactory(
      repository: Get.find<AlbumRepository>(),
      likedSongIds: _likedSongIdsSnapshot,
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => ArtistPageControllerFactory(
      repository: Get.find<ArtistRepository>(),
      likedSongIds: _likedSongIdsSnapshot,
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => CloudPageControllerFactory(
      repository: Get.find<CloudRepository>(),
      currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
      likedSongIds: _likedSongIdsSnapshot,
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => RadioControllerFactory(
      repository: Get.find<RadioRepository>(),
      currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
      likedSongIds: _likedSongIdsSnapshot,
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => LocalSongListControllerFactory(
      musicDataRepository: Get.find<MusicDataRepository>(),
      downloadRepository: Get.find<DownloadRepository>(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => PlaylistPageControllerFactory(
      repository: Get.find<PlaylistRepository>(),
      artworkColorService: Get.find<PlaylistArtworkColorService>(),
      likedSongIds: _likedSongIdsSnapshot,
      currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => CommentControllerFactory(
      repository: Get.find<CommentRepository>(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => UserProfileControllerFactory(
      repository: Get.find<UserRepository>(),
      currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
      logoutCurrentUser: () => Get.find<AuthController>().logoutCurrentUser(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => SearchPanelController(
      repository: Get.find<SearchRepository>(),
      likedSongIds: _likedSongIdsSnapshot,
      currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
    ),
    fenix: true,
  );
  Get.put<MusicPagePlaybackActions>(
    MusicPagePlaybackActions(
      playerController: Get.find<PlayerController>(),
      openPlaybackPanel: _openPlaybackPanel,
    ),
    permanent: true,
  );
  Get.put<MusicDetailControllerBundle>(
    MusicDetailControllerBundle(
      albumControllerFactory: Get.find<AlbumPageControllerFactory>(),
      artistControllerFactory: Get.find<ArtistPageControllerFactory>(),
      cloudControllerFactory: Get.find<CloudPageControllerFactory>(),
      playbackActions: Get.find<MusicPagePlaybackActions>(),
      playlistControllerFactory: Get.find<PlaylistPageControllerFactory>(),
      radioControllerFactory: Get.find<RadioControllerFactory>(),
    ),
    permanent: true,
  );
  Get.put<UtilityPageControllerBundle>(
    UtilityPageControllerBundle(
      cacheAnalysisControllerFactory: Get.find<CacheAnalysisControllerFactory>(),
      localSongListControllerFactory: Get.find<LocalSongListControllerFactory>(),
      userProfileControllerFactory: Get.find<UserProfileControllerFactory>(),
    ),
    permanent: true,
  );
  Get.put<SettingsPageControllerBundle>(
    SettingsPageControllerBundle(
      localMediaScanController: Get.find<LocalMediaScanController>(),
      playerController: Get.find<PlayerController>(),
      settingsController: Get.find<SettingsController>(),
    ),
    permanent: true,
  );
  Get.put<AppHomeControllerBundle>(
    AppHomeControllerBundle(
      commentControllerFactory: Get.find<CommentControllerFactory>(),
      homeShellController: Get.find<HomeShellController>(),
      playerController: Get.find<PlayerController>(),
      searchController: Get.find<SearchPanelController>(),
      settingsController: Get.find<SettingsController>(),
    ),
    permanent: true,
  );
}

void _openPlaybackPanel() {
  final shellController = Get.find<ShellController>();
  shellController.jumpBottomPanelToPage(0);
  shellController.openBottomPanel();
}

void _reportPlaybackBackgroundError(
  String taskName,
  String? trackId,
  Object error,
  StackTrace stackTrace,
) {
  developer.log(
    'playback.backgroundTask.failed task=$taskName trackId=${trackId ?? ''}',
    name: 'Playback',
    error: error,
    stackTrace: stackTrace,
  );
}

List<int> _likedSongIdsSnapshot() {
  return Get.find<UserLibraryController>().likedSongIdSnapshot;
}
