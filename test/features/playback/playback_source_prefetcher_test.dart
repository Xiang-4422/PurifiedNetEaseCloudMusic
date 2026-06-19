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
  });
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
  }) {
    return resolve(item, preferHighQuality: preferHighQuality);
  }
}
