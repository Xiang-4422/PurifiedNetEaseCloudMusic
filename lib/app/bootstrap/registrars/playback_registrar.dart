import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/playback/application/confirmed_playback_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
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
import 'package:bujuan/features/playback/application/playback_switch_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_ui_command_service.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:get/get.dart';

/// 播放应用层注册器，统一装配播放服务、队列、模式和下载用例。
class PlaybackRegistrar {
  /// 禁止实例化播放注册器。
  const PlaybackRegistrar._();

  /// 注册播放链路需要的 application service 与 port。
  static void register() {
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
        restoreCoordinator: Get.find<PlaybackRestoreCoordinator>(),
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
        isHighQualityEnabled: () =>
            Get.find<SettingsController>().isHighSoundQualityOpen.value,
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
}
