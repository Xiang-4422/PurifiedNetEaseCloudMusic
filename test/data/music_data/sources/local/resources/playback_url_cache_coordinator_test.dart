import 'package:bujuan/data/music_data/sources/local/resources/playback_url_cache_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackUrlCacheCoordinator', () {
    test('treats blank local resource urls as local misses', () async {
      final resolvedTrackIds = <String>[];
      var remoteLoads = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (trackId) async {
          resolvedTrackIds.add(trackId);
          return '   ';
        },
      );

      final url = await coordinator.resolve(
        ' netease:1 ',
        qualityLevel: 'lossless',
        forceRefresh: false,
        load: () async {
          remoteLoads++;
          return 'https://audio.test/1.mp3';
        },
      );

      expect(url, 'https://audio.test/1.mp3');
      expect(resolvedTrackIds, ['netease:1']);
      expect(remoteLoads, 1);
    });

    test('does not cache invalid remote urls', () async {
      var remoteLoads = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      Future<String?> loadInvalidRemoteUrl() async {
        remoteLoads++;
        return 'https:///missing-host-$remoteLoads.mp3';
      }

      final first = await coordinator.resolve(
        'netease:1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: loadInvalidRemoteUrl,
      );
      final second = await coordinator.resolve(
        'netease:1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: loadInvalidRemoteUrl,
      );

      expect(first, 'https:///missing-host-1.mp3');
      expect(second, 'https:///missing-host-2.mp3');
      expect(remoteLoads, 2);
    });

    test('does not return or cache blank remote urls', () async {
      var remoteLoads = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      final first = await coordinator.resolve(
        'netease:1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          remoteLoads++;
          return '   ';
        },
      );
      final second = await coordinator.resolve(
        'netease:1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          remoteLoads++;
          return 'https://audio.test/1.mp3';
        },
      );

      expect(first, isNull);
      expect(second, 'https://audio.test/1.mp3');
      expect(remoteLoads, 2);
    });

    test('clears in-flight state after remote load failure', () async {
      var remoteLoads = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      await expectLater(
        coordinator.resolve(
          'netease:1',
          qualityLevel: 'standard',
          forceRefresh: false,
          load: () async {
            remoteLoads++;
            throw StateError('network failed');
          },
        ),
        throwsA(isA<StateError>()),
      );

      final recovered = await coordinator.resolve(
        'netease:1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          remoteLoads++;
          return 'https://audio.test/1.mp3';
        },
      );

      expect(recovered, 'https://audio.test/1.mp3');
      expect(remoteLoads, 2);
    });
  });
}
