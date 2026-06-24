import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/features/playback/application/audio_service_handler.dart';
import 'package:bujuan/features/playback/application/playback_engine_adapter.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  group('AudioServiceHandler', () {
    test('replaceSource publishes confirmed media item after source set', () async {
      final engine = _FakePlaybackEngine();
      final handler = AudioServiceHandler(engineAdapter: engine);
      await handler.updateQueue([_mediaItem('1')]);

      final success = await handler.replaceSource(
        audioSourceIndex: 0,
        mediaItemToPlay: _mediaItem('1'),
        source: const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.url,
          url: 'url-1',
        ),
        playNow: true,
      );

      expect(success, isTrue);
      expect(engine.sources.map((source) => source.url), ['url-1']);
      expect(engine.playCount, 1);
      expect(handler.mediaItem.value?.id, '1');
      expect(handler.playbackState.value.queueIndex, 0);
      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.ready,
      );
    });

    test('replaceSource returns false when engine rejects source', () async {
      final engine = _FakePlaybackEngine(
        failingSourceKinds: {PlaybackResolvedSourceKind.filePath},
      );
      final handler = AudioServiceHandler(engineAdapter: engine);
      await handler.updateQueue([_mediaItem('1')]);

      final success = await handler.replaceSource(
        audioSourceIndex: 0,
        mediaItemToPlay: _mediaItem('1'),
        source: const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.filePath,
          url: 'local-cache.mp3',
        ),
        playNow: true,
      );

      expect(success, isFalse);
      expect(handler.mediaItem.value, isNull);
      expect(engine.playCount, 0);
    });

    test('replaceSource pauses current engine at source replacement boundary', () async {
      final engine = _FakePlaybackEngine(initialPlaying: true);
      final handler = AudioServiceHandler(engineAdapter: engine);
      await handler.updateQueue([_mediaItem('1')]);

      await handler.replaceSource(
        audioSourceIndex: 0,
        mediaItemToPlay: _mediaItem('1'),
        source: const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.url,
          url: 'url-1',
        ),
        playNow: true,
      );

      expect(engine.pauseCount, 1);
      expect(engine.playCount, 1);
      expect(engine.playing, isTrue);
    });

    test('replaceSource does not wait for engine play completion', () async {
      final engine = _FakePlaybackEngine(holdPlayFuture: true);
      final handler = AudioServiceHandler(engineAdapter: engine);
      await handler.updateQueue([_mediaItem('1')]);

      final success = await handler
          .replaceSource(
            audioSourceIndex: 0,
            mediaItemToPlay: _mediaItem('1'),
            source: const PlaybackResolvedSource(
              kind: PlaybackResolvedSourceKind.url,
              url: 'url-1',
            ),
            playNow: true,
          )
          .timeout(const Duration(milliseconds: 100));

      expect(success, isTrue);
      expect(engine.playCount, 1);
      expect(engine.playCompleter?.isCompleted, isFalse);
      engine.playCompleter?.complete();
    });

    test('replaceSource skips restore seek for a different restored item', () async {
      final engine = _FakePlaybackEngine();
      final handler = AudioServiceHandler(engineAdapter: engine);
      await handler.updateQueue([_mediaItem('restored'), _mediaItem('next')]);
      await handler.setPendingRestorePosition(
        const Duration(seconds: 200),
        mediaItemId: 'restored',
      );

      final success = await handler.replaceSource(
        audioSourceIndex: 1,
        mediaItemToPlay: _mediaItem('next'),
        source: const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.url,
          url: 'url-next',
        ),
        playNow: true,
      );

      expect(success, isTrue);
      expect(engine.seekPositions, isEmpty);
    });

    test('replaceSource applies restore seek when restored item id only differs by whitespace', () async {
      final engine = _FakePlaybackEngine();
      final handler = AudioServiceHandler(engineAdapter: engine);
      await handler.updateQueue([_mediaItem(' restored ')]);
      await handler.setPendingRestorePosition(
        const Duration(seconds: 200),
        mediaItemId: 'restored',
      );

      final success = await handler.replaceSource(
        audioSourceIndex: 0,
        mediaItemToPlay: _mediaItem(' restored '),
        source: const PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.url,
          url: 'url-restored',
        ),
        playNow: true,
      );

      expect(success, isTrue);
      expect(engine.seekPositions, [const Duration(seconds: 200)]);
    });

    test('play without a prepared source is ignored', () async {
      final engine = _FakePlaybackEngine();
      final handler = AudioServiceHandler(engineAdapter: engine);

      await handler.play();

      expect(engine.playCount, 0);
      expect(engine.playing, isFalse);
    });
  });
}

MediaItem _mediaItem(String id) {
  return MediaItem(id: id, title: 'Track $id');
}

class _FakePlaybackEngine implements PlaybackEnginePort {
  _FakePlaybackEngine({
    this.failingSourceKinds = const <PlaybackResolvedSourceKind>{},
    this.holdPlayFuture = false,
    bool initialPlaying = false,
  }) : _playing = initialPlaying;

  final Set<PlaybackResolvedSourceKind> failingSourceKinds;

  final bool holdPlayFuture;

  final StreamController<PlaybackEvent> _events = StreamController<PlaybackEvent>.broadcast();

  final List<PlaybackResolvedSource> sources = <PlaybackResolvedSource>[];

  int playCount = 0;

  int pauseCount = 0;

  Completer<void>? playCompleter;

  final List<Duration> seekPositions = <Duration>[];

  bool _hasAudioSource = false;

  bool _playing;

  @override
  Duration get bufferedPosition => Duration.zero;

  @override
  bool get hasAudioSource => _hasAudioSource;

  @override
  Stream<PlaybackEvent> get playbackEventStream => _events.stream;

  @override
  bool get playing => _playing;

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
  Future<void> pause() async {
    pauseCount++;
    _playing = false;
  }

  @override
  Future<void> play() async {
    if (!_hasAudioSource) {
      return;
    }
    playCount++;
    _playing = true;
    if (holdPlayFuture) {
      playCompleter = Completer<void>();
      await playCompleter!.future;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    seekPositions.add(position);
  }

  @override
  Future<void> setSource(PlaybackResolvedSource source) async {
    sources.add(source);
    if (failingSourceKinds.contains(source.kind)) {
      throw StateError('source failed');
    }
    _hasAudioSource = true;
  }

  void emitPlaybackEvent() {
    _events.add(PlaybackEvent());
  }
}
