import 'dart:async';

import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_source_prefetcher.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/application/playback_switch_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSwitchCoordinator', () {
    test('does not touch engine while source is still resolving', () async {
      final playbackService = _FakePlaybackService();
      final resolver = _ControllableSourceResolver();
      final queueService = _queueService(playbackService);
      final coordinator = PlaybackSwitchCoordinator(
        playbackService: playbackService,
        queueService: queueService,
        sourceResolver: resolver,
      );
      final queue = [_item('1'), _item('2')];
      await queueService.replaceQueue(queue, 1, playlistName: 'Queue');

      final switching = coordinator.switchToSelection(
        queue: queue,
        item: queue[1],
        activeIndex: 1,
        selectionVersion: queueService.state.selectionVersion,
        trigger: PlaybackSwitchTrigger.userNext,
        playNow: true,
      );
      await Future<void>.delayed(Duration.zero);

      expect(coordinator.state.phase, PlaybackSwitchPhase.resolving);
      expect(playbackService.replaceCalls, isEmpty);

      resolver.completeResolve(_urlSource('2'));
      await switching;

      expect(playbackService.replaceCalls.single.activeIndex, 1);
      expect(queueService.state.confirmedItem.id, '2');
    });

    test('pause during resolving clears autoplay intent before source replace',
        () async {
      final playbackService = _FakePlaybackService();
      final resolver = _ControllableSourceResolver();
      final queueService = _queueService(playbackService);
      final coordinator = PlaybackSwitchCoordinator(
        playbackService: playbackService,
        queueService: queueService,
        sourceResolver: resolver,
      );
      final queue = [_item('1')];
      await queueService.replaceQueue(queue, 0, playlistName: 'Queue');

      final switching = coordinator.switchToSelection(
        queue: queue,
        item: queue.first,
        activeIndex: 0,
        selectionVersion: queueService.state.selectionVersion,
        trigger: PlaybackSwitchTrigger.userSelect,
        playNow: true,
      );
      await Future<void>.delayed(Duration.zero);

      coordinator.cancelAutoplayIntent();
      resolver.completeResolve(_urlSource('1'));
      await switching;

      expect(playbackService.replaceCalls.single.playNow, isFalse);
    });

    test('falls back to remote source when local cached source fails',
        () async {
      final playbackService = _FakePlaybackService(failFirstReplace: true);
      final resolver = _ControllableSourceResolver();
      final queueService = _queueService(playbackService);
      final coordinator = PlaybackSwitchCoordinator(
        playbackService: playbackService,
        queueService: queueService,
        sourceResolver: resolver,
      );
      final queue = [_item('1')];
      await queueService.replaceQueue(queue, 0, playlistName: 'Queue');

      final switching = coordinator.switchToSelection(
        queue: queue,
        item: queue.first,
        activeIndex: 0,
        selectionVersion: queueService.state.selectionVersion,
        trigger: PlaybackSwitchTrigger.userSelect,
        playNow: true,
      );
      await Future<void>.delayed(Duration.zero);

      resolver.completeResolve(const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.filePath,
        url: '/tmp/cache.mp3',
      ));
      await Future<void>.delayed(Duration.zero);
      resolver.completeRemote(_urlSource('1'));
      final result = await switching;

      expect(result.success, isTrue);
      expect(playbackService.replaceCalls, hasLength(2));
      expect(playbackService.replaceCalls.last.source.kind,
          PlaybackResolvedSourceKind.url);
    });

    test('captures resolver timeout without replacing current source',
        () async {
      final playbackService = _FakePlaybackService();
      final resolver = _ThrowingSourceResolver(TimeoutException('slow url'));
      final queueService = _queueService(playbackService);
      final coordinator = PlaybackSwitchCoordinator(
        playbackService: playbackService,
        queueService: queueService,
        sourceResolver: resolver,
      );
      final queue = [_item('1')];
      await queueService.replaceQueue(queue, 0, playlistName: 'Queue');

      final result = await coordinator.switchToSelection(
        queue: queue,
        item: queue.first,
        activeIndex: 0,
        selectionVersion: queueService.state.selectionVersion,
        trigger: PlaybackSwitchTrigger.userSelect,
        playNow: true,
      );

      expect(result.success, isFalse);
      expect(result.message, '播放地址获取超时，请重试');
      expect(playbackService.replaceCalls, isEmpty);
      expect(queueService.state.confirmedIndex, -1);
      expect(coordinator.state.phase, PlaybackSwitchPhase.failed);
    });

    test('retries normal quality when high quality source resolving fails',
        () async {
      final playbackService = _FakePlaybackService(preferHighQuality: true);
      final resolver = _QualityFallbackSourceResolver();
      final queueService = _queueService(playbackService);
      final coordinator = PlaybackSwitchCoordinator(
        playbackService: playbackService,
        queueService: queueService,
        sourceResolver: resolver,
      );
      final queue = [_item('1')];
      await queueService.replaceQueue(queue, 0, playlistName: 'Queue');

      final result = await coordinator.switchToSelection(
        queue: queue,
        item: queue.first,
        activeIndex: 0,
        selectionVersion: queueService.state.selectionVersion,
        trigger: PlaybackSwitchTrigger.userSelect,
        playNow: true,
      );

      expect(result.success, isTrue);
      expect(resolver.preferences, [true, false]);
      expect(playbackService.replaceCalls.single.source.url, 'normal-url');
    });

    test('prefetch swallows resolver failures', () async {
      final prefetcher = PlaybackSourcePrefetcher(
        resolver: _ThrowingSourceResolver(Exception('prefetch failed')),
      );

      prefetcher.prefetch(_item('1'), preferHighQuality: true);
      await Future<void>.delayed(Duration.zero);
    });
  });
}

PlaybackQueueService _queueService(_FakePlaybackService playbackService) {
  return PlaybackQueueService(
    queueStore: _FakePlaybackQueueStore(),
    playbackService: playbackService,
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

PlaybackResolvedSource _urlSource(String id) {
  return PlaybackResolvedSource(
    kind: PlaybackResolvedSourceKind.url,
    url: 'url-$id',
  );
}

class _ReplaceCall {
  _ReplaceCall({
    required this.activeIndex,
    required this.source,
    required this.playNow,
  });

  final int activeIndex;
  final PlaybackResolvedSource source;
  final bool playNow;
}

class _FakePlaybackService implements PlaybackService {
  _FakePlaybackService({
    this.failFirstReplace = false,
    this.preferHighQuality = false,
  });

  final bool failFirstReplace;
  final bool preferHighQuality;
  final List<_ReplaceCall> replaceCalls = <_ReplaceCall>[];

  @override
  bool isHighQualityEnabled() => preferHighQuality;

  @override
  Future<void> setNotificationQueue(
    List<PlaybackQueueItem> queue, {
    required int currentIndex,
    required String playlistName,
    required String playlistHeader,
  }) async {}

  @override
  Future<bool> replaceSourceForQueueItem({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackResolvedSource source,
    required bool playNow,
  }) async {
    replaceCalls.add(_ReplaceCall(
      activeIndex: activeIndex,
      source: source,
      playNow: playNow,
    ));
    return !(failFirstReplace && replaceCalls.length == 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ThrowingSourceResolver implements PlaybackSourceResolver {
  _ThrowingSourceResolver(this.error);

  final Object error;

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    return Future<PlaybackResolvedSource>.error(error);
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    return resolve(item, preferHighQuality: preferHighQuality);
  }
}

class _QualityFallbackSourceResolver implements PlaybackSourceResolver {
  final List<bool> preferences = <bool>[];

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    preferences.add(preferHighQuality);
    if (preferHighQuality) {
      throw TimeoutException('high quality timeout');
    }
    return const PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'normal-url',
    );
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    return resolve(item, preferHighQuality: preferHighQuality);
  }
}

class _ControllableSourceResolver implements PlaybackSourceResolver {
  Completer<PlaybackResolvedSource>? _resolveCompleter;
  Completer<PlaybackResolvedSource>? _remoteCompleter;

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    _resolveCompleter = Completer<PlaybackResolvedSource>();
    return _resolveCompleter!.future;
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    _remoteCompleter = Completer<PlaybackResolvedSource>();
    return _remoteCompleter!.future;
  }

  void completeResolve(PlaybackResolvedSource source) {
    _resolveCompleter!.complete(source);
  }

  void completeRemote(PlaybackResolvedSource source) {
    _remoteCompleter!.complete(source);
  }
}

class _FakePlaybackQueueStore implements PlaybackQueueStore {
  @override
  Future<void> saveQueueSnapshot({
    required List<PlaybackQueueItem> originalSongs,
    required String playlistName,
    required String playlistHeader,
  }) async {}

  @override
  Future<void> savePlaylistMeta({
    required String playlistName,
    required String playlistHeader,
  }) async {}

  @override
  Future<void> saveRepeatMode(PlaybackRepeatMode repeatMode) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
