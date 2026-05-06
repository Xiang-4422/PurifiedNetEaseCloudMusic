import 'package:bujuan/app/presentation_adapters/playback_artwork_presenter.dart';
import 'package:bujuan/app/presentation_adapters/playback_selection_ui_effect_coordinator.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/library/library_repository.dart';
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
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/settings/application/cache_analysis_service.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';

/// Feature 控制器注册器，集中注册共享页面控制器和少量 feature service。
class FeatureControllerRegistrar {
  /// 禁止实例化 feature 控制器注册器。
  const FeatureControllerRegistrar._();

  /// 注册 feature service 和共享页面控制器。
  static void register() {
    _registerFeatureApplications();
    _registerControllers();
  }

  static void _registerFeatureApplications() {
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
        resourceIndexRepository: Get.find(),
      ),
      permanent: true,
    );
  }

  static void _registerControllers() {
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
}
