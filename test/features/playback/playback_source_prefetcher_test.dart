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

Matcher _hasUrl(String url) {
  return isA<PlaybackResolvedSource>().having(
    (source) => source.url,
    'url',
    url,
  );
}
