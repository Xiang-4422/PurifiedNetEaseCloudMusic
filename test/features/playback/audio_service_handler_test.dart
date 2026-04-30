import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/audio_service_handler.dart';
import 'package:bujuan/features/playback/application/playback_engine_adapter.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  group('AudioServiceHandler', () {
    test('only applies the latest rapid playIndex request', () async {
      final engine = _FakePlaybackEngine();
      final resolver = _FakePlaybackSourceResolver();
      final handler = AudioServiceHandler(
        queueStore: _FakePlaybackQueueStore(),
        restoreCoordinator: _FakePlaybackRestoreCoordinator(),
        sourceResolver: resolver,
        engineAdapter: engine,
      );
      final queue = [
        _mediaItem('1'),
        _mediaItem('2'),
      ];
      await handler.updateQueue(queue);

      final first = handler.playIndex(audioSourceIndex: 0, playNow: true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final second = handler.playIndex(audioSourceIndex: 1, playNow: true);
      await Future.wait([first, second]);

      expect(engine.sources.map((source) => source.url), ['url-2']);
      expect(engine.playCount, 1);
      expect(handler.mediaItem.value?.id, '2');
      expect(handler.playbackState.value.queueIndex, 1);
    });
  });
}

MediaItem _mediaItem(String id) {
  return MediaItem(id: id, title: 'Track $id');
}

class _FakePlaybackEngine implements PlaybackEnginePort {
  final StreamController<PlaybackEvent> _events =
      StreamController<PlaybackEvent>.broadcast();

  final List<PlaybackResolvedSource> sources = <PlaybackResolvedSource>[];

  int playCount = 0;

  bool _hasAudioSource = false;

  @override
  Duration get bufferedPosition => Duration.zero;

  @override
  bool get hasAudioSource => _hasAudioSource;

  @override
  Stream<PlaybackEvent> get playbackEventStream => _events.stream;

  @override
  bool get playing => playCount > 0;

  @override
  Duration get position => Duration.zero;

  @override
  ProcessingState get processingState => ProcessingState.ready;

  @override
  bool get shuffleModeEnabled => false;

  @override
  double get speed => 1;

  @override
  Future<void> dispose() async {
    await _events.close();
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {
    playCount++;
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setSource(PlaybackResolvedSource source) async {
    sources.add(source);
    _hasAudioSource = true;
  }
}

class _FakePlaybackSourceResolver implements PlaybackSourceResolver {
  @override
  Future<PlaybackResolvedSource> resolve(
    MediaItem mediaItem, {
    required bool preferHighQuality,
  }) async {
    if (mediaItem.id == '1') {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'url-${mediaItem.id}',
    );
  }
}

class _FakePlaybackQueueStore implements PlaybackQueueStore {
  @override
  Future<List<PlaybackQueueItem>> decodeQueue(
      List<String> queueSnapshot) async {
    return const <PlaybackQueueItem>[];
  }

  @override
  Future<void> saveCurrentSong(String currentSongId) async {}

  @override
  Future<void> savePlaybackMode(PlaybackMode playbackMode) async {}

  @override
  Future<void> savePlaylistMeta({
    required String playlistName,
    required String playlistHeader,
  }) async {}

  @override
  Future<void> savePosition(Duration position) async {}

  @override
  Future<void> saveQueueSnapshot({
    required List<PlaybackQueueItem> originalSongs,
    required String playlistName,
    required String playlistHeader,
  }) async {}

  @override
  Future<void> saveRepeatMode(PlaybackRepeatMode repeatMode) async {}
}

class _FakePlaybackRestoreCoordinator implements PlaybackRestoreCoordinator {
  @override
  Future<PlaybackRestoreSnapshot> loadSnapshot() async {
    return const PlaybackRestoreSnapshot(
      playbackMode: PlaybackMode.playlist,
      repeatMode: PlaybackRepeatMode.all,
      queue: <PlaybackQueueItem>[],
      index: -1,
      playlistName: '',
      playlistHeader: '',
      position: Duration.zero,
    );
  }
}
