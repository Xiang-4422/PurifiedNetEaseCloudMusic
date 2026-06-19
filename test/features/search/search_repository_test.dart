import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_search_remote_data_source.dart';
import 'package:bujuan/features/search/search_cache_store.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchRepository', () {
    test('keeps local results first and appends unique remote tracks', () async {
      final musicDataRepository = _FakeMusicDataRepository(
        localTracks: [
          _track('local:1', sourceType: SourceType.local),
          _track('netease:2'),
        ],
        remoteTracks: [
          _track('netease:2'),
          _track('netease:3'),
        ],
      );
      final repository = SearchRepository(
        musicDataRepository: musicDataRepository,
        remoteDataSource: _FakeNeteaseSearchRemoteDataSource(),
        cacheStore: _FakeSearchCacheStore(),
        userPlaylistListDataSource: _FakeUserPlaylistListDataSource(),
      );

      final items = await repository.searchTrackQueueItems(
        'keyword',
        likedSongIds: const [2],
      );

      expect(musicDataRepository.loadedTrackIds, [
        'local:1',
        'netease:2',
        'netease:3',
      ]);
      expect(items.map((item) => item.id), [
        'local:1',
        'netease:2',
        'netease:3',
      ]);
      expect(items.map((item) => item.isLiked), [false, true, false]);
    });
  });
}

Track _track(String id, {SourceType sourceType = SourceType.netease}) {
  final sourceId = id.contains(':') ? id.split(':').last : id;
  return Track(
    id: id,
    sourceType: sourceType,
    sourceId: sourceId,
    title: 'Track $sourceId',
  );
}

class _FakeMusicDataRepository implements MusicDataRepository {
  _FakeMusicDataRepository({
    required this.localTracks,
    required this.remoteTracks,
  });

  final List<Track> localTracks;
  final List<Track> remoteTracks;
  List<String> loadedTrackIds = const [];

  @override
  Future<List<Track>> searchLocalTracks(String keyword) async => localTracks;

  @override
  Future<List<Track>> searchTracks({
    required String sourceKey,
    required String keyword,
  }) async =>
      remoteTracks;

  @override
  Future<List<TrackWithResources>> getTracksWithResources(
    Iterable<String> trackIds,
  ) async {
    loadedTrackIds = trackIds.toList();
    final tracksById = {
      for (final track in [...localTracks, ...remoteTracks]) track.id: track,
    };
    return loadedTrackIds
        .map((trackId) => tracksById[trackId])
        .whereType<Track>()
        .map(
          (track) => TrackWithResources(
            track: track,
            resources: const TrackResourceBundle(),
          ),
        )
        .toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNeteaseSearchRemoteDataSource implements NeteaseSearchRemoteDataSource {
  @override
  Future<List<String>> fetchHotKeywords() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSearchCacheStore implements SearchCacheStore {
  @override
  Future<List<String>?> loadHotKeywords() async => const [];

  @override
  Future<void> saveHotKeywords(List<String> keywords) async {}

  @override
  Future<bool> isHotKeywordsFresh({required Duration ttl}) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserPlaylistListDataSource implements UserPlaylistListDataSource {
  @override
  Future<List<PlaylistSummaryData>> searchPlaylistItems(
    String userId,
    String keyword,
  ) async =>
      const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
