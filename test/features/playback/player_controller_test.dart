import 'dart:async';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/current_track_download_use_case.dart';
import 'package:bujuan/features/playback/application/playback_lyric_ui_state_controller.dart';
import 'package:bujuan/features/playback/application/playback_mode_command_service.dart';
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

    test('builds mini player feedback metric details for success', () {
      expect(
        miniPlayerFeedbackMetricDetails(
          wasPlaying: false,
          succeeded: true,
        ),
        'action=play result=success',
      );
      expect(
        miniPlayerFeedbackMetricDetails(
          wasPlaying: true,
          succeeded: true,
        ),
        'action=pause result=success',
      );
    });

    test('builds mini player feedback metric details for failures', () {
      expect(
        miniPlayerFeedbackMetricDetails(
          wasPlaying: false,
          succeeded: false,
          error: StateError('play failed'),
        ),
        'action=play result=error error=StateError',
      );
      expect(
        miniPlayerFeedbackMetricDetails(
          wasPlaying: true,
          succeeded: false,
        ),
        'action=pause result=error',
      );
    });
  });
}

PlayerController _playerController({
  _FakePlaybackService? playbackService,
  _FakePlaybackQueueService? queueService,
  PlaybackUserContentPort? userContentPort,
}) {
  return PlayerController(
    playbackService: playbackService ?? _FakePlaybackService(),
    queueService: queueService ?? _FakePlaybackQueueService(),
    commandService: _FakePlaybackUiCommandService(),
    modeCommandService: _FakePlaybackModeCommandService(),
    stateSynchronizer: _FakePlaybackStateSynchronizer(),
    selectionService: _FakePlaybackSelectionService(),
    lyricUiStateController: _FakePlaybackLyricUiStateController(),
    userContentPort: userContentPort ?? _userContentPort(),
    artworkPresenter: _FakePlaybackArtworkPresenter(),
    selectionUiEffectCoordinator: _FakePlaybackSelectionUiEffectCoordinator(),
    downloadUseCase: _FakeCurrentTrackDownloadUseCase(),
    toastPort: _FakePlaybackToastPort(),
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
    localArtworkPath: null,
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
