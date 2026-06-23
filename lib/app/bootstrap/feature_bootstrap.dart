import 'dart:developer' as developer;

import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:bujuan/features/album/album_page_controller.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_page_controller.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/cloud/cloud_page_controller_factory.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
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
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_controller_factory.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
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
      sessionController: Get.find<UserSessionController>(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => RecommendationController(
      repository: Get.find<UserRepository>(),
      playlistRepository: Get.find<PlaylistRepository>(),
      sessionController: Get.find<UserSessionController>(),
      libraryController: Get.find<UserLibraryController>(),
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
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
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
    () => AlbumPageController(
      repository: Get.find<AlbumRepository>(),
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => ArtistPageController(
      repository: Get.find<ArtistRepository>(),
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => CloudPageControllerFactory(
      repository: Get.find<CloudRepository>(),
      currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => RadioControllerFactory(
      repository: Get.find<RadioRepository>(),
      currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => SearchPanelController(
      repository: Get.find<SearchRepository>(),
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
      currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
    ),
    fenix: true,
  );
  Get.lazyPut(() => ShellController(), fenix: true);
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
