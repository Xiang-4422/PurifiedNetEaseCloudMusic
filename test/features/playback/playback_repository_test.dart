import 'package:bujuan/data/music_data/sources/local/database/data_sources/playback_restore_data_source.dart';
import 'package:bujuan/core/entities/playback_restore_state.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackRepository', () {
    test('coalesces concurrent restore state writes', () async {
      final dataSource = _FakePlaybackRestoreDataSource(
        saveDelay: const Duration(milliseconds: 30),
      );
      final repository = PlaybackRepository(
        musicDataRepository: _FakeMusicDataRepository(),
        playbackRestoreDataSource: dataSource,
      );

      await repository.getRestoreState();
      final writes = List.generate(
        50,
        (index) => repository.updateRestoreState(
          position: Duration(seconds: index),
        ),
      );
      await Future.wait(writes);

      expect(dataSource.loadCount, 1);
      expect(dataSource.savedStates.length, lessThan(50));
      expect(dataSource.savedStates.last.position, const Duration(seconds: 49));
    });

    test('position-only update does not rewrite queue state', () async {
      final dataSource = _FakePlaybackRestoreDataSource();
      final repository = PlaybackRepository(
        musicDataRepository: _FakeMusicDataRepository(),
        playbackRestoreDataSource: dataSource,
      );

      await repository.updateRestoreState(
        queue: const ['netease:1', 'netease:2'],
        currentSongId: 'netease:1',
      );
      await repository.updateRestorePosition(const Duration(seconds: 42));

      expect(dataSource.savedStates, hasLength(1));
      expect(dataSource.savedStates.single.queue, ['netease:1', 'netease:2']);
      expect(dataSource.savedPositions, [const Duration(seconds: 42)]);
      expect(dataSource.loadCount, 1);
    });

    test('forwards quality and force refresh when fetching playback url', () async {
      final musicDataRepository = _FakeMusicDataRepository();
      final repository = PlaybackRepository(
        musicDataRepository: musicDataRepository,
        playbackRestoreDataSource: _FakePlaybackRestoreDataSource(),
      );

      await repository.fetchPlaybackUrl(
        'netease:1',
        preferHighQuality: true,
        forceRefresh: true,
      );

      expect(musicDataRepository.requestedTrackIds, ['netease:1']);
      expect(musicDataRepository.requestedQualityLevels, ['lossless']);
      expect(musicDataRepository.forceRefreshValues, [true]);
    });
  });
}

class _FakePlaybackRestoreDataSource implements PlaybackRestoreDataSource {
  _FakePlaybackRestoreDataSource({
    this.saveDelay = Duration.zero,
  });

  final Duration saveDelay;
  final List<PlaybackRestoreState> savedStates = <PlaybackRestoreState>[];
  final List<Duration> savedPositions = <Duration>[];
  int loadCount = 0;

  @override
  Future<PlaybackRestoreState?> getRestoreState() async {
    loadCount++;
    return const PlaybackRestoreState();
  }

  @override
  Future<void> saveRestoreState(PlaybackRestoreState state) async {
    if (saveDelay > Duration.zero) {
      await Future<void>.delayed(saveDelay);
    }
    savedStates.add(state);
  }

  @override
  Future<void> saveRestorePosition(Duration position) async {
    if (saveDelay > Duration.zero) {
      await Future<void>.delayed(saveDelay);
    }
    savedPositions.add(position);
  }
}

class _FakeMusicDataRepository implements MusicDataRepository {
  final List<String> requestedTrackIds = <String>[];
  final List<String?> requestedQualityLevels = <String?>[];
  final List<bool> forceRefreshValues = <bool>[];

  @override
  Future<String?> getPlaybackUrlWithQuality(
    String trackId, {
    String? qualityLevel,
    bool forceRefresh = false,
  }) async {
    requestedTrackIds.add(trackId);
    requestedQualityLevels.add(qualityLevel);
    forceRefreshValues.add(forceRefresh);
    return 'https://audio.test/$trackId.mp3';
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async {
    return null;
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    return null;
  }

  @override
  Future<TrackWithResources?> getTrackWithResources(String trackId) async {
    return null;
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
