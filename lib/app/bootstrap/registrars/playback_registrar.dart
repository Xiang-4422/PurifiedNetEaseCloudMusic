import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/application/playback_mode_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_preference_port.dart';
import 'package:bujuan/features/playback/application/playback_queue_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/application/playback_ui_command_service.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:get/get.dart';

class PlaybackRegistrar {
  const PlaybackRegistrar._();

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
    Get.put<PlaybackUiCommandService>(
      PlaybackUiCommandService(
        playbackService: Get.find<PlaybackService>(),
        modeCoordinator: Get.find<PlaybackModeCoordinator>(),
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
