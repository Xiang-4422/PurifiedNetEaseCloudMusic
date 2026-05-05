import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_playlist_remote_data_source.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/playlist/playlist_cache_store.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylistDetailData', () {
    test('treats local detail as incomplete when snapshot has more track ids',
        () {
      final snapshot = PlaylistSnapshotData(
        id: '1',
        name: 'playlist',
        trackIds: List.generate(100, (index) => 'netease:$index'),
        creatorUserId: null,
      );
      final detail = _detail(
        songCount: 30,
        expectedTrackCount:
            PlaylistDetailData.resolveExpectedTrackCount(snapshot, null),
      );

      expect(detail.expectedTrackCount, 100);
      expect(detail.isComplete, isFalse);
    });

    test('treats local detail as complete when it reaches snapshot track ids',
        () {
      final snapshot = PlaylistSnapshotData(
        id: '1',
        name: 'playlist',
        trackIds: List.generate(100, (index) => 'netease:$index'),
        creatorUserId: null,
      );
      final detail = _detail(
        songCount: 100,
        expectedTrackCount:
            PlaylistDetailData.resolveExpectedTrackCount(snapshot, null),
      );

      expect(detail.isComplete, isTrue);
    });

    test('uses fallback track count when snapshot track ids are unavailable',
        () {
      const snapshot = PlaylistSnapshotData(
        id: '1',
        name: 'playlist',
        trackIds: [],
        creatorUserId: null,
        trackCount: 100,
      );
      final detail = _detail(
        songCount: 30,
        expectedTrackCount:
            PlaylistDetailData.resolveExpectedTrackCount(snapshot, null),
      );

      expect(detail.expectedTrackCount, 100);
      expect(detail.isComplete, isFalse);
    });

    test('allows cached detail when no expected track count is known', () {
      final detail = _detail(songCount: 30);

      expect(detail.expectedTrackCount, isNull);
      expect(detail.isComplete, isTrue);
    });
  });

  group('PlaylistPageController', () {
    test('resolves partial local cache for first screen display', () {
      final detail = _detail(songCount: 30, expectedTrackCount: 100);

      expect(
        PlaylistPageController.resolveLocalDetailDisplayState(detail),
        PlaylistLocalDetailState.partial,
      );
    });

    test('resolves remote replacement as complete after refresh succeeds', () {
      final detail = _detail(
        songCount: 100,
        expectedTrackCount: 100,
        source: PlaylistDetailSource.remote,
      );

      expect(
        PlaylistPageController.resolveLocalDetailDisplayState(detail),
        PlaylistLocalDetailState.complete,
      );
    });

    test('resolves empty local detail for initial loading or empty failure',
        () {
      expect(
        PlaylistPageController.resolveLocalDetailDisplayState(null),
        PlaylistLocalDetailState.empty,
      );
      expect(
        PlaylistPageController.resolveLocalDetailDisplayState(
          _detail(songCount: 0, expectedTrackCount: 100),
        ),
        PlaylistLocalDetailState.empty,
      );
    });
  });

  group('PlaylistRepository pagination', () {
    test('loads first page, appends next page, and completes remaining songs',
        () async {
      final repository = _playlistRepository(totalTracks: 250);

      final firstPage = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: 100,
      );
      expect(firstPage.songs, hasLength(100));
      expect(firstPage.isComplete, isFalse);

      final secondPage = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 100,
        limit: 100,
      );
      expect(secondPage.songs, hasLength(200));
      expect(secondPage.songs[99].sourceId, '99');
      expect(secondPage.songs[100].sourceId, '100');

      final completed = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 200,
        limit: -1,
      );
      expect(completed.songs, hasLength(250));
      expect(completed.isComplete, isTrue);

      final cachedSongs = await repository.loadCachedSongs('1');
      expect(cachedSongs, hasLength(250));
    });

    test('keeps loaded songs in cache when a later page fails', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 150);
      final repository =
          _playlistRepository(remoteDataSource: remoteDataSource);

      await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: 100,
      );
      remoteDataSource.failOffsets.add(100);

      await expectLater(
        repository.fetchPlaylistDetail(
          playlistId: '1',
          likedSongIds: const [],
          currentUserId: null,
          offset: 100,
          limit: 100,
        ),
        throwsStateError,
      );

      final cachedSongs = await repository.loadCachedSongs('1');
      expect(cachedSongs, hasLength(100));
    });
  });
}

PlaylistDetailData _detail({
  required int songCount,
  int? expectedTrackCount,
  PlaylistDetailSource source = PlaylistDetailSource.local,
}) {
  return PlaylistDetailData(
    songs: List.generate(songCount, (index) => _queueItem(index)),
    isSubscribed: false,
    isMyPlayList: false,
    expectedTrackCount: expectedTrackCount,
    source: source,
  );
}

PlaybackQueueItem _queueItem(int index) {
  return PlaybackQueueItem(
    id: 'netease:$index',
    sourceId: '$index',
    title: 'Song $index',
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}

PlaylistRepository _playlistRepository({
  int totalTracks = 100,
  _FakePlaylistRemoteDataSource? remoteDataSource,
}) {
  return PlaylistRepository(
    cacheStore: PlaylistCacheStore(
      cacheDataSource: _InMemoryAppCacheDataSource(),
    ),
    libraryRepository: _FakeLibraryRepository(),
    localLibraryDataSource: _FakeLocalLibraryDataSource(),
    remoteDataSource: remoteDataSource ??
        _FakePlaylistRemoteDataSource(totalTracks: totalTracks),
    userScopedDataSource: _FakeUserScopedDataSource(),
  );
}

class _FakePlaylistRemoteDataSource implements NeteasePlaylistRemoteDataSource {
  _FakePlaylistRemoteDataSource({required this.totalTracks});

  final int totalTracks;
  final Set<int> failOffsets = <int>{};

  @override
  Future<
      ({
        PlaylistEntity? playlist,
        List<String> trackIds,
        bool isSubscribed,
        String name,
        String? creatorUserId,
        bool isLikedSongs,
      })> fetchPlaylistSnapshot(String playlistId) async {
    return (
      playlist: PlaylistEntity(
        id: 'netease:$playlistId',
        sourceType: SourceType.netease,
        sourceId: playlistId,
        title: 'playlist',
        trackCount: totalTracks,
      ),
      trackIds: List.generate(totalTracks, (index) => '$index'),
      isSubscribed: false,
      name: 'playlist',
      creatorUserId: null,
      isLikedSongs: false,
    );
  }

  @override
  Future<List<Track>> fetchPlaylistSongs({
    required List<String> songIds,
    required int offset,
    required int limit,
  }) async {
    if (failOffsets.contains(offset)) {
      throw StateError('failed offset $offset');
    }
    final targetIds = songIds.skip(offset);
    final ids = limit == -1 ? targetIds : targetIds.take(limit);
    return ids.map((id) => _track(int.parse(id))).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeLibraryRepository implements LibraryRepository {
  final Map<String, Track> _tracks = <String, Track>{};

  @override
  Future<void> saveTracks(List<Track> tracks) async {
    for (final track in tracks) {
      _tracks[track.id] = track;
    }
  }

  @override
  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {}

  @override
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    return null;
  }

  @override
  Future<List<TrackWithResources>> getTracksWithResources(
    Iterable<String> trackIds,
  ) async {
    return trackIds
        .map((trackId) => _tracks[trackId])
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
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeLocalLibraryDataSource implements LocalLibraryDataSource {
  @override
  Future<void> clearPlaylistTrackRefs(String playlistId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserScopedDataSource implements UserScopedDataSource {
  @override
  Future<bool?> loadPlaylistSubscriptionState(
    String userId,
    String playlistId,
  ) async {
    return false;
  }

  @override
  Future<void> savePlaylistSubscriptionState(
    String userId,
    String playlistId,
    bool isSubscribed,
  ) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _InMemoryAppCacheDataSource implements AppCacheDataSource {
  final Map<String, AppCacheRecord> _records = <String, AppCacheRecord>{};

  @override
  Future<AppCacheRecord?> load(String cacheKey) async {
    return _records[cacheKey];
  }

  @override
  Future<String?> loadPayloadJson(String cacheKey) async {
    return _records[cacheKey]?.payloadJson;
  }

  @override
  Future<void> save({
    required String cacheKey,
    required String payloadJson,
  }) async {
    _records[cacheKey] = AppCacheRecord(
      cacheKey: cacheKey,
      payloadJson: payloadJson,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> isFresh(String cacheKey, {required Duration ttl}) async {
    return _records[cacheKey]?.isFresh(ttl) ?? false;
  }

  @override
  Future<void> delete(String cacheKey) async {
    _records.remove(cacheKey);
  }

  @override
  Future<void> deleteByPrefix(String cacheKeyPrefix) async {
    _records.removeWhere((key, value) => key.startsWith(cacheKeyPrefix));
  }
}

Track _track(int index) {
  return Track(
    id: 'netease:$index',
    sourceType: SourceType.netease,
    sourceId: '$index',
    title: 'Song $index',
    artistNames: const ['Artist'],
    albumTitle: 'Album',
    durationMs: 1000,
    artworkUrl: null,
    remoteUrl: 'https://example.com/$index.mp3',
    lyricKey: null,
    metadata: const {
      'albumId': 'album',
      'artistIds': ['artist'],
    },
  );
}
