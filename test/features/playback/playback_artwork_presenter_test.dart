import 'package:bujuan/features/playback/playback_artwork_presenter.dart';
import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackArtworkPresenter', () {
    test('prewarms current and nearest remote cached colors safely', () async {
      final cachePrefix = '/cache/${DateTime.now().microsecondsSinceEpoch}';
      final imageCacheRepository = _FakeLocalImageCacheRepository({
        'https://img.test/prev-2.jpg': '$cachePrefix/prev-2.jpg',
        'https://img.test/prev-1.jpg': '$cachePrefix/prev-1.jpg',
        'https://img.test/current.jpg': '$cachePrefix/current.jpg',
        'https://img.test/next-1.jpg': '$cachePrefix/next-1.jpg',
        'https://img.test/next-2.jpg': '$cachePrefix/next-2.jpg',
      });
      final resolvedColorPaths = <String>[];
      final cachedColorPaths = <String>[];
      final presenter = PlaybackArtworkPresenter(
        repository: _FakePlaybackRepository(),
        imageCacheRepository: imageCacheRepository,
        dominantColorResolver: (imagePath) async {
          resolvedColorPaths.add(imagePath);
          return Colors.black;
        },
        cachedColorReader: (imagePath) {
          cachedColorPaths.add(imagePath);
          return Colors.red;
        },
      );

      await presenter.prewarmQueueDominantColors(
        queue: [
          _item('prev-2', 'https://img.test/prev-2.jpg'),
          _item('prev-1', 'https://img.test/prev-1.jpg'),
          _item('current', 'https://img.test/current.jpg'),
          _item('next-1', 'https://img.test/next-1.jpg'),
          _item('next-2', 'https://img.test/next-2.jpg'),
        ],
        currentIndex: 2,
        radius: 2,
        remoteResolveRadius: 1,
      );

      expect(imageCacheRepository.resolvedSources, [
        'https://img.test/current.jpg',
        'https://img.test/next-1.jpg',
        'https://img.test/prev-1.jpg',
      ]);
      expect(resolvedColorPaths, isEmpty);
      expect(cachedColorPaths, [
        '$cachePrefix/current.jpg',
        '$cachePrefix/next-1.jpg',
        '$cachePrefix/prev-1.jpg',
      ]);
    });

    test('does not compute missing colors during queue prewarm', () async {
      final imageCacheRepository = _FakeLocalImageCacheRepository({
        'https://img.test/current.jpg': '/cache/current.jpg',
        'https://img.test/next.jpg': '/cache/next.jpg',
      });
      final resolvedColorPaths = <String>[];
      final presenter = PlaybackArtworkPresenter(
        repository: _FakePlaybackRepository(),
        imageCacheRepository: imageCacheRepository,
        dominantColorResolver: (imagePath) async {
          resolvedColorPaths.add(imagePath);
          return Colors.black;
        },
        cachedColorReader: (_) => null,
      );

      await presenter.prewarmQueueDominantColors(
        queue: [
          _item('current', 'https://img.test/current.jpg'),
          _item('next', 'https://img.test/next.jpg'),
        ],
        currentIndex: 0,
        radius: 1,
        remoteResolveRadius: 1,
      );

      expect(resolvedColorPaths, isEmpty);
    });

    test('keeps mixed-case remote artwork inside remote resolve radius', () async {
      final imageCacheRepository = _FakeLocalImageCacheRepository({
        'HTTPS://img.test/current.jpg': '/cache/current.jpg',
        'HTTPS://img.test/next-1.jpg': '/cache/next-1.jpg',
        'HTTPS://img.test/prev-1.jpg': '/cache/prev-1.jpg',
        'HTTPS://img.test/next-2.jpg': '/cache/next-2.jpg',
        'HTTPS://img.test/prev-2.jpg': '/cache/prev-2.jpg',
      });
      final presenter = PlaybackArtworkPresenter(
        repository: _FakePlaybackRepository(),
        imageCacheRepository: imageCacheRepository,
        cachedColorReader: (_) => Colors.red,
      );

      await presenter.prewarmQueueDominantColors(
        queue: [
          _item('prev-2', 'HTTPS://img.test/prev-2.jpg'),
          _item('prev-1', 'HTTPS://img.test/prev-1.jpg'),
          _item('current', 'HTTPS://img.test/current.jpg'),
          _item('next-1', 'HTTPS://img.test/next-1.jpg'),
          _item('next-2', 'HTTPS://img.test/next-2.jpg'),
        ],
        currentIndex: 2,
        radius: 2,
        remoteResolveRadius: 1,
      );

      expect(imageCacheRepository.resolvedSources, [
        'HTTPS://img.test/current.jpg',
        'HTTPS://img.test/next-1.jpg',
        'HTTPS://img.test/prev-1.jpg',
      ]);
    });

    test('normalizes local file uri artwork before reading cached color', () {
      final cachedColorPaths = <String>[];
      final presenter = PlaybackArtworkPresenter(
        repository: _FakePlaybackRepository(),
        imageCacheRepository: _FakeLocalImageCacheRepository(const {}),
        cachedColorReader: (imagePath) {
          cachedColorPaths.add(imagePath);
          return Colors.green;
        },
      );
      final fileUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/cache/art with space.jpg',
        queryParameters: {'token': 'local'},
      ).toString();

      final color = presenter.peekCachedDominantColor(
        _itemWithLocalArtwork('local', fileUri),
      );

      expect(color, Colors.green);
      expect(cachedColorPaths, ['/cache/art with space.jpg']);
    });

    test('prefers local artwork over remote while resolving dominant color', () async {
      final imageCacheRepository = _FakeLocalImageCacheRepository(const {});
      final resolvedColorPaths = <String>[];
      final presenter = PlaybackArtworkPresenter(
        repository: _FakePlaybackRepository(),
        imageCacheRepository: imageCacheRepository,
        dominantColorResolver: (imagePath) async {
          resolvedColorPaths.add(imagePath);
          return Colors.blue;
        },
        cachedColorReader: (_) => null,
      );
      final fileUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/cache/local-art.jpg',
        queryParameters: {'token': 'local'},
      ).toString();

      final color = await presenter.resolveDominantColor(
        _itemWithArtworkPaths(
          'mixed',
          artworkUrl: 'https://img.test/remote-art.jpg',
          localArtworkPath: fileUri,
        ),
      );

      expect(color, Colors.blue);
      expect(imageCacheRepository.resolvedSources, ['/cache/local-art.jpg']);
      expect(resolvedColorPaths, ['/cache/local-art.jpg']);
    });

    test('ignores unsafe file uri artwork while reading cached color', () {
      final cachedColorPaths = <String>[];
      final presenter = PlaybackArtworkPresenter(
        repository: _FakePlaybackRepository(),
        imageCacheRepository: _FakeLocalImageCacheRepository(const {}),
        cachedColorReader: (imagePath) {
          cachedColorPaths.add(imagePath);
          return Colors.green;
        },
      );
      final fileUri = Uri(
        scheme: 'file',
        host: 'media-server',
        path: '/cache/art.jpg',
      ).toString();

      final color = presenter.peekCachedDominantColor(
        _itemWithLocalArtwork('unsafe', fileUri),
      );

      expect(color, isNull);
      expect(cachedColorPaths, isEmpty);
    });
  });
}

class _FakeLocalImageCacheRepository extends LocalImageCacheRepository {
  _FakeLocalImageCacheRepository(this.paths);

  final Map<String, String> paths;
  final List<String> resolvedSources = [];

  @override
  Future<String> resolveImagePath(String imageUrl) async {
    resolvedSources.add(imageUrl);
    return paths[imageUrl] ?? imageUrl;
  }
}

class _FakePlaybackRepository implements PlaybackRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

PlaybackQueueItem _item(String id, String artworkUrl) {
  return _itemWithArtworkPaths(
    id,
    artworkUrl: artworkUrl,
  );
}

PlaybackQueueItem _itemWithLocalArtwork(String id, String localArtworkPath) {
  return _itemWithArtworkPaths(
    id,
    localArtworkPath: localArtworkPath,
  );
}

PlaybackQueueItem _itemWithArtworkPaths(
  String id, {
  String? artworkUrl,
  String? localArtworkPath,
}) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
    title: 'Track $id',
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: artworkUrl,
    localArtworkPath: localArtworkPath,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}
