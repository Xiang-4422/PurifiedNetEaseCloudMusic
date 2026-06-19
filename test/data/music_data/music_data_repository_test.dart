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
  });
}

MusicDataRepository _buildRepository({
  _FakeLocalLibraryDataSource? localDataSource,
  _FakeNeteaseMusicSource? neteaseSource,
  _FakeLocalArtworkCacheRepository? artworkCacheRepository,
}) {
  final local = localDataSource ?? _FakeLocalLibraryDataSource();
  return MusicDataRepository(
    localDataSource: local,
    neteaseSource: neteaseSource ?? _FakeNeteaseMusicSource(),
    localMusicSource: _FakeLocalMusicSource(),
    resourceIndexRepository: _FakeLocalResourceIndexRepository(),
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

class _FakeLocalLibraryDataSource implements LocalLibraryDataSource {
  _FakeLocalLibraryDataSource({Map<String, Track>? tracks}) : _tracks = tracks ?? {};

  final Map<String, TrackLyrics> savedLyrics = {};
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
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeNeteaseMusicSource implements NeteaseMusicSource {
  _FakeNeteaseMusicSource({
    this.playbackUrlDelay = Duration.zero,
    this.lyricsDelay = Duration.zero,
    this.includeQualityInPlaybackUrl = false,
  });

  final Duration playbackUrlDelay;
  final Duration lyricsDelay;
  final bool includeQualityInPlaybackUrl;
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
  @override
  Future<TrackResourceBundle> getTrackResourceBundle(String trackId) async {
    return const TrackResourceBundle();
  }

  @override
  Future<Map<String, TrackResourceBundle>> getTrackResourceBundles(
    Iterable<String> trackIds,
  ) async {
    return {
      for (final trackId in trackIds) trackId: const TrackResourceBundle(),
    };
  }

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
