import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/app/presentation_adapters/playback_artwork_presenter.dart';
import 'package:bujuan/app/presentation_adapters/playback_selection_ui_effect_coordinator.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/explore/explore_application_service.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/playback/application/confirmed_playback_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_action_port.dart';
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
import 'package:bujuan/features/playlist/application/playlist_playback_use_case.dart';
import 'package:bujuan/features/playlist/application/playlist_playback_action.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/application/search_application_service.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';

/// Feature 控制器注册器，集中注册页面控制器和 feature application service。
class FeatureControllerRegistrar {
  /// 禁止实例化 feature 控制器注册器。
  const FeatureControllerRegistrar._();

  /// 注册 feature application、页面控制器和页面控制器工厂。
  static void register() {
    _registerFeatureApplications();
    _registerControllers();
    _registerFeatureFactories();
  }

  static void _registerFeatureApplications() {
    Get.put<ExploreApplicationService>(
      ExploreApplicationService(
        exploreRepository: Get.find<ExploreRepository>(),
        playlistRepository: Get.find<PlaylistRepository>(),
        likedSongIds: () => Get.find<UserLibraryController>().likedSongIds,
        currentUserId: () =>
            Get.find<UserSessionController>().userInfo.value.userId,
        playPlaylist: (
          playlist,
          index, {
          required playListName,
          playListNameHeader = '',
        }) =>
            Get.find<PlayerController>().playPlaylist(
          playlist,
          index,
          playListName: playListName,
          playListNameHeader: playListNameHeader,
        ),
      ),
      permanent: true,
    );
    Get.put<PlaybackActionPort>(
      PlaybackActionPort(
        playPlaylist: (
          playList,
          index, {
          playListName = '无名歌单',
          playListNameHeader = '',
        }) =>
            Get.find<PlayerController>().playPlaylist(
          playList,
          index,
          playListName: playListName,
          playListNameHeader: playListNameHeader,
        ),
        playOrPause: () => Get.find<PlayerController>().playOrPause(),
        skipToPrevious: () =>
            Get.find<PlayerController>().skipToPreviousTrack(),
        skipToNext: () => Get.find<PlayerController>().skipToNextTrack(),
        seekTo: (position) => Get.find<PlayerController>().seekTo(position),
        setRepeatMode: (repeatMode) =>
            Get.find<PlayerController>().setRepeatMode(repeatMode),
        setOrderMode: (orderMode) =>
            Get.find<PlayerController>().setOrderMode(orderMode),
        openFmMode: () => Get.find<PlayerController>().openFmMode(),
        openHeartBeatMode: (startSongId, {required fromPlayAll}) =>
            Get.find<PlayerController>().openHeartBeatMode(
          startSongId,
          fromPlayAll: fromPlayAll,
        ),
        currentSong: () => Get.find<PlayerController>().currentSongState.value,
        isPlaying: () => Get.find<PlayerController>().isPlaying.value,
        isFmMode: () => Get.find<PlayerController>().isFmModeValue,
        isHeartBeatMode: () =>
            Get.find<PlayerController>().isHeartBeatModeValue,
        sessionState: () => Get.find<PlayerController>().sessionState.value,
      ),
      permanent: true,
    );
    Get.put<PlaylistPlaybackAction>(
      PlaylistPlaybackAction(
        repository: Get.find<PlaylistRepository>(),
        currentPlaylistName: () =>
            Get.find<PlayerController>().sessionState.value.playlistName,
        toggleCurrentPlayback: () => Get.find<PlayerController>().playOrPause(),
        playPlaylist: (
          playlist,
          index, {
          required playListName,
          playListNameHeader = '',
        }) =>
            Get.find<PlayerController>().playPlaylist(
          playlist,
          index,
          playListName: playListName,
          playListNameHeader: playListNameHeader,
        ),
      ),
      permanent: true,
    );
    Get.put<PlaylistPlaybackUseCase>(
      PlaylistPlaybackUseCase(
        playbackAction: Get.find<PlaybackActionPort>(),
      ),
      permanent: true,
    );
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
    Get.put<SearchApplicationService>(
      SearchApplicationService(repository: Get.find<SearchRepository>()),
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
        selectionUiEffectCoordinator:
            Get.find<PlaybackSelectionUiEffectCoordinator>(),
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
        applicationService: Get.find<ExploreApplicationService>(),
      ),
      fenix: true,
    );
    Get.lazyPut(() => ShellController(), fenix: true);
  }

  static void _registerFeatureFactories() {
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
        searchApplicationService: Get.find<SearchApplicationService>(),
        userRepository: Get.find<UserRepository>(),
        userSessionController: Get.find<UserSessionController>(),
        userLibraryController: Get.find<UserLibraryController>(),
      ),
      permanent: true,
    );
  }
}
