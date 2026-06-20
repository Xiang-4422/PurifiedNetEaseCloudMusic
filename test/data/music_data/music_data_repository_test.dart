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
      final repository = _buildRepository(localDataSource: localDataSource);

      final tracks = await repository.getTracksWithResources(['3', '1', '3', '2']);

      expect(tracks.map((item) => item.track.id), ['3', '1', '2']);
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
  _FakeNeteaseMusicSource? neteaseSource,
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

Track _track(String id) {
  return Track(
    id: id,
    sourceType: SourceType.netease,
    sourceId: id,
    title: 'Track $id',
  );
}

Future<File> _writeFile(Directory directory, String name) async {
  final file = File('${directory.path}/$name');
  await file.writeAsString(name);
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
  final Map<String, Track> _tracks;

  @override
  Future<Track?> getTrack(String trackId) async {
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
    return savedLyrics[trackId];
  }

  @override
  Future<void> saveTracks(List<Track> tracks) async {}

  @override
  Future<List<Track>> getTracksByIds(Iterable<String> trackIds) async {
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
  int playbackUrlCallCount = 0;
  int lyricsCallCount = 0;

  @override
  Future<String?> getPlaybackUrl(
    String trackId, {
    String? qualityLevel,
  }) async {
    playbackUrlCallCount++;
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

class _FakeLocalMusicSource implements LocalMusicSource {
  @override
  String get sourceKey => 'local';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeLocalResourceIndexRepository implements LocalResourceIndexRepository {
  _FakeLocalResourceIndexRepository({
    List<LocalResourceEntry> resources = const [],
  }) : _resources = {
          for (final resource in resources) _key(resource.trackId, resource.kind): resource,
        };

  final Map<String, LocalResourceEntry> _resources;

  @override
  Future<TrackResourceBundle> getTrackResourceBundle(String trackId) async {
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
