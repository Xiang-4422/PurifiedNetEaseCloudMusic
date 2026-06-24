import 'dart:async';

import 'package:bujuan/data/music_data/sources/local/resources/playback_url_cache_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackUrlCacheCoordinator', () {
    test('coalesces concurrent remote loads and reuses fresh cache', () async {
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      Future<String?> load() async {
        loadCount++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return 'https://audio.test/1.mp3';
      }

      final urls = await Future.wait([
        coordinator.resolve('1', qualityLevel: 'lossless', forceRefresh: false, load: load),
        coordinator.resolve('1', qualityLevel: 'lossless', forceRefresh: false, load: load),
        coordinator.resolve('1', qualityLevel: 'lossless', forceRefresh: false, load: load),
      ]);
      final cached = await coordinator.resolve('1', qualityLevel: 'lossless', forceRefresh: false, load: load);

      expect(urls, [
        'https://audio.test/1.mp3',
        'https://audio.test/1.mp3',
        'https://audio.test/1.mp3',
      ]);
      expect(cached, 'https://audio.test/1.mp3');
      expect(loadCount, 1);
    });

    test('ignores blank track ids before local or remote lookup', () async {
      var localLookupCount = 0;
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async {
          localLookupCount++;
          return '/music/downloaded.mp3';
        },
      );

      final url = await coordinator.resolve(
        '   ',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          loadCount++;
          return 'https://audio.test/blank.mp3';
        },
      );

      expect(url, isNull);
      expect(localLookupCount, 0);
      expect(loadCount, 0);
    });

    test('normalizes track ids before local lookup and cache key lookup', () async {
      final localLookupTrackIds = <String>[];
      final localCoordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (trackId) async {
          localLookupTrackIds.add(trackId);
          return '/music/$trackId.mp3';
        },
      );

      final localUrl = await localCoordinator.resolve(
        ' 1 ',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async => 'https://audio.test/raw-id.mp3',
      );

      var loadCount = 0;
      final remoteCoordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );
      final remoteFromSpacedId = await remoteCoordinator.resolve(
        ' 1 ',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          loadCount++;
          return 'https://audio.test/1-$loadCount.mp3';
        },
      );
      final remoteFromNormalizedId = await remoteCoordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          loadCount++;
          return 'https://audio.test/1-$loadCount.mp3';
        },
      );

      expect(localUrl, '/music/1.mp3');
      expect(localLookupTrackIds, ['1']);
      expect(remoteFromSpacedId, 'https://audio.test/1-1.mp3');
      expect(remoteFromNormalizedId, remoteFromSpacedId);
      expect(loadCount, 1);
    });

    test('treats blank quality level as default cache key', () async {
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      Future<String?> load() async {
        loadCount++;
        return 'https://audio.test/1-$loadCount.mp3';
      }

      final defaultQuality = await coordinator.resolve(
        '1',
        qualityLevel: null,
        forceRefresh: false,
        load: load,
      );
      final blankQuality = await coordinator.resolve(
        '1',
        qualityLevel: '   ',
        forceRefresh: false,
        load: load,
      );

      expect(defaultQuality, 'https://audio.test/1-1.mp3');
      expect(blankQuality, defaultQuality);
      expect(loadCount, 1);
    });

    test('expires remote cache by ttl', () async {
      var now = DateTime(2026);
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
        ttl: const Duration(minutes: 2),
        now: () => now,
      );

      Future<String?> load() async {
        loadCount++;
        return 'https://audio.test/1-$loadCount.mp3';
      }

      final initial = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);
      now = now.add(const Duration(minutes: 1));
      final cached = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);
      now = now.add(const Duration(minutes: 2));
      final expired = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);

      expect(initial, 'https://audio.test/1-1.mp3');
      expect(cached, initial);
      expect(expired, 'https://audio.test/1-2.mp3');
      expect(loadCount, 2);
    });

    test('expires remote cache by playback url query timestamp before ttl', () async {
      var now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
        ttl: const Duration(minutes: 5),
        now: () => now,
      );

      Future<String?> load() async {
        loadCount++;
        final expiresAt = now.add(const Duration(seconds: 30)).millisecondsSinceEpoch ~/ 1000;
        return 'https://audio.test/1-$loadCount.mp3?authTime=$expiresAt';
      }

      final initial = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);
      now = now.add(const Duration(seconds: 20));
      final cached = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);
      now = now.add(const Duration(seconds: 11));
      final refreshed = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);

      expect(initial, startsWith('https://audio.test/1-1.mp3?authTime='));
      expect(cached, initial);
      expect(refreshed, startsWith('https://audio.test/1-2.mp3?authTime='));
      expect(loadCount, 2);
    });

    test('normalizes remote url before returning and caching it', () async {
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      Future<String?> load() async {
        loadCount++;
        return '  HTTPS://audio.test/1.mp3?token=abc  ';
      }

      final initial = await coordinator.resolve('1', qualityLevel: 'lossless', forceRefresh: false, load: load);
      final cached = await coordinator.resolve('1', qualityLevel: 'lossless', forceRefresh: false, load: load);

      expect(initial, 'HTTPS://audio.test/1.mp3?token=abc');
      expect(cached, initial);
      expect(loadCount, 1);
    });

    test('does not return or cache empty playback url results', () async {
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      Future<String?> load() async {
        loadCount++;
        return loadCount == 1 ? '' : 'https://audio.test/1.mp3';
      }

      final empty = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);
      final remote = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);
      final cached = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);

      expect(empty, isNull);
      expect(remote, 'https://audio.test/1.mp3');
      expect(cached, remote);
      expect(loadCount, 2);
    });

    test('does not cache malformed remote playback url results', () async {
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      Future<String?> load() async {
        loadCount++;
        return loadCount == 1 ? '  HTTPS:///missing-host.mp3  ' : 'https://audio.test/1.mp3';
      }

      final malformed = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);
      final remote = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);
      final cached = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);

      expect(malformed, 'HTTPS:///missing-host.mp3');
      expect(remote, 'https://audio.test/1.mp3');
      expect(cached, remote);
      expect(loadCount, 2);
    });

    test('does not cache failed remote loads and retries next resolve', () async {
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      Future<String?> load() async {
        loadCount++;
        if (loadCount == 1) {
          throw StateError('remote expired');
        }
        return 'https://audio.test/1-recovered.mp3';
      }

      await expectLater(
        coordinator.resolve(
          '1',
          qualityLevel: 'standard',
          forceRefresh: false,
          load: load,
        ),
        throwsA(isA<StateError>()),
      );
      final recovered = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: load,
      );
      final cached = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: load,
      );

      expect(recovered, 'https://audio.test/1-recovered.mp3');
      expect(cached, recovered);
      expect(loadCount, 2);
    });

    test('prefers local resource over cached and in-flight remote url', () async {
      String? localUrl;
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => localUrl,
      );

      Future<String?> load() async {
        loadCount++;
        return 'https://audio.test/1.mp3';
      }

      final remote = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);
      localUrl = '/music/downloaded.mp3';
      final cachedLocal = await coordinator.resolve('1', qualityLevel: 'standard', forceRefresh: false, load: load);

      localUrl = null;
      final completer = Completer<String?>();
      final inFlight = coordinator.resolve(
        '2',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () {
          loadCount++;
          return completer.future;
        },
      );
      await _waitUntil(() => loadCount == 2);
      localUrl = '/music/downloading.mp3';
      final inFlightLocal = await coordinator.resolve(
        '2',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async => 'https://audio.test/2-reloaded.mp3',
      );
      completer.complete('https://audio.test/2.mp3');

      expect(remote, 'https://audio.test/1.mp3');
      expect(cachedLocal, '/music/downloaded.mp3');
      expect(inFlightLocal, '/music/downloading.mp3');
      expect(await inFlight, 'https://audio.test/2.mp3');
      expect(loadCount, 2);
    });

    test('drops stale remote state when local resource becomes available', () async {
      String? localUrl;
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => localUrl,
      );

      Future<String?> load() async {
        loadCount++;
        return 'https://audio.test/1-$loadCount.mp3';
      }

      final remote = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: load,
      );
      localUrl = '/music/downloaded.mp3';
      final local = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: load,
      );
      localUrl = null;
      final refreshedRemote = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: load,
      );

      expect(remote, 'https://audio.test/1-1.mp3');
      expect(local, '/music/downloaded.mp3');
      expect(refreshedRemote, 'https://audio.test/1-2.mp3');
      expect(loadCount, 2);
    });

    test('drops in-flight remote state when local resource becomes available', () async {
      String? localUrl;
      var loadCount = 0;
      final completer = Completer<String?>();
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => localUrl,
      );

      final staleRemote = coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () {
          loadCount++;
          return completer.future;
        },
      );
      await _waitUntil(() => loadCount == 1);
      localUrl = '/music/downloading.mp3';
      final local = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          loadCount++;
          return 'https://audio.test/1-unexpected.mp3';
        },
      );
      completer.complete('https://audio.test/1-stale.mp3');
      expect(await staleRemote, 'https://audio.test/1-stale.mp3');

      localUrl = null;
      final refreshedRemote = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          loadCount++;
          return 'https://audio.test/1-fresh.mp3';
        },
      );

      expect(local, '/music/downloading.mp3');
      expect(refreshedRemote, 'https://audio.test/1-fresh.mp3');
      expect(loadCount, 2);
    });

    test('prefers local resource even when remote url is force refreshed', () async {
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => '/music/downloaded.mp3',
      );

      final url = await coordinator.resolve(
        '1',
        qualityLevel: 'lossless',
        forceRefresh: true,
        load: () async {
          loadCount++;
          return 'https://audio.test/1-refreshed.mp3';
        },
      );

      expect(url, '/music/downloaded.mp3');
      expect(loadCount, 0);
    });

    test('ignores empty local resource result and resolves remote url', () async {
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => '',
      );

      final url = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          loadCount++;
          return 'https://audio.test/1.mp3';
        },
      );

      expect(url, 'https://audio.test/1.mp3');
      expect(loadCount, 1);
    });

    test('keeps cached remote url when local resource lookup fails', () async {
      var shouldFailLocalLookup = false;
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async {
          if (shouldFailLocalLookup) {
            throw StateError('local index failed');
          }
          return null;
        },
      );

      Future<String?> load() async {
        loadCount++;
        return 'https://audio.test/1.mp3';
      }

      final remote = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: load,
      );
      shouldFailLocalLookup = true;
      final cached = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: load,
      );

      expect(remote, 'https://audio.test/1.mp3');
      expect(cached, remote);
      expect(loadCount, 1);
    });

    test('keeps in-flight remote url when local resource lookup fails', () async {
      final completer = Completer<String?>();
      var loadCount = 0;
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async {
          throw StateError('local index failed');
        },
      );

      final inFlight = coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () {
          loadCount++;
          return completer.future;
        },
      );
      await _waitUntil(() => loadCount == 1);
      final joined = coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          loadCount++;
          return 'https://audio.test/1-reloaded.mp3';
        },
      );
      completer.complete('https://audio.test/1.mp3');

      expect(await inFlight, 'https://audio.test/1.mp3');
      expect(await joined, 'https://audio.test/1.mp3');
      expect(loadCount, 1);
    });

    test('evicts least recently used remote url cache entries', () async {
      final loadCounts = <String, int>{};
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
        maxEntries: 2,
      );

      Future<String?> load(String trackId) async {
        final count = (loadCounts[trackId] ?? 0) + 1;
        loadCounts[trackId] = count;
        return 'https://audio.test/$trackId-$count.mp3';
      }

      final first = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () => load('1'),
      );
      final second = await coordinator.resolve(
        '2',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () => load('2'),
      );
      final touchedFirst = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () => load('1'),
      );
      final third = await coordinator.resolve(
        '3',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () => load('3'),
      );
      final cachedFirst = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () => load('1'),
      );
      final reloadedSecond = await coordinator.resolve(
        '2',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () => load('2'),
      );

      expect(first, 'https://audio.test/1-1.mp3');
      expect(second, 'https://audio.test/2-1.mp3');
      expect(touchedFirst, first);
      expect(third, 'https://audio.test/3-1.mp3');
      expect(cachedFirst, first);
      expect(reloadedSecond, 'https://audio.test/2-2.mp3');
      expect(loadCounts, {'1': 1, '2': 2, '3': 1});
    });

    test('late stale load does not overwrite force refreshed cache', () async {
      final completers = <Completer<String?>>[];
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      Future<String?> load() {
        final completer = Completer<String?>();
        completers.add(completer);
        return completer.future;
      }

      final staleLoad = coordinator.resolve('1', qualityLevel: 'lossless', forceRefresh: false, load: load);
      await _waitUntil(() => completers.length == 1);
      final refreshLoad = coordinator.resolve('1', qualityLevel: 'lossless', forceRefresh: true, load: load);
      await _waitUntil(() => completers.length == 2);

      completers[1].complete('https://audio.test/1-fresh.mp3');
      expect(await refreshLoad, 'https://audio.test/1-fresh.mp3');
      completers[0].complete('https://audio.test/1-stale.mp3');
      expect(await staleLoad, 'https://audio.test/1-stale.mp3');

      final cached = await coordinator.resolve(
        '1',
        qualityLevel: 'lossless',
        forceRefresh: false,
        load: () async => 'https://audio.test/1-reloaded.mp3',
      );

      expect(cached, 'https://audio.test/1-fresh.mp3');
    });

    test('force refresh evicts stale cache before refresh load completes', () async {
      var loadCount = 0;
      final refreshCompleter = Completer<String?>();
      final coordinator = PlaybackUrlCacheCoordinator(
        resolveLocalResourceUrl: (_) async => null,
      );

      final cached = await coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          loadCount++;
          return 'https://audio.test/1-stale.mp3';
        },
      );
      final refresh = coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: true,
        load: () {
          loadCount++;
          return refreshCompleter.future;
        },
      );
      await _waitUntil(() => loadCount == 2);
      final joinedRefresh = coordinator.resolve(
        '1',
        qualityLevel: 'standard',
        forceRefresh: false,
        load: () async {
          loadCount++;
          return 'https://audio.test/1-still-stale.mp3';
        },
      );

      refreshCompleter.complete('https://audio.test/1-fresh.mp3');

      expect(cached, 'https://audio.test/1-stale.mp3');
      expect(await refresh, 'https://audio.test/1-fresh.mp3');
      expect(await joinedRefresh, 'https://audio.test/1-fresh.mp3');
      expect(loadCount, 2);
    });
  });
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
