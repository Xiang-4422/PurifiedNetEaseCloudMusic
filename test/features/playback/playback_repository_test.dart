import 'package:bujuan/data/music_data/sources/local/database/data_sources/playback_restore_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/playback_history_data_source.dart';
import 'package:bujuan/core/entities/playback_restore_state.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
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
        playbackHistoryDataSource: _FakePlaybackHistoryDataSource(),
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
        playbackHistoryDataSource: _FakePlaybackHistoryDataSource(),
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
        playbackHistoryDataSource: _FakePlaybackHistoryDataSource(),
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

    test('records non-empty recently played tracks', () async {
      final historyDataSource = _FakePlaybackHistoryDataSource();
      final repository = PlaybackRepository(
        musicDataRepository: _FakeMusicDataRepository(),
        playbackRestoreDataSource: _FakePlaybackRestoreDataSource(),
        playbackHistoryDataSource: historyDataSource,
      );

      await repository.recordPlayedTrack(
        'netease:1',
        playedAt: DateTime.fromMillisecondsSinceEpoch(1234),
      );
      await repository.recordPlayedTrack('');

      expect(historyDataSource.recordedTrackIds, ['netease:1']);
      expect(historyDataSource.recordedPlayedAt.single?.millisecondsSinceEpoch, 1234);
      expect(historyDataSource.pruneMaxEntries, [100]);
    });

    test('loads recently played tracks through music data repository', () async {
      final historyDataSource = _FakePlaybackHistoryDataSource(
        recentTrackIds: const ['netease:3', 'netease:1'],
      );
      final musicDataRepository = _FakeMusicDataRepository(
        trackResources: {
          'netease:1': _trackWithResources('netease:1'),
          'netease:3': _trackWithResources('netease:3'),
        },
      );
      final repository = PlaybackRepository(
        musicDataRepository: musicDataRepository,
        playbackRestoreDataSource: _FakePlaybackRestoreDataSource(),
        playbackHistoryDataSource: historyDataSource,
      );

      final recentTracks = await repository.loadRecentPlayedTracks(limit: 2);

      expect(historyDataSource.requestedLimits, [2]);
      expect(musicDataRepository.requestedTrackResourceIds, [
        ['netease:3', 'netease:1'],
      ]);
      expect(recentTracks.map((item) => item.track.id), ['netease:3', 'netease:1']);
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

class _FakePlaybackHistoryDataSource implements PlaybackHistoryDataSource {
  _FakePlaybackHistoryDataSource({
    this.recentTrackIds = const <String>[],
  });

  final List<String> recentTrackIds;
  final List<String> recordedTrackIds = <String>[];
  final List<DateTime?> recordedPlayedAt = <DateTime?>[];
  final List<int> requestedLimits = <int>[];
  final List<int> pruneMaxEntries = <int>[];

  @override
  Future<List<String>> loadRecentTrackIds({int limit = 20}) async {
    requestedLimits.add(limit);
    return recentTrackIds.take(limit).toList(growable: false);
  }

  @override
  Future<void> prune({int maxEntries = 100}) async {
    pruneMaxEntries.add(maxEntries);
  }

  @override
  Future<void> recordPlayedTrack(
    String trackId, {
    DateTime? playedAt,
  }) async {
    recordedTrackIds.add(trackId);
    recordedPlayedAt.add(playedAt);
  }
}

class _FakeMusicDataRepository implements MusicDataRepository {
  _FakeMusicDataRepository({
    this.trackResources = const <String, TrackWithResources>{},
  });

  final Map<String, TrackWithResources> trackResources;
  final List<String> requestedTrackIds = <String>[];
  final List<String?> requestedQualityLevels = <String?>[];
  final List<bool> forceRefreshValues = <bool>[];
  final List<List<String>> requestedTrackResourceIds = <List<String>>[];

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
  Future<List<TrackWithResources>> getTracksWithResources(
    Iterable<String> trackIds,
  ) async {
    final ids = trackIds.toList(growable: false);
    requestedTrackResourceIds.add(ids);
    return ids.map((trackId) => trackResources[trackId]).whereType<TrackWithResources>().toList(growable: false);
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

TrackWithResources _trackWithResources(String id) {
  return TrackWithResources(
    track: Track(
      id: id,
      sourceType: SourceType.netease,
      sourceId: id,
      title: 'Track $id',
    ),
    resources: const TrackResourceBundle(),
  );
}
