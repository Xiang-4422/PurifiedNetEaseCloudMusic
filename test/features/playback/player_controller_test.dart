import 'dart:async';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_lyric_ui_state_controller.dart';
import 'package:bujuan/features/playback/application/playback_mode_command_service.dart';
import 'package:bujuan/features/playback/application/playback_preference_port.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_state_synchronizer.dart';
import 'package:bujuan/features/playback/application/playback_toast_port.dart';
import 'package:bujuan/features/playback/application/playback_ui_command_service.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_artwork_presenter.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/playback_runtime_state.dart';
import 'package:bujuan/features/playback/playback_queue_state.dart';
import 'package:bujuan/features/playback/playback_selection_ui_effect_coordinator.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerController helpers', () {
    test('reads and toggles high quality playback preference through playback boundary', () async {
      var highQualityEnabled = false;
      var toggleCount = 0;
      final controller = _playerController(
        preferencePort: _preferencePort(
          isHighQualityEnabled: () => highQualityEnabled,
          toggleHighQuality: () async {
            toggleCount++;
            highQualityEnabled = !highQualityEnabled;
          },
        ),
      );

      expect(controller.isHighQualityPlaybackPreferred(), isFalse);

      await controller.toggleHighQualityPlaybackPreference();

      expect(toggleCount, 1);
      expect(controller.isHighQualityPlaybackPreferred(), isTrue);
    });

    test('resolves playback item liked state through playback boundary', () {
      final controller = _playerController(
        userContentPort: _userContentPort(
          likedSongIds: () => const [1],
        ),
      );

      expect(
        controller.isPlaybackItemLiked(
          _queueItem('netease:1', sourceId: '1'),
        ),
        isTrue,
      );
      expect(
        controller.isPlaybackItemLiked(
          _queueItem('netease:2', sourceId: '2', isLiked: true),
        ),
        isTrue,
      );
      expect(
        controller.isPlaybackItemLiked(
          _queueItem('local:/music/a.mp3', sourceId: 'local:/music/a.mp3'),
        ),
        isFalse,
      );
    });

    test('coalesces concurrent like toggles for the same playback item', () async {
      final item = _queueItem('netease:1', sourceId: '1');
      final updatedItem = item.copyWith(isLiked: true);
      final toggleCompleter = Completer<PlaybackQueueItem?>();
      final queueService = _FakePlaybackQueueService();
      final playbackService = _FakePlaybackService();
      var toggleCount = 0;
      final controller = _playerController(
        playbackService: playbackService,
        queueService: queueService,
        userContentPort: _userContentPort(
          toggleLikeStatus: (_) {
            toggleCount++;
            return toggleCompleter.future;
          },
        ),
      );
      controller.runtimeState.value = PlaybackRuntimeState(
        queue: [item],
        currentSong: item,
      );

      final first = controller.toggleLikeFromPlayback(item);
      final second = controller.toggleLikeFromPlayback(item);
      await Future<void>.delayed(Duration.zero);

      expect(toggleCount, 1);

      toggleCompleter.complete(updatedItem);
      await Future.wait([first, second]);

      expect(queueService.updatedItems, [updatedItem]);
      expect(playbackService.updatedItems, [updatedItem]);
      expect(controller.runtimeState.value.currentSong.isLiked, isTrue);
    });

    test('normalizes current item id before applying resolved artwork', () async {
      final rawItem = _queueItem(' 1 ', sourceId: '1');
      final currentItem = _queueItem('1', sourceId: '1');
      final updatedItem = currentItem.copyWith(
        localArtworkPath: '/tmp/cover.jpg',
      );
      final queueService = _FakePlaybackQueueService();
      final playbackService = _FakePlaybackService();
      final artworkPresenter = _FakePlaybackArtworkPresenter(
        resolveMissingArtworkHandler: (item) async {
          return item.copyWith(localArtworkPath: updatedItem.localArtworkPath);
        },
      );
      final controller = _playerController(
        playbackService: playbackService,
        queueService: queueService,
        artworkPresenter: artworkPresenter,
      );
      controller.runtimeState.value = PlaybackRuntimeState(
        queue: [rawItem],
        currentSong: currentItem,
      );

      await controller.ensureCurrentTrackArtwork(rawItem);

      expect(artworkPresenter.resolveMissingArtworkItems.map((item) => item.id), ['1']);
      expect(queueService.updatedItems.map((item) => item.id), ['1']);
      expect(playbackService.updatedItems.map((item) => item.id), ['1']);
      expect(controller.runtimeState.value.currentSong.id, '1');
      expect(controller.runtimeState.value.currentSong.localArtworkPath, '/tmp/cover.jpg');
      expect(controller.runtimeState.value.queue.map((item) => item.id), ['1']);
      expect(controller.runtimeState.value.queue.single.localArtworkPath, '/tmp/cover.jpg');
    });

    test('builds mini player feedback metric details for success', () {
      expect(
        miniPlayerFeedbackMetricDetails(
          action: 'play',
          succeeded: true,
        ),
        'action=play result=success',
      );
      expect(
        miniPlayerFeedbackMetricDetails(
          action: 'pause',
          succeeded: true,
        ),
        'action=pause result=success',
      );
    });

    test('builds mini player feedback metric details for failures', () {
      expect(
        miniPlayerFeedbackMetricDetails(
          action: 'play',
          succeeded: false,
          error: StateError('play failed'),
        ),
        'action=play result=error error=StateError',
      );
      expect(
        miniPlayerFeedbackMetricDetails(
          action: 'pause',
          succeeded: false,
        ),
        'action=pause result=error',
      );
    });

    test('builds mini player skip feedback metric details', () {
      expect(
        miniPlayerFeedbackMetricDetails(
          action: 'skip_previous',
          succeeded: true,
        ),
        'action=skip_previous result=success',
      );
      expect(
        miniPlayerFeedbackMetricDetails(
          action: 'skip_next',
          succeeded: false,
          error: StateError('skip failed'),
        ),
        'action=skip_next result=error error=StateError',
      );
    });

    test('delegates mini player skip commands through feedback boundary', () async {
      final commandService = _FakePlaybackUiCommandService();
      final controller = _playerController(commandService: commandService);

      await controller.skipToPreviousTrackFromMiniPlayer();
      await controller.skipToNextTrackFromMiniPlayer();

      expect(commandService.previousTrackCount, 1);
      expect(commandService.nextTrackCount, 1);
    });

    test('keeps mini player skip command failures visible to callers', () async {
      final commandService = _FakePlaybackUiCommandService(
        nextTrackError: StateError('skip failed'),
      );
      final controller = _playerController(commandService: commandService);

      await expectLater(
        controller.skipToNextTrackFromMiniPlayer(),
        throwsStateError,
      );

      expect(commandService.nextTrackCount, 1);
    });
  });
}

PlayerController _playerController({
  _FakePlaybackService? playbackService,
  _FakePlaybackQueueService? queueService,
  PlaybackUiCommandService? commandService,
  PlaybackPreferencePort? preferencePort,
  PlaybackUserContentPort? userContentPort,
  PlaybackArtworkPresenter? artworkPresenter,
}) {
  return PlayerController(
    playbackService: playbackService ?? _FakePlaybackService(),
    queueService: queueService ?? _FakePlaybackQueueService(),
    commandService: commandService ?? _FakePlaybackUiCommandService(),
    modeCommandService: _FakePlaybackModeCommandService(),
    stateSynchronizer: _FakePlaybackStateSynchronizer(),
    selectionService: _FakePlaybackSelectionService(),
    lyricUiStateController: _FakePlaybackLyricUiStateController(),
    preferencePort: preferencePort ?? _preferencePort(),
    userContentPort: userContentPort ?? _userContentPort(),
    artworkPresenter: artworkPresenter ?? _FakePlaybackArtworkPresenter(),
    selectionUiEffectCoordinator: _FakePlaybackSelectionUiEffectCoordinator(),
    downloadUseCase: _FakeCurrentTrackDownloadUseCase(),
    toastPort: _FakePlaybackToastPort(),
  );
}

PlaybackPreferencePort _preferencePort({
  bool Function()? isHighQualityEnabled,
  Future<void> Function()? toggleHighQuality,
}) {
  return PlaybackPreferencePort(
    isHighQualityEnabled: isHighQualityEnabled ?? () => false,
    toggleHighQuality: toggleHighQuality ?? () async {},
  );
}

PlaybackUserContentPort _userContentPort({
  Future<PlaybackQueueItem?> Function(PlaybackQueueItem item)? toggleLikeStatus,
  List<int> Function()? likedSongIds,
}) {
  return PlaybackUserContentPort(
    toggleLikeStatus: toggleLikeStatus ?? (_) async => null,
    likedSongIds: likedSongIds ?? () => const <int>[],
    ensureLikedSongsLoaded: () async {},
    likedSongs: () => const <PlaybackQueueItem>[],
    loadFmSongs: () async => const <PlaybackQueueItem>[],
    loadHeartBeatSongs: (_, __, ___) async => const <PlaybackQueueItem>[],
    randomLikedSongId: () => '',
  );
}

PlaybackQueueItem _queueItem(
  String id, {
  required String sourceId,
  bool isLiked = false,
  String? localArtworkPath,
}) {
  return PlaybackQueueItem(
    id: id,
    sourceId: sourceId,
    title: 'Track $id',
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: null,
    localArtworkPath: localArtworkPath,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: isLiked,
    isCached: false,
  );
}

class _FakePlaybackService implements PlaybackService {
  final List<PlaybackQueueItem> updatedItems = <PlaybackQueueItem>[];

  @override
  Future<void> updateQueueItem(PlaybackQueueItem item) async {
    updatedItems.add(item);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackQueueService implements PlaybackQueueService {
  final List<PlaybackQueueItem> updatedItems = <PlaybackQueueItem>[];

  @override
  Future<PlaybackQueueState> updateQueueItem(PlaybackQueueItem item) async {
    updatedItems.add(item);
    return const PlaybackQueueState();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackUiCommandService implements PlaybackUiCommandService {
  _FakePlaybackUiCommandService({
    this.nextTrackError,
  });

  final Object? nextTrackError;
  int previousTrackCount = 0;
  int nextTrackCount = 0;

  @override
  Future<void> skipToPreviousTrack() async {
    previousTrackCount++;
  }

  @override
  Future<void> skipToNextTrack() async {
    nextTrackCount++;
    final error = nextTrackError;
    if (error != null) {
      throw error;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackModeCommandService implements PlaybackModeCommandService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackStateSynchronizer implements PlaybackStateSynchronizer {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackSelectionService implements PlaybackSelectionService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackLyricUiStateController implements PlaybackLyricUiStateController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackArtworkPresenter implements PlaybackArtworkPresenter {
  _FakePlaybackArtworkPresenter({
    this.resolveMissingArtworkHandler,
  });

  final FutureOr<PlaybackQueueItem?> Function(PlaybackQueueItem item)? resolveMissingArtworkHandler;
  final List<PlaybackQueueItem> resolveMissingArtworkItems = <PlaybackQueueItem>[];

  @override
  Future<PlaybackQueueItem?> resolveMissingArtwork(PlaybackQueueItem currentItem) async {
    resolveMissingArtworkItems.add(currentItem);
    return resolveMissingArtworkHandler?.call(currentItem);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackSelectionUiEffectCoordinator implements PlaybackSelectionUiEffectCoordinator {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCurrentTrackDownloadUseCase implements CurrentTrackDownloadUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackToastPort implements PlaybackToastPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
