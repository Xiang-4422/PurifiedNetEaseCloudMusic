import 'dart:async';
import 'dart:io';

import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_library_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/local_music_source.dart';
import 'package:bujuan/data/music_data/sources/netease/netease_music_source.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_artwork_cache_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusicDataRepository', () {
    test('ignores blank track ids before local resources or remote lookup', () async {
      final localDataSource = _FakeLocalLibraryDataSource();
      final neteaseSource = _FakeNeteaseMusicSource();
      final resourceIndexRepository = _FakeLocalResourceIndexRepository();
      final repository = _buildRepository(
        localDataSource: localDataSource,
        neteaseSource: neteaseSource,
        resourceIndexRepository: resourceIndexRepository,
      );

      expect(await repository.getTrack('   '), isNull);
      expect(await repository.getTrackWithResources('   '), isNull);
      expect(await repository.getPlaybackUrl('   '), isNull);
      expect(
        await repository.getPlaybackUrlWithQuality(
          '   ',
          qualityLevel: 'standard',
        ),
        isNull,
      );
      expect(await repository.getArtworkSource('   '), '');
      expect(await repository.getLyrics('   '), isNull);
      expect(
        (await repository.getTrackResourceBundle('   ')).hasAnyResource,
        isFalse,
      );

      expect(localDataSource.requestedTrackIds, isEmpty);
      expect(localDataSource.requestedLyricsTrackIds, isEmpty);
      expect(resourceIndexRepository.requestedBundleTrackIds, isEmpty);
      expect(neteaseSource.trackCallCount, 0);
      expect(neteaseSource.playbackUrlCallCount, 0);
      expect(neteaseSource.lyricsCallCount, 0);
    });

    test('normalizes playback url track ids before resources and remote cache', () async {
      final directory = await Directory.systemTemp.createTemp(
        'music-data-playback-url-id-',
      );
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final localAudio = await _writeFile(directory, 'local.mp3');
      final localResourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.audio,
            path: localAudio.path,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final localRepository = _buildRepository(
        resourceIndexRepository: localResourceIndexRepository,
      );

      final localUrl = await localRepository.getPlaybackUrlWithQuality(
        ' 1 ',
        qualityLevel: 'lossless',
      );

      expect(localUrl, localAudio.path);
      expect(localResourceIndexRepository.requestedBundleTrackIds, ['1']);
      expect(localResourceIndexRepository.touchedResources, ['1|audio']);

      final neteaseSource = _FakeNeteaseMusicSource(
        includeCallCountInPlaybackUrl: true,
      );
      final remoteRepository = _buildRepository(neteaseSource: neteaseSource);

      final spacedRemote = await remoteRepository.getPlaybackUrlWithQuality(
        ' 1 ',
        qualityLevel: 'lossless',
      );
      final normalizedRemote = await remoteRepository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );

      expect(spacedRemote, 'https://audio.test/1-1.mp3');
      expect(normalizedRemote, spacedRemote);
      expect(neteaseSource.playbackUrlTrackIds, ['1']);
    });

    test('coalesces concurrent playback url loads and reuses fresh remote url', () async {
      final neteaseSource = _FakeNeteaseMusicSource(
        playbackUrlDelay: const Duration(milliseconds: 20),
      );
      final repository = _buildRepository(neteaseSource: neteaseSource);

      final urls = await Future.wait([
        repository.getPlaybackUrlWithQuality('1', qualityLevel: 'lossless'),
        repository.getPlaybackUrlWithQuality('1', qualityLevel: 'lossless'),
        repository.getPlaybackUrlWithQuality('1', qualityLevel: 'lossless'),
      ]);
      final cachedUrl = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );

      expect(
        urls,
        [
          'https://audio.test/1.mp3',
          'https://audio.test/1.mp3',
          'https://audio.test/1.mp3',
        ],
      );
      expect(cachedUrl, 'https://audio.test/1.mp3');
      expect(neteaseSource.playbackUrlCallCount, 1);
    });

    test('keeps playback url cache separated by quality level', () async {
      final neteaseSource = _FakeNeteaseMusicSource(
        includeQualityInPlaybackUrl: true,
      );
      final repository = _buildRepository(neteaseSource: neteaseSource);

      final lossless = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );
      final standard = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'standard',
      );
      final cachedLossless = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );
      final cachedStandard = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'standard',
      );

      expect(lossless, 'https://audio.test/1-lossless.mp3');
      expect(standard, 'https://audio.test/1-standard.mp3');
      expect(cachedLossless, lossless);
      expect(cachedStandard, standard);
      expect(neteaseSource.playbackUrlCallCount, 2);
    });

    test('force refresh bypasses fresh playback url cache', () async {
      final neteaseSource = _FakeNeteaseMusicSource(
        includeCallCountInPlaybackUrl: true,
      );
      final repository = _buildRepository(neteaseSource: neteaseSource);

      final cached = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );
      final refreshed = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
        forceRefresh: true,
      );
      final reusedRefresh = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );

      expect(cached, 'https://audio.test/1-1.mp3');
      expect(refreshed, 'https://audio.test/1-2.mp3');
      expect(reusedRefresh, refreshed);
      expect(neteaseSource.playbackUrlCallCount, 2);
    });

    test('limits playback url cache and evicts least recently used remote entries', () async {
      final neteaseSource = _FakeNeteaseMusicSource(
        includeCallCountInPlaybackUrl: true,
      );
      final repository = _buildRepository(neteaseSource: neteaseSource);

      for (var index = 0; index < 64; index++) {
        await repository.getPlaybackUrlWithQuality(
          '$index',
          qualityLevel: 'standard',
        );
      }
      final reusedOldest = await repository.getPlaybackUrlWithQuality(
        '0',
        qualityLevel: 'standard',
      );
      await repository.getPlaybackUrlWithQuality(
        '64',
        qualityLevel: 'standard',
      );
      final reloadedLeastRecent = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'standard',
      );

      expect(reusedOldest, 'https://audio.test/0-1.mp3');
      expect(reloadedLeastRecent, 'https://audio.test/1-66.mp3');
      expect(neteaseSource.playbackUrlCallCount, 66);
    });

    test('late stale playback url load does not overwrite force refreshed cache', () async {
      final neteaseSource = _ControllablePlaybackUrlNeteaseMusicSource();
      final repository = _buildRepository(neteaseSource: neteaseSource);

      final staleLoad = repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );
      await _waitUntil(() => neteaseSource.playbackUrlCallCount == 1);
      final refreshLoad = repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
        forceRefresh: true,
      );
      await _waitUntil(() => neteaseSource.playbackUrlCallCount == 2);

      neteaseSource.complete(1, 'https://audio.test/1-fresh.mp3');
      expect(await refreshLoad, 'https://audio.test/1-fresh.mp3');

      neteaseSource.complete(0, 'https://audio.test/1-stale.mp3');
      expect(await staleLoad, 'https://audio.test/1-stale.mp3');

      final cached = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );

      expect(cached, 'https://audio.test/1-fresh.mp3');
      expect(neteaseSource.playbackUrlCallCount, 2);
    });

    test('prefers newly available local audio over fresh remote playback url cache', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-local-priority-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final localAudio = await _writeFile(directory, 'downloaded.mp3');
      final neteaseSource = _FakeNeteaseMusicSource();
      final resourceIndexRepository = _FakeLocalResourceIndexRepository();
      final repository = _buildRepository(
        neteaseSource: neteaseSource,
        resourceIndexRepository: resourceIndexRepository,
      );

      final remote = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );
      resourceIndexRepository.saveResource(
        _resource(
          trackId: '1',
          kind: LocalResourceKind.audio,
          path: localAudio.path,
          origin: TrackResourceOrigin.managedDownload,
        ),
      );
      final local = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );

      expect(remote, 'https://audio.test/1.mp3');
      expect(local, localAudio.path);
      expect(neteaseSource.playbackUrlCallCount, 1);
    });

    test('removes missing indexed audio before falling back to remote playback url', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-missing-audio-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final missingAudio = File('${directory.path}/missing.mp3');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.audio,
            path: missingAudio.path,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final neteaseSource = _FakeNeteaseMusicSource();
      final repository = _buildRepository(
        neteaseSource: neteaseSource,
        resourceIndexRepository: resourceIndexRepository,
      );

      final url = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );

      expect(url, 'https://audio.test/1.mp3');
      expect(resourceIndexRepository.remainingResourceKinds('1'), isEmpty);
      expect(neteaseSource.playbackUrlCallCount, 1);
    });

    test('normalizes indexed local audio file uri before returning playback url', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-audio-uri-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final localAudio = await _writeFile(directory, 'downloaded.mp3');
      final localAudioUri = localAudio.uri.replace(queryParameters: {'token': 'local'}).toString();
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.audio,
            path: localAudioUri,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final repository = _buildRepository(
        resourceIndexRepository: resourceIndexRepository,
      );

      final url = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );

      expect(url, localAudio.path);
      expect(resourceIndexRepository.touchedResources, ['1|audio']);
    });

    test('prefers existing indexed artwork source over remote artwork url', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-local-artwork-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final localArtwork = await _writeFile(directory, 'cover.jpg');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.artwork,
            path: localArtwork.path,
            origin: TrackResourceOrigin.artworkCache,
          ),
        ],
      );
      final repository = _buildRepository(
        localDataSource: _FakeLocalLibraryDataSource(
          tracks: {
            '1': _track('1', artworkUrl: 'https://img.test/cover.jpg'),
          },
        ),
        resourceIndexRepository: resourceIndexRepository,
      );

      final artwork = await repository.getArtworkSource('1');

      expect(artwork, localArtwork.path);
      expect(resourceIndexRepository.touchedResources, ['1|artwork']);
    });

    test('normalizes indexed local artwork file uri before returning artwork source', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-artwork-uri-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final localArtwork = await _writeFile(directory, 'cover.jpg');
      final localArtworkUri = localArtwork.uri.replace(queryParameters: {'token': 'local'}).toString();
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.artwork,
            path: localArtworkUri,
            origin: TrackResourceOrigin.artworkCache,
          ),
        ],
      );
      final repository = _buildRepository(
        localDataSource: _FakeLocalLibraryDataSource(
          tracks: {
            '1': _track('1', artworkUrl: 'https://img.test/cover.jpg'),
          },
        ),
        resourceIndexRepository: resourceIndexRepository,
      );

      final artwork = await repository.getArtworkSource('1');

      expect(artwork, localArtwork.path);
      expect(resourceIndexRepository.touchedResources, ['1|artwork']);
    });

    test('removes missing indexed artwork before falling back to remote artwork url', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-missing-artwork-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final missingArtwork = File('${directory.path}/missing.jpg');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.artwork,
            path: missingArtwork.path,
            origin: TrackResourceOrigin.artworkCache,
          ),
        ],
      );
      final repository = _buildRepository(
        localDataSource: _FakeLocalLibraryDataSource(
          tracks: {
            '1': _track('1', artworkUrl: 'https://img.test/cover.jpg'),
          },
        ),
        resourceIndexRepository: resourceIndexRepository,
      );

      final artwork = await repository.getArtworkSource('1');

      expect(artwork, 'https://img.test/cover.jpg');
      expect(resourceIndexRepository.remainingResourceKinds('1'), isEmpty);
      expect(resourceIndexRepository.touchedResources, isEmpty);
    });

    test('prefers newly available local audio over in-flight remote playback url load', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-local-priority-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final localAudio = await _writeFile(directory, 'downloaded.mp3');
      final neteaseSource = _FakeNeteaseMusicSource(
        playbackUrlDelay: const Duration(milliseconds: 50),
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository();
      final repository = _buildRepository(
        neteaseSource: neteaseSource,
        resourceIndexRepository: resourceIndexRepository,
      );

      final remoteLoad = repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );
      while (neteaseSource.playbackUrlCallCount == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      resourceIndexRepository.saveResource(
        _resource(
          trackId: '1',
          kind: LocalResourceKind.audio,
          path: localAudio.path,
          origin: TrackResourceOrigin.managedDownload,
        ),
      );
      final local = await repository.getPlaybackUrlWithQuality(
        '1',
        qualityLevel: 'lossless',
      );

      expect(local, localAudio.path);
      expect(await remoteLoad, 'https://audio.test/1.mp3');
      expect(neteaseSource.playbackUrlCallCount, 1);
    });

    test('does not use local track source id as playback fallback', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-local-source-uri-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final localAudio = await _writeFile(directory, 'Local Song.mp3');
      final trackId = 'local:${localAudio.path}';
      final sourceUri = localAudio.uri.replace(queryParameters: {'token': 'local'}).toString();
      final localDataSource = _FakeLocalLibraryDataSource(
        tracks: {
          trackId: Track(
            id: trackId,
            sourceType: SourceType.local,
            sourceId: sourceUri,
            title: 'Local Song',
          ),
        },
      );
      final neteaseSource = _FakeNeteaseMusicSource();
      final repository = _buildRepository(
        localDataSource: localDataSource,
        neteaseSource: neteaseSource,
      );

      final url = await repository.getPlaybackUrlWithQuality(
        trackId,
        qualityLevel: 'lossless',
      );

      expect(url, isNull);
      expect(neteaseSource.playbackUrlCallCount, 0);
    });

    test('coalesces concurrent lyric loads', () async {
      final localDataSource = _FakeLocalLibraryDataSource();
      final neteaseSource = _FakeNeteaseMusicSource(
        lyricsDelay: const Duration(milliseconds: 20),
      );
      final repository = _buildRepository(
        localDataSource: localDataSource,
        neteaseSource: neteaseSource,
      );

      final lyrics = await Future.wait([
        repository.getLyrics('1'),
        repository.getLyrics('1'),
        repository.getLyrics('1'),
      ]);

      expect(lyrics.map((item) => item?.main), ['lyric-1', 'lyric-1', 'lyric-1']);
      expect(neteaseSource.lyricsCallCount, 1);
      expect(localDataSource.savedLyrics.length, 1);
    });

    test('reads lyrics from legacy file uri resource index', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-lyrics-file-uri-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final lyricsFile = await _writeFile(
        directory,
        'lyrics with space.lrc',
        contents: '[00:01]local lyric',
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.lyrics,
            path: lyricsFile.uri.replace(queryParameters: {'token': 'local'}).toString(),
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final neteaseSource = _FakeNeteaseMusicSource();
      final repository = _buildRepository(
        neteaseSource: neteaseSource,
        resourceIndexRepository: resourceIndexRepository,
      );

      final lyrics = await repository.getLyrics('1');

      expect(lyrics?.main, '[00:01]local lyric');
      expect(neteaseSource.lyricsCallCount, 0);
      expect(resourceIndexRepository.touchedResources, ['1|lyrics']);
    });

    test('keeps first requested order when loading tracks with resources', () async {
      final localDataSource = _FakeLocalLibraryDataSource(
        tracks: {
          '1': const Track(
            id: '1',
            sourceType: SourceType.netease,
            sourceId: '1',
            title: 'Track 1',
          ),
          '2': const Track(
            id: '2',
            sourceType: SourceType.netease,
            sourceId: '2',
            title: 'Track 2',
          ),
          '3': const Track(
            id: '3',
            sourceType: SourceType.netease,
            sourceId: '3',
            title: 'Track 3',
          ),
        },
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository();
      final repository = _buildRepository(
        localDataSource: localDataSource,
        resourceIndexRepository: resourceIndexRepository,
      );

      final tracks = await repository.getTracksWithResources([
        '3',
        '   ',
        '1',
        '3',
        '',
        '2',
      ]);

      expect(tracks.map((item) => item.track.id), ['3', '1', '2']);
      expect(localDataSource.requestedBatchTrackIds, ['3', '1', '2']);
      expect(resourceIndexRepository.requestedBundleTrackIds, ['3', '1', '2']);
    });

    test('pre-caches artwork only when requested while saving tracks', () async {
      final artworkCacheRepository = _FakeLocalArtworkCacheRepository();
      final repository = _buildRepository(
        artworkCacheRepository: artworkCacheRepository,
      );
      final tracks = [_track('1')];

      await repository.saveTracks(tracks);
      await repository.saveTracks(tracks, precacheArtwork: false);

      expect(artworkCacheRepository.cacheCallCount, 1);
      expect(artworkCacheRepository.cachedTrackIds, ['1']);
    });

    test('clears playback cache resources without deleting other indexed resources', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-cache-cleanup-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final playbackAudio = await _writeFile(directory, 'playback.mp3');
      final playbackLyrics = await _writeFile(directory, 'playback.lrc');
      final managedArtwork = await _writeFile(directory, 'managed.jpg');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.audio,
            path: playbackAudio.path,
            origin: TrackResourceOrigin.playbackCache,
          ),
          _resource(
            trackId: '1',
            kind: LocalResourceKind.lyrics,
            path: playbackLyrics.path,
            origin: TrackResourceOrigin.playbackCache,
          ),
          _resource(
            trackId: '1',
            kind: LocalResourceKind.artwork,
            path: managedArtwork.path,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final repository = _buildRepository(
        resourceIndexRepository: resourceIndexRepository,
      );

      await repository.removePlaybackCache();

      expect(playbackAudio.existsSync(), isFalse);
      expect(playbackLyrics.existsSync(), isFalse);
      expect(managedArtwork.existsSync(), isTrue);
      expect(resourceIndexRepository.remainingResourceKinds('1'), {
        LocalResourceKind.artwork,
      });
    });

    test('keeps playback cache files referenced by retained resource indexes', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-cache-shared-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final sharedAudio = await _writeFile(directory, 'shared.mp3');
      final playbackOnly = await _writeFile(directory, 'playback-only.mp3');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.audio,
            path: sharedAudio.path,
            origin: TrackResourceOrigin.playbackCache,
          ),
          _resource(
            trackId: '2',
            kind: LocalResourceKind.audio,
            path: sharedAudio.path,
            origin: TrackResourceOrigin.managedDownload,
          ),
          _resource(
            trackId: '3',
            kind: LocalResourceKind.audio,
            path: playbackOnly.path,
            origin: TrackResourceOrigin.playbackCache,
          ),
        ],
      );
      final repository = _buildRepository(
        resourceIndexRepository: resourceIndexRepository,
      );

      await repository.removePlaybackCache();

      expect(sharedAudio.existsSync(), isTrue);
      expect(playbackOnly.existsSync(), isFalse);
      expect(resourceIndexRepository.remainingResourceKinds('1'), isEmpty);
      expect(resourceIndexRepository.remainingResourceKinds('2'), {
        LocalResourceKind.audio,
      });
      expect(resourceIndexRepository.remainingResourceKinds('3'), isEmpty);
    });

    test('keeps playback cache files referenced by retained legacy file uri indexes', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-cache-legacy-shared-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final sharedAudio = await _writeFile(directory, 'shared with uri.mp3');
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.audio,
            path: sharedAudio.path,
            origin: TrackResourceOrigin.playbackCache,
          ),
          _resource(
            trackId: '2',
            kind: LocalResourceKind.audio,
            path: sharedAudio.uri.replace(queryParameters: {'token': 'legacy'}).toString(),
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final repository = _buildRepository(
        resourceIndexRepository: resourceIndexRepository,
      );

      await repository.removePlaybackCache();

      expect(sharedAudio.existsSync(), isTrue);
      expect(resourceIndexRepository.remainingResourceKinds('1'), isEmpty);
      expect(resourceIndexRepository.remainingResourceKinds('2'), {
        LocalResourceKind.audio,
      });
    });

    test('keeps local resource files referenced by retained indexes', () async {
      final directory = await Directory.systemTemp.createTemp('music-data-resource-shared-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final sharedAudio = await _writeFile(directory, 'shared.mp3');
      final ownedLyrics = await _writeFile(directory, 'owned.lrc');
      final localDataSource = _FakeLocalLibraryDataSource(
        tracks: {
          '1': _track('1'),
          '2': _track('2'),
        },
      );
      final resourceIndexRepository = _FakeLocalResourceIndexRepository(
        resources: [
          _resource(
            trackId: '1',
            kind: LocalResourceKind.audio,
            path: sharedAudio.path,
            origin: TrackResourceOrigin.managedDownload,
          ),
          _resource(
            trackId: '1',
            kind: LocalResourceKind.lyrics,
            path: ownedLyrics.path,
            origin: TrackResourceOrigin.managedDownload,
          ),
          _resource(
            trackId: '2',
            kind: LocalResourceKind.audio,
            path: sharedAudio.path,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
      );
      final repository = _buildRepository(
        localDataSource: localDataSource,
        resourceIndexRepository: resourceIndexRepository,
      );

      await repository.removeLocalTrackResources('1', deleteSourceFiles: true);

      expect(sharedAudio.existsSync(), isTrue);
      expect(ownedLyrics.existsSync(), isFalse);
      expect(resourceIndexRepository.remainingResourceKinds('1'), isEmpty);
      expect(resourceIndexRepository.remainingResourceKinds('2'), {
        LocalResourceKind.audio,
      });
      expect(localDataSource.removedLyrics, ['1']);
    });
  });
}

MusicDataRepository _buildRepository({
  _FakeLocalLibraryDataSource? localDataSource,
  NeteaseMusicSource? neteaseSource,
  _FakeLocalArtworkCacheRepository? artworkCacheRepository,
  _FakeLocalResourceIndexRepository? resourceIndexRepository,
}) {
  final local = localDataSource ?? _FakeLocalLibraryDataSource();
  return MusicDataRepository(
    localDataSource: local,
    neteaseSource: neteaseSource ?? _FakeNeteaseMusicSource(),
    localMusicSource: _FakeLocalMusicSource(),
    resourceIndexRepository: resourceIndexRepository ?? _FakeLocalResourceIndexRepository(),
    artworkCacheRepository: artworkCacheRepository ?? _FakeLocalArtworkCacheRepository(),
  );
}

Track _track(
  String id, {
  String? artworkUrl,
}) {
  return Track(
    id: id,
    sourceType: SourceType.netease,
    sourceId: id,
    title: 'Track $id',
    artworkUrl: artworkUrl,
  );
}

Future<File> _writeFile(
  Directory directory,
  String name, {
  String? contents,
}) async {
  final file = File('${directory.path}/$name');
  await file.writeAsString(contents ?? name);
  return file;
}

LocalResourceEntry _resource({
  required String trackId,
  required LocalResourceKind kind,
  required String path,
  required TrackResourceOrigin origin,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: trackId,
    kind: kind,
    path: path,
    origin: origin,
    sizeBytes: 1,
    createdAt: now,
    lastAccessedAt: now,
  );
}

class _FakeLocalLibraryDataSource implements LocalLibraryDataSource {
  _FakeLocalLibraryDataSource({Map<String, Track>? tracks}) : _tracks = tracks ?? {};

  final Map<String, TrackLyrics> savedLyrics = {};
  final List<String> removedLyrics = [];
  final List<String> removedTracks = [];
  final List<String> requestedTrackIds = [];
  final List<String> requestedBatchTrackIds = [];
  final List<String> requestedLyricsTrackIds = [];
  final Map<String, Track> _tracks;

  @override
  Future<Track?> getTrack(String trackId) async {
    requestedTrackIds.add(trackId);
    final track = _tracks[trackId];
    if (track != null) {
      return track;
    }
    return Track(
      id: trackId,
      sourceType: SourceType.netease,
      sourceId: trackId,
      title: 'Track $trackId',
    );
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async {
    requestedLyricsTrackIds.add(trackId);
    return savedLyrics[trackId];
  }

  @override
  Future<void> saveTracks(List<Track> tracks) async {}

  @override
  Future<List<Track>> getTracksByIds(Iterable<String> trackIds) async {
    requestedBatchTrackIds.addAll(trackIds);
    return trackIds.map((trackId) => _tracks[trackId]).whereType<Track>().toList().reversed.toList();
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {
    savedLyrics[trackId] = lyrics;
  }

  @override
  Future<void> removeTrack(String trackId) async {
    removedTracks.add(trackId);
    _tracks.remove(trackId);
  }

  @override
  Future<void> removeLyrics(String trackId) async {
    removedLyrics.add(trackId);
    savedLyrics.remove(trackId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeNeteaseMusicSource implements NeteaseMusicSource {
  _FakeNeteaseMusicSource({
    this.playbackUrlDelay = Duration.zero,
    this.lyricsDelay = Duration.zero,
    this.includeQualityInPlaybackUrl = false,
    this.includeCallCountInPlaybackUrl = false,
  });

  final Duration playbackUrlDelay;
  final Duration lyricsDelay;
  final bool includeQualityInPlaybackUrl;
  final bool includeCallCountInPlaybackUrl;
  int trackCallCount = 0;
  int playbackUrlCallCount = 0;
  int lyricsCallCount = 0;
  final List<String> playbackUrlTrackIds = [];

  @override
  Future<Track?> getTrack(String trackId) async {
    trackCallCount++;
    return _track(trackId);
  }

  @override
  Future<String?> getPlaybackUrl(
    String trackId, {
    String? qualityLevel,
  }) async {
    playbackUrlCallCount++;
    playbackUrlTrackIds.add(trackId);
    if (playbackUrlDelay > Duration.zero) {
      await Future<void>.delayed(playbackUrlDelay);
    }
    if (includeQualityInPlaybackUrl) {
      return 'https://audio.test/$trackId-${qualityLevel ?? 'normal'}.mp3';
    }
    if (includeCallCountInPlaybackUrl) {
      return 'https://audio.test/$trackId-$playbackUrlCallCount.mp3';
    }
    return 'https://audio.test/$trackId.mp3';
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async {
    lyricsCallCount++;
    if (lyricsDelay > Duration.zero) {
      await Future<void>.delayed(lyricsDelay);
    }
    return TrackLyrics(main: 'lyric-$trackId');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _ControllablePlaybackUrlNeteaseMusicSource implements NeteaseMusicSource {
  final List<Completer<String?>> _playbackUrlCompleters = <Completer<String?>>[];

  int get playbackUrlCallCount => _playbackUrlCompleters.length;

  void complete(int index, String? url) {
    _playbackUrlCompleters[index].complete(url);
  }

  @override
  Future<String?> getPlaybackUrl(
    String trackId, {
    String? qualityLevel,
  }) {
    final completer = Completer<String?>();
    _playbackUrlCompleters.add(completer);
    return completer.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeLocalMusicSource implements LocalMusicSource {
  @override
  String get sourceKey => 'local';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
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

class _FakeLocalResourceIndexRepository implements LocalResourceIndexRepository {
  _FakeLocalResourceIndexRepository({
    List<LocalResourceEntry> resources = const [],
  }) : _resources = {
          for (final resource in resources) _key(resource.trackId, resource.kind): resource,
        };

  final Map<String, LocalResourceEntry> _resources;
  final List<String> touchedResources = <String>[];
  final List<String> requestedBundleTrackIds = <String>[];

  @override
  Future<TrackResourceBundle> getTrackResourceBundle(String trackId) async {
    requestedBundleTrackIds.add(trackId);
    return _toBundle(_resources.values.where((resource) => resource.trackId == trackId));
  }

  @override
  Future<Map<String, TrackResourceBundle>> getTrackResourceBundles(
    Iterable<String> trackIds,
  ) async {
    return {
      for (final trackId in trackIds) trackId: await getTrackResourceBundle(trackId),
    };
  }

  @override
  Future<List<LocalResourceEntry>> listResources({
    Set<TrackResourceOrigin>? origins,
    Set<LocalResourceKind>? kinds,
  }) async {
    return _resources.values
        .where(
          (resource) => (origins == null || origins.isEmpty || origins.contains(resource.origin)) && (kinds == null || kinds.isEmpty || kinds.contains(resource.kind)),
        )
        .toList();
  }

  @override
  Future<void> removeResource(String trackId, LocalResourceKind kind) async {
    _resources.remove(_key(trackId, kind));
  }

  @override
  Future<void> removeTrackResources(String trackId) async {
    _resources.removeWhere((key, resource) => resource.trackId == trackId);
  }

  void saveResource(LocalResourceEntry resource) {
    _resources[_key(resource.trackId, resource.kind)] = resource;
  }

  @override
  Future<void> touchResource(String trackId, LocalResourceKind kind) async {
    final key = _key(trackId, kind);
    final resource = _resources[key];
    if (resource != null) {
      touchedResources.add(key);
      _resources[key] = resource.copyWith(lastAccessedAt: DateTime.now());
    }
  }

  Set<LocalResourceKind> remainingResourceKinds(String trackId) {
    return _resources.values.where((resource) => resource.trackId == trackId).map((resource) => resource.kind).toSet();
  }

  TrackResourceBundle _toBundle(Iterable<LocalResourceEntry> resources) {
    LocalResourceEntry? audio;
    LocalResourceEntry? artwork;
    LocalResourceEntry? lyrics;
    for (final resource in resources) {
      switch (resource.kind) {
        case LocalResourceKind.audio:
          audio = resource;
          break;
        case LocalResourceKind.artwork:
          artwork = resource;
          break;
        case LocalResourceKind.lyrics:
          lyrics = resource;
          break;
      }
    }
    return TrackResourceBundle(audio: audio, artwork: artwork, lyrics: lyrics);
  }

  static String _key(String trackId, LocalResourceKind kind) => '$trackId|${kind.name}';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeLocalArtworkCacheRepository implements LocalArtworkCacheRepository {
  int cacheCallCount = 0;
  final List<String> cachedTrackIds = [];

  @override
  Future<List<Track>> cacheTrackArtwork(List<Track> tracks) async {
    cacheCallCount++;
    cachedTrackIds.addAll(tracks.map((track) => track.id));
    return tracks;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
