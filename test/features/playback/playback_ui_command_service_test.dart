import 'dart:async';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_mode_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_mode_switch_context.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_switch_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/application/playback_ui_command_service.dart';
import 'package:bujuan/features/playback/playback_queue_state.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackUiCommandService', () {
    test('coalesces concurrent pause commands', () async {
      final playbackService = _FakePlaybackService();
      final switchCoordinator = _FakePlaybackSwitchCoordinator();
      final commandService = _commandService(
        playbackService: playbackService,
        switchCoordinator: switchCoordinator,
      );

      final first = commandService.playOrPause(isPlaying: true);
      final second = commandService.playOrPause(isPlaying: true);
      await Future<void>.delayed(Duration.zero);

      expect(switchCoordinator.cancelAutoplayIntentCount, 1);
      expect(playbackService.pauseCount, 1);

      playbackService.completePause();
      await Future.wait([first, second]);

      final third = commandService.playOrPause(isPlaying: true);
      await Future<void>.delayed(Duration.zero);
      expect(playbackService.pauseCount, 2);

      playbackService.completePause();
      await third;
    });

    test('coalesces concurrent play commands', () async {
      final playbackService = _FakePlaybackService(hasAudioSource: true);
      final commandService = _commandService(playbackService: playbackService);

      final first = commandService.playOrPause(isPlaying: false);
      final second = commandService.playOrPause(isPlaying: false);
      await Future<void>.delayed(Duration.zero);

      expect(playbackService.playCount, 1);

      playbackService.completePlay();
      await Future.wait([first, second]);
    });

    test('resumes playback when selected and confirmed ids differ only by whitespace', () async {
      final playbackService = _FakePlaybackService(hasAudioSource: true);
      final selectionService = _FakePlaybackSelectionService(
        state: PlaybackSelectionState(
          queue: [_item(' 1 ')],
          selectedItem: _item(' 1 '),
          selectedIndex: 0,
          sourceStatus: PlaybackSelectionSourceStatus.idle,
        ),
      );
      final queueService = _FakePlaybackQueueService(
        state: PlaybackQueueState(
          activeQueue: [_item('1')],
          confirmedIndex: 0,
        ),
      );
      final commandService = _commandService(
        playbackService: playbackService,
        queueService: queueService,
        selectionService: selectionService,
      );

      final command = commandService.playOrPause(isPlaying: false);
      await Future<void>.delayed(Duration.zero);

      expect(playbackService.playCount, 1);
      expect(selectionService.submitCurrentCount, 0);

      playbackService.completePlay();
      await command;
    });

    test('coalesces concurrent source submit commands', () async {
      final playbackService = _FakePlaybackService(hasAudioSource: false);
      final selectionService = _FakePlaybackSelectionService(
        state: PlaybackSelectionState(
          queue: [_item('1')],
          selectedItem: _item('1'),
          selectedIndex: 0,
          sourceStatus: PlaybackSelectionSourceStatus.idle,
        ),
      );
      final commandService = _commandService(
        playbackService: playbackService,
        selectionService: selectionService,
      );

      final first = commandService.playOrPause(isPlaying: false);
      final second = commandService.playOrPause(isPlaying: false);
      await Future<void>.delayed(Duration.zero);

      expect(selectionService.submitCurrentCount, 1);

      selectionService.completeSubmit();
      await Future.wait([first, second]);
    });

    test('allows retry after a failed command releases the gate', () async {
      final playbackService = _FakePlaybackService();
      final commandService = _commandService(playbackService: playbackService);

      final failed = commandService.playOrPause(isPlaying: true);
      await Future<void>.delayed(Duration.zero);
      playbackService.completePauseError(StateError('pause failed'));
      await expectLater(failed, throwsA(isA<StateError>()));

      final retry = commandService.playOrPause(isPlaying: true);
      await Future<void>.delayed(Duration.zero);
      expect(playbackService.pauseCount, 2);

      playbackService.completePause();
      await retry;
    });

    test('starts heartbeat mode with typed switch context', () async {
      final commandService = _commandService();
      final syncedModes = <PlaybackMode>[];
      final startedSongIds = <String>[];
      var startedFromPlayAll = true;

      await commandService.switchMode(
        currentMode: PlaybackMode.playlist,
        newMode: PlaybackMode.heartbeat,
        isPlaying: true,
        syncMode: (mode) async => syncedModes.add(mode),
        playOrPauseWhenPaused: () async {},
        startRoaming: () async => false,
        startHeartBeat: (startSongId, fromPlayAll) async {
          startedSongIds.add(startSongId);
          startedFromPlayAll = fromPlayAll;
          return true;
        },
        heartBeatModeContext: const PlaybackHeartBeatModeContext(
          startSongId: '42',
          fromPlayAll: false,
        ),
      );

      expect(syncedModes, [PlaybackMode.heartbeat]);
      expect(startedSongIds, ['42']);
      expect(startedFromPlayAll, isFalse);
    });

    test('rolls back heartbeat mode when switch context is missing', () async {
      final commandService = _commandService();
      final syncedModes = <PlaybackMode>[];
      var startHeartBeatCount = 0;

      await commandService.switchMode(
        currentMode: PlaybackMode.playlist,
        newMode: PlaybackMode.heartbeat,
        isPlaying: true,
        syncMode: (mode) async => syncedModes.add(mode),
        playOrPauseWhenPaused: () async {},
        startRoaming: () async => false,
        startHeartBeat: (startSongId, fromPlayAll) async {
          startHeartBeatCount++;
          return true;
        },
        heartBeatModeContext: null,
      );

      expect(syncedModes, [PlaybackMode.heartbeat, PlaybackMode.playlist]);
      expect(startHeartBeatCount, 0);
    });

    test('rolls back heartbeat mode when startup fails', () async {
      final commandService = _commandService();
      final syncedModes = <PlaybackMode>[];

      await commandService.switchMode(
        currentMode: PlaybackMode.playlist,
        newMode: PlaybackMode.heartbeat,
        isPlaying: true,
        syncMode: (mode) async => syncedModes.add(mode),
        playOrPauseWhenPaused: () async {},
        startRoaming: () async => false,
        startHeartBeat: (startSongId, fromPlayAll) async => false,
        heartBeatModeContext: const PlaybackHeartBeatModeContext(
          startSongId: '42',
          fromPlayAll: true,
        ),
      );

      expect(syncedModes, [PlaybackMode.heartbeat, PlaybackMode.playlist]);
    });
  });
}

PlaybackUiCommandService _commandService({
  _FakePlaybackService? playbackService,
  _FakePlaybackQueueService? queueService,
  _FakePlaybackSelectionService? selectionService,
  _FakePlaybackSwitchCoordinator? switchCoordinator,
}) {
  return PlaybackUiCommandService(
    playbackService: playbackService ?? _FakePlaybackService(),
    modeCoordinator: _FakePlaybackModeCoordinator(),
    queueService: queueService ?? _FakePlaybackQueueService(),
    selectionService: selectionService ?? _FakePlaybackSelectionService(),
    switchCoordinator: switchCoordinator ?? _FakePlaybackSwitchCoordinator(),
  );
}

PlaybackQueueItem _item(String id) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
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
    isLiked: false,
    isCached: false,
  );
}

class _FakePlaybackService implements PlaybackService {
  _FakePlaybackService({this.hasAudioSource = false});

  @override
  final bool hasAudioSource;

  final List<Completer<void>> _playCompleters = <Completer<void>>[];
  final List<Completer<void>> _pauseCompleters = <Completer<void>>[];

  int get playCount => _playCompleters.length;

  int get pauseCount => _pauseCompleters.length;

  @override
  Future<void> play() {
    final completer = Completer<void>();
    _playCompleters.add(completer);
    return completer.future;
  }

  @override
  Future<void> pause() {
    final completer = Completer<void>();
    _pauseCompleters.add(completer);
    return completer.future;
  }

  void completePlay() {
    _playCompleters.last.complete();
  }

  void completePause() {
    _pauseCompleters.last.complete();
  }

  void completePauseError(Object error) {
    _pauseCompleters.last.completeError(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackQueueService implements PlaybackQueueService {
  _FakePlaybackQueueService({
    this.state = const PlaybackQueueState(),
  });

  @override
  final PlaybackQueueState state;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackSelectionService implements PlaybackSelectionService {
  _FakePlaybackSelectionService({
    this.state = const PlaybackSelectionState(),
  });

  @override
  PlaybackSelectionState state;

  final List<Completer<void>> _submitCompleters = <Completer<void>>[];

  int get submitCurrentCount => _submitCompleters.length;

  @override
  Future<void> submitCurrent({
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) {
    final completer = Completer<void>();
    _submitCompleters.add(completer);
    return completer.future;
  }

  void completeSubmit() {
    _submitCompleters.last.complete();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackSwitchCoordinator implements PlaybackSwitchCoordinator {
  int cancelAutoplayIntentCount = 0;

  @override
  void cancelAutoplayIntent() {
    cancelAutoplayIntentCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackModeCoordinator implements PlaybackModeCoordinator {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
