import 'dart:async';
import 'dart:io';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_source_prefetcher.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSourcePrefetcher', () {
    test('re-resolves sources after ttl expires', () async {
      final resolver = _CountingSourceResolver();
      final prefetcher = PlaybackSourcePrefetcher(
        resolver: resolver,
        ttl: const Duration(milliseconds: 100),
      );
      final item = _item('1');

      final first = await prefetcher.resolve(item, preferHighQuality: false);
      final cached = await prefetcher.resolve(item, preferHighQuality: false);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final refreshed = await prefetcher.resolve(item, preferHighQuality: false);

      expect(first.url, 'normal-url-1');
      expect(cached.url, 'normal-url-1');
      expect(refreshed.url, 'normal-url-2');
      expect(resolver.resolveCallCount, 2);
    });

    test('keeps normal and high quality cache entries separate', () async {
      final resolver = _CountingSourceResolver();
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item('1');

      final normal = await prefetcher.resolve(item, preferHighQuality: false);
      final high = await prefetcher.resolve(item, preferHighQuality: true);
      final cachedNormal = await prefetcher.resolve(item, preferHighQuality: false);
      final cachedHigh = await prefetcher.resolve(item, preferHighQuality: true);

      expect(normal.url, 'normal-url-1');
      expect(high.url, 'high-url-2');
      expect(cachedNormal.url, normal.url);
      expect(cachedHigh.url, high.url);
      expect(resolver.resolveCallCount, 2);
      expect(resolver.preferences, [false, true]);
    });

    test('limits cache and evicts least recently used sources', () async {
      final resolver = _CountingSourceResolver();
      final prefetcher = PlaybackSourcePrefetcher(
        resolver: resolver,
        maxEntries: 2,
      );
      final first = _item('1');
      final second = _item('2');
      final third = _item('3');

      expect((await prefetcher.resolve(first, preferHighQuality: false)).url, 'normal-url-1');
      expect((await prefetcher.resolve(second, preferHighQuality: false)).url, 'normal-url-2');
      expect((await prefetcher.resolve(first, preferHighQuality: false)).url, 'normal-url-1');
      expect((await prefetcher.resolve(third, preferHighQuality: false)).url, 'normal-url-3');
      expect((await prefetcher.resolve(second, preferHighQuality: false)).url, 'normal-url-4');

      expect(resolver.resolveCallCount, 4);
    });

    test('re-resolves cached local file source after file is removed', () async {
      final directory = await Directory.systemTemp.createTemp('source-prefetch-file-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song.mp3');
      await audioFile.writeAsString('audio');
      final resolver = _LocalFileThenRemoteSourceResolver(audioFile);
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item('1');

      final cachedFile = await prefetcher.resolve(item, preferHighQuality: false);
      await audioFile.delete();
      final refreshed = await prefetcher.resolve(item, preferHighQuality: false);

      expect(cachedFile.kind, PlaybackResolvedSourceKind.filePath);
      expect(cachedFile.url, audioFile.path);
      expect(refreshed.kind, PlaybackResolvedSourceKind.url);
      expect(refreshed.url, 'remote-url-2');
      expect(resolver.resolveCallCount, 2);
    });

    test('re-resolves cached remote source when item local file becomes available', () async {
      final directory = await Directory.systemTemp.createTemp('source-prefetch-file-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song.mp3');
      final resolver = _LocalFileThenRemoteSourceResolver(audioFile);
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item(
        '1',
        mediaType: MediaType.neteaseCache,
        playbackUrl: audioFile.path,
      );

      final cachedRemote = await prefetcher.resolve(item, preferHighQuality: false);
      await audioFile.writeAsString('audio');
      final refreshed = await prefetcher.resolve(item, preferHighQuality: false);

      expect(cachedRemote.kind, PlaybackResolvedSourceKind.url);
      expect(cachedRemote.url, 'remote-url-1');
      expect(refreshed.kind, PlaybackResolvedSourceKind.filePath);
      expect(refreshed.url, audioFile.path);
      expect(resolver.resolveCallCount, 2);
    });

    test('re-resolves cached remote source when item local file uri becomes available', () async {
      final directory = await Directory.systemTemp.createTemp('source-prefetch-file-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song with space.mp3');
      final resolver = _LocalFileThenRemoteSourceResolver(audioFile);
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item(
        '1',
        mediaType: MediaType.local,
        playbackUrl: audioFile.uri.replace(queryParameters: {'token': 'local'}).toString(),
      );

      final cachedRemote = await prefetcher.resolve(item, preferHighQuality: false);
      await audioFile.writeAsString('audio');
      final refreshed = await prefetcher.resolve(item, preferHighQuality: false);

      expect(cachedRemote.kind, PlaybackResolvedSourceKind.url);
      expect(cachedRemote.url, 'remote-url-1');
      expect(refreshed.kind, PlaybackResolvedSourceKind.filePath);
      expect(refreshed.url, audioFile.path);
      expect(resolver.resolveCallCount, 2);
    });

    test('bypasses in-flight remote prefetch when item local file becomes available', () async {
      final directory = await Directory.systemTemp.createTemp('source-prefetch-file-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song.mp3');
      final resolver = _ControllableLocalFileThenRemoteSourceResolver(audioFile);
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item(
        '1',
        mediaType: MediaType.local,
        playbackUrl: audioFile.path,
      );

      final staleRemote = prefetcher.resolve(item, preferHighQuality: false);
      await _waitUntil(() => resolver.pendingRemoteCount == 1);
      await audioFile.writeAsString('audio');
      final local = await prefetcher.resolve(item, preferHighQuality: false);
      resolver.complete(0, 'remote-url-1');
      final cachedLocal = await prefetcher.resolve(item, preferHighQuality: false);

      expect(local.kind, PlaybackResolvedSourceKind.filePath);
      expect(local.url, audioFile.path);
      expect(await staleRemote, _hasUrl('remote-url-1'));
      expect(cachedLocal.kind, PlaybackResolvedSourceKind.filePath);
      expect(cachedLocal.url, audioFile.path);
      expect(resolver.resolveCallCount, 2);
    });

    test('keeps cached remote source for non-localhost file uri authority', () async {
      final directory = await Directory.systemTemp.createTemp('source-prefetch-file-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song.mp3');
      final resolver = _LocalFileThenRemoteSourceResolver(audioFile);
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item(
        '1',
        mediaType: MediaType.local,
        playbackUrl: Uri(
          scheme: 'file',
          host: 'media-server',
          path: audioFile.path,
        ).toString(),
      );

      final cachedRemote = await prefetcher.resolve(item, preferHighQuality: false);
      await audioFile.writeAsString('audio');
      final reusedRemote = await prefetcher.resolve(item, preferHighQuality: false);

      expect(cachedRemote.kind, PlaybackResolvedSourceKind.url);
      expect(cachedRemote.url, 'remote-url-1');
      expect(reusedRemote.kind, PlaybackResolvedSourceKind.url);
      expect(reusedRemote.url, 'remote-url-1');
      expect(resolver.resolveCallCount, 1);
    });

    test('keeps cache entries separate when media type changes for the same path', () async {
      final directory = await Directory.systemTemp.createTemp('source-prefetch-file-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song.mp3.uc!');
      await audioFile.writeAsString('encrypted audio');
      final resolver = _MediaTypeAwareSourceResolver();
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);

      final localSource = await prefetcher.resolve(
        _item(
          '1',
          mediaType: MediaType.local,
          playbackUrl: audioFile.path,
        ),
        preferHighQuality: false,
      );
      final cacheSource = await prefetcher.resolve(
        _item(
          '1',
          mediaType: MediaType.neteaseCache,
          playbackUrl: audioFile.path,
        ),
        preferHighQuality: false,
      );

      expect(localSource.kind, PlaybackResolvedSourceKind.filePath);
      expect(cacheSource.kind, PlaybackResolvedSourceKind.neteaseCacheStream);
      expect(cacheSource.fileType, 'mp3');
      expect(resolver.resolveCallCount, 2);
    });

    test('force refresh keeps newer in-flight remote source active', () async {
      final resolver = _ControllableRemoteSourceResolver();
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item('1');

      final stale = prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
      );
      final refreshed = prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
        forceRefresh: true,
      );

      resolver.complete(0, 'stale-url');
      expect(await stale, _hasUrl('stale-url'));

      final coalesced = prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
      );

      expect(resolver.remoteCallCount, 2);
      resolver.complete(1, 'fresh-url');
      expect(await refreshed, _hasUrl('fresh-url'));
      expect(await coalesced, _hasUrl('fresh-url'));
    });

    test('late stale remote result does not overwrite refreshed cache', () async {
      final resolver = _ControllableRemoteSourceResolver();
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item('1');

      final stale = prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
      );
      final refreshed = prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
        forceRefresh: true,
      );

      resolver.complete(1, 'fresh-url');
      expect(await refreshed, _hasUrl('fresh-url'));

      resolver.complete(0, 'stale-url');
      expect(await stale, _hasUrl('stale-url'));

      final cached = await prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
      );

      expect(cached, _hasUrl('fresh-url'));
      expect(resolver.remoteCallCount, 2);
    });

    test('force refresh clears stale remote cache before coalescing followers', () async {
      final resolver = _ControllableRemoteSourceResolver();
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item('1');

      final initial = prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
      );
      resolver.complete(0, 'stale-url');
      expect(await initial, _hasUrl('stale-url'));

      final refreshed = prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
        forceRefresh: true,
      );
      final follower = prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
      );

      expect(resolver.remoteCallCount, 2);
      resolver.complete(1, 'fresh-url');
      expect(await refreshed, _hasUrl('fresh-url'));
      expect(await follower, _hasUrl('fresh-url'));
    });

    test('does not keep failed remote prefetch in flight and retries next resolve', () async {
      final resolver = _FailingThenRecoveredRemoteSourceResolver();
      final prefetcher = PlaybackSourcePrefetcher(resolver: resolver);
      final item = _item('1');

      await expectLater(
        prefetcher.resolveRemote(item, preferHighQuality: false),
        throwsA(isA<StateError>()),
      );
      final recovered = await prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
      );
      final cached = await prefetcher.resolveRemote(
        item,
        preferHighQuality: false,
      );

      expect(recovered, _hasUrl('recovered-url-2'));
      expect(cached, _hasUrl('recovered-url-2'));
      expect(resolver.remoteCallCount, 2);
    });
  });
}

PlaybackQueueItem _item(
  String id, {
  MediaType mediaType = MediaType.playlist,
  String? playbackUrl,
}) {
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
    mediaType: mediaType,
    playbackUrl: playbackUrl,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
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

class _CountingSourceResolver implements PlaybackSourceResolver {
  int resolveCallCount = 0;
  final List<bool> preferences = [];

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    resolveCallCount++;
    preferences.add(preferHighQuality);
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: '${preferHighQuality ? 'high' : 'normal'}-url-$resolveCallCount',
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

class _LocalFileThenRemoteSourceResolver implements PlaybackSourceResolver {
  _LocalFileThenRemoteSourceResolver(this.audioFile);

  final File audioFile;
  int resolveCallCount = 0;

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    resolveCallCount++;
    if (audioFile.existsSync()) {
      return PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.filePath,
        url: audioFile.path,
      );
    }
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'remote-url-$resolveCallCount',
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

class _ControllableRemoteSourceResolver implements PlaybackSourceResolver {
  final List<Completer<PlaybackResolvedSource>> _remoteCompleters = [];

  int get remoteCallCount => _remoteCompleters.length;

  void complete(int index, String url) {
    _remoteCompleters[index].complete(
      PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.url,
        url: url,
      ),
    );
  }

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    return resolveRemote(item, preferHighQuality: preferHighQuality);
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) {
    final completer = Completer<PlaybackResolvedSource>();
    _remoteCompleters.add(completer);
    return completer.future;
  }
}

class _FailingThenRecoveredRemoteSourceResolver implements PlaybackSourceResolver {
  int remoteCallCount = 0;

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    return resolveRemote(item, preferHighQuality: preferHighQuality);
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    remoteCallCount++;
    if (remoteCallCount == 1) {
      throw StateError('remote prefetch failed');
    }
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'recovered-url-$remoteCallCount',
    );
  }
}

class _ControllableLocalFileThenRemoteSourceResolver implements PlaybackSourceResolver {
  _ControllableLocalFileThenRemoteSourceResolver(this.audioFile);

  final File audioFile;
  final List<Completer<PlaybackResolvedSource>> _remoteCompleters = [];
  int resolveCallCount = 0;

  int get pendingRemoteCount => _remoteCompleters.length;

  void complete(int index, String url) {
    _remoteCompleters[index].complete(
      PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.url,
        url: url,
      ),
    );
  }

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    resolveCallCount++;
    if (audioFile.existsSync()) {
      return Future.value(
        PlaybackResolvedSource(
          kind: PlaybackResolvedSourceKind.filePath,
          url: audioFile.path,
        ),
      );
    }
    final completer = Completer<PlaybackResolvedSource>();
    _remoteCompleters.add(completer);
    return completer.future;
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

class _MediaTypeAwareSourceResolver implements PlaybackSourceResolver {
  int resolveCallCount = 0;

  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    resolveCallCount++;
    if (item.mediaType == MediaType.neteaseCache) {
      return PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.neteaseCacheStream,
        url: item.playbackUrl ?? '',
        fileType: 'mp3',
      );
    }
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.filePath,
      url: item.playbackUrl ?? '',
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

Matcher _hasUrl(String url) {
  return isA<PlaybackResolvedSource>().having(
    (source) => source.url,
    'url',
    url,
  );
}
