import 'dart:async';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_source_prefetcher.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/application/playback_switch_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
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

    test('pause during resolving clears autoplay intent before source replace', () async {
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

    test('serializes source replacement and drops stale waiters', () async {
      final playbackService = _FakePlaybackService(holdReplace: true);
      final resolver = _ImmediateSourceResolver();
      final queueService = _queueService(playbackService);
      final coordinator = PlaybackSwitchCoordinator(
        playbackService: playbackService,
        queueService: queueService,
        sourceResolver: resolver,
      );
      final queue = [_item('1'), _item('2'), _item('3')];
      await queueService.replaceQueue(queue, 0, playlistName: 'Queue');

      final first = coordinator.switchToSelection(
        queue: queue,
        item: queue[0],
        activeIndex: 0,
        selectionVersion: 1,
        trigger: PlaybackSwitchTrigger.userSelect,
        playNow: true,
      );
      await _waitUntil(() => playbackService.replaceCalls.length == 1);

      final stale = coordinator.switchToSelection(
        queue: queue,
        item: queue[1],
        activeIndex: 1,
        selectionVersion: 2,
        trigger: PlaybackSwitchTrigger.userNext,
        playNow: true,
      );
      final latest = coordinator.switchToSelection(
        queue: queue,
        item: queue[2],
        activeIndex: 2,
        selectionVersion: 3,
        trigger: PlaybackSwitchTrigger.userNext,
        playNow: true,
      );
      await Future<void>.delayed(Duration.zero);

      expect(playbackService.replaceCalls.map((call) => call.activeIndex), [0]);

      playbackService.completeNextReplace();
      await _waitUntil(() => playbackService.replaceCalls.length == 2);
      expect(playbackService.replaceCalls.map((call) => call.activeIndex), [0, 2]);

      playbackService.completeNextReplace();
      final results = await Future.wait([first, stale, latest]);

      expect(results[0].success, isFalse);
      expect(results[0].isObsolete, isTrue);
      expect(results[1].success, isFalse);
      expect(results[1].isObsolete, isTrue);
      expect(results[2].success, isTrue);
      expect(queueService.state.confirmedIndex, 2);
    });

    test('falls back to remote source when local cached source fails', () async {
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
      expect(playbackService.replaceCalls.last.source.kind, PlaybackResolvedSourceKind.url);
    });

    test('does not resolve remote fallback when local import file fails', () async {
      final playbackService = _FakePlaybackService(failFirstReplace: true);
      final resolver = _LocalThenRemoteRefreshSourceResolver();
      final queueService = _queueService(playbackService);
      final coordinator = PlaybackSwitchCoordinator(
        playbackService: playbackService,
        queueService: queueService,
        sourceResolver: resolver,
      );
      final queue = [
        _item(
          '1',
          sourceType: SourceType.local,
          mediaType: MediaType.local,
        ),
      ];
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
      expect(playbackService.replaceCalls, hasLength(1));
      expect(playbackService.replaceCalls.single.source.kind, PlaybackResolvedSourceKind.filePath);
      expect(resolver.remoteForceRefreshValues, isEmpty);
    });

    test('falls back to remote url when downloaded local file is missing', () async {
      final playbackService = _FakePlaybackService();
      final repository = _RemoteUrlPlaybackRepository('remote-url-1');
      final queueService = _queueService(playbackService);
      final coordinator = PlaybackSwitchCoordinator(
        playbackService: playbackService,
        queueService: queueService,
        sourceResolver: PlaybackSourceResolver(repository: repository),
      );
      final queue = [
        _item(
          '1',
          sourceType: SourceType.netease,
          mediaType: MediaType.local,
          playbackUrl: '/missing/download.mp3',
        ),
      ];
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
      expect(playbackService.replaceCalls.single.source.kind, PlaybackResolvedSourceKind.url);
      expect(playbackService.replaceCalls.single.source.url, 'remote-url-1');
      expect(repository.trackIds, ['1']);
      expect(repository.forceRefreshValues, [false]);
    });

    test('refreshes remote url when remote source replacement fails', () async {
      final playbackService = _FakePlaybackService(failFirstReplace: true);
      final resolver = _RemoteRefreshSourceResolver();
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
      expect(playbackService.replaceCalls.map((call) => call.source.url), [
        'stale-url-1',
        'fresh-url-1',
      ]);
      expect(resolver.remoteForceRefreshValues, [true]);
    });

    test('source error retries current song with refreshed remote url first', () async {
      final playbackService = _FakePlaybackService();
      final resolver = _RemoteRefreshSourceResolver();
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
        trigger: PlaybackSwitchTrigger.sourceError,
        playNow: true,
      );

      expect(result.success, isTrue);
      expect(playbackService.replaceCalls.map((call) => call.source.url), [
        'fresh-url-1',
      ]);
      expect(resolver.resolveCalls, 0);
      expect(resolver.remoteForceRefreshValues, [true]);
    });

    test('source error does not resolve remote for local import', () async {
      final playbackService = _FakePlaybackService();
      final resolver = _RemoteRefreshSourceResolver();
      final queueService = _queueService(playbackService);
      final coordinator = PlaybackSwitchCoordinator(
        playbackService: playbackService,
        queueService: queueService,
        sourceResolver: resolver,
      );
      final queue = [
        _item(
          '1',
          sourceType: SourceType.local,
          mediaType: MediaType.local,
        ),
      ];
      await queueService.replaceQueue(queue, 0, playlistName: 'Queue');

      final result = await coordinator.switchToSelection(
        queue: queue,
        item: queue.first,
        activeIndex: 0,
        selectionVersion: queueService.state.selectionVersion,
        trigger: PlaybackSwitchTrigger.sourceError,
        playNow: true,
      );

      expect(result.success, isFalse);
      expect(result.message, '当前本地歌曲文件不可用');
      expect(playbackService.replaceCalls, isEmpty);
      expect(resolver.resolveCalls, 0);
      expect(resolver.remoteForceRefreshValues, isEmpty);
    });

    test('source error falls back to refreshed normal quality when high quality refresh fails', () async {
      final playbackService = _FakePlaybackService(preferHighQuality: true);
      final resolver = _SourceErrorQualityFallbackResolver();
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
        trigger: PlaybackSwitchTrigger.sourceError,
        playNow: true,
      );

      expect(result.success, isTrue);
      expect(playbackService.replaceCalls.single.source.url, 'normal-fresh-1');
      expect(resolver.remotePreferences, [true, false]);
      expect(resolver.remoteForceRefreshValues, [true, true]);
    });

    test('falls back to normal quality when refreshed high quality remote replacement fails', () async {
      final playbackService = _FakePlaybackService(
        failReplaceCount: 2,
        preferHighQuality: true,
      );
      final resolver = _RemoteQualityFallbackSourceResolver();
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
      expect(playbackService.replaceCalls.map((call) => call.source.url), [
        'high-stale-1',
        'high-fresh-1',
        'normal-fresh-1',
      ]);
      expect(resolver.remotePreferences, [true, false]);
      expect(resolver.remoteForceRefreshValues, [true, true]);
    });

    test('refreshes remote source after local cached source and first remote fallback both fail', () async {
      final playbackService = _FakePlaybackService(failReplaceCount: 2);
      final resolver = _LocalThenRemoteRefreshSourceResolver();
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
      expect(playbackService.replaceCalls.map((call) => call.source.url), [
        '/tmp/cache-1.mp3',
        'remote-stale-1',
        'remote-fresh-1',
      ]);
      expect(resolver.remoteForceRefreshValues, [false, true]);
    });

    test('captures resolver timeout without replacing current source', () async {
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

    test('retries normal quality when high quality source resolving fails', () async {
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

PlaybackQueueItem _item(
  String id, {
  SourceType sourceType = SourceType.netease,
  MediaType mediaType = MediaType.playlist,
  String? playbackUrl,
}) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
    sourceType: sourceType,
    title: 'Track $id',
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: mediaType,
    playbackUrl: playbackUrl,
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

class _RemoteUrlPlaybackRepository implements PlaybackRepository {
  _RemoteUrlPlaybackRepository(this.url);

  final String url;
  final List<String> trackIds = <String>[];
  final List<bool> forceRefreshValues = <bool>[];

  @override
  Future<String?> fetchPlaybackUrl(
    String trackId, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    trackIds.add(trackId);
    forceRefreshValues.add(forceRefresh);
    return url;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
    this.failReplaceCount = 0,
    this.preferHighQuality = false,
    this.holdReplace = false,
  });

  final bool failFirstReplace;
  final int failReplaceCount;
  final bool preferHighQuality;
  final bool holdReplace;
  final List<_ReplaceCall> replaceCalls = <_ReplaceCall>[];
  final List<Completer<bool>> _replaceCompleters = <Completer<bool>>[];

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
    if (holdReplace) {
      final completer = Completer<bool>();
      _replaceCompleters.add(completer);
      return completer.future;
    }
    return !(replaceCalls.length <= failReplaceCount || (failFirstReplace && replaceCalls.length == 1));
  }

  void completeNextReplace([bool success = true]) {
    _replaceCompleters.removeAt(0).complete(success);
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
    bool forceRefresh = false,
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
    bool forceRefresh = false,
  }) {
    return resolve(item, preferHighQuality: preferHighQuality);
  }
}

class _ImmediateSourceResolver implements PlaybackSourceResolver {
  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    return _urlSource(item.id);
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) {
    return resolve(item, preferHighQuality: preferHighQuality);
  }
}

class _RemoteRefreshSourceResolver implements PlaybackSourceResolver {
  int resolveCalls = 0;
  final List<bool> remoteForceRefreshValues = <bool>[];

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    resolveCalls++;
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'stale-url-${item.id}',
    );
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    remoteForceRefreshValues.add(forceRefresh);
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'fresh-url-${item.id}',
    );
  }
}

class _SourceErrorQualityFallbackResolver implements PlaybackSourceResolver {
  final List<bool> remotePreferences = <bool>[];
  final List<bool> remoteForceRefreshValues = <bool>[];

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'stale-${item.id}',
    );
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    remotePreferences.add(preferHighQuality);
    remoteForceRefreshValues.add(forceRefresh);
    if (preferHighQuality) {
      throw TimeoutException('expired high quality url');
    }
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'normal-fresh-${item.id}',
    );
  }
}

class _RemoteQualityFallbackSourceResolver implements PlaybackSourceResolver {
  final List<bool> remotePreferences = <bool>[];
  final List<bool> remoteForceRefreshValues = <bool>[];

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'high-stale-${item.id}',
    );
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    remotePreferences.add(preferHighQuality);
    remoteForceRefreshValues.add(forceRefresh);
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: '${preferHighQuality ? 'high' : 'normal'}-${forceRefresh ? 'fresh' : 'stale'}-${item.id}',
    );
  }
}

class _LocalThenRemoteRefreshSourceResolver implements PlaybackSourceResolver {
  final List<bool> remoteForceRefreshValues = <bool>[];

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.filePath,
      url: '/tmp/cache-${item.id}.mp3',
    );
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    remoteForceRefreshValues.add(forceRefresh);
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'remote-${forceRefresh ? 'fresh' : 'stale'}-${item.id}',
    );
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
    bool forceRefresh = false,
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
  Future<void> saveQueueState({
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

Future<void> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for condition');
    }
    await Future<void>.delayed(Duration.zero);
  }
}
