import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/local_music_source.dart';
import 'package:bujuan/data/netease/netease_music_source.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:bujuan/features/library/library_preference_store.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_artwork_cache_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryRepository', () {
    test('coalesces concurrent playback url loads and reuses fresh remote url',
        () async {
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

      expect(
          lyrics.map((item) => item?.main), ['lyric-1', 'lyric-1', 'lyric-1']);
      expect(neteaseSource.lyricsCallCount, 1);
      expect(localDataSource.savedLyrics.length, 1);
    });
  });
}

LibraryRepository _buildRepository({
  _FakeLocalLibraryDataSource? localDataSource,
  _FakeNeteaseMusicSource? neteaseSource,
}) {
  final local = localDataSource ?? _FakeLocalLibraryDataSource();
  return LibraryRepository(
    localDataSource: local,
    neteaseSource: neteaseSource ?? _FakeNeteaseMusicSource(),
    localMusicSource: _FakeLocalMusicSource(),
    preferenceStore: _FakeLibraryPreferenceStore(),
    resourceIndexRepository: _FakeLocalResourceIndexRepository(),
    artworkCacheRepository: _FakeLocalArtworkCacheRepository(),
  );
}

class _FakeLocalLibraryDataSource implements LocalLibraryDataSource {
  final Map<String, TrackLyrics> savedLyrics = {};

  @override
  Future<Track?> getTrack(String trackId) async {
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
  });

  final Duration playbackUrlDelay;
  final Duration lyricsDelay;
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

class _FakeLibraryPreferenceStore implements LibraryPreferenceStore {
  @override
  bool get isOfflineModeEnabled => false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeLocalResourceIndexRepository
    implements LocalResourceIndexRepository {
  @override
  Future<TrackResourceBundle> getTrackResourceBundle(String trackId) async {
    return const TrackResourceBundle();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeLocalArtworkCacheRepository implements LocalArtworkCacheRepository {
  @override
  Future<List<Track>> cacheTrackArtwork(List<Track> tracks) async {
    return tracks;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
