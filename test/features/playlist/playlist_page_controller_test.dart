import 'package:bujuan/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_library_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_playlist_remote_data_source.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/playlist_track_ref.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylistDetailData', () {
    test('treats local detail as incomplete when ordered track count is larger', () {
      final detail = _detail(
        songCount: 30,
        expectedTrackCount: PlaylistDetailData.resolveExpectedTrackCount(100, null),
      );

      expect(detail.expectedTrackCount, 100);
      expect(detail.isComplete, isFalse);
    });

    test('treats local detail as complete when it reaches ordered track count', () {
      final detail = _detail(
        songCount: 100,
        expectedTrackCount: PlaylistDetailData.resolveExpectedTrackCount(100, null),
      );

      expect(detail.isComplete, isTrue);
    });

    test('uses fallback track count when ordered track ids are unavailable', () {
      final detail = _detail(
        songCount: 30,
        expectedTrackCount: PlaylistDetailData.resolveExpectedTrackCount(0, 100),
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

    test('resolves empty local detail for initial loading or empty failure', () {
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

    test('loads initial detail as empty when no local songs are available', () async {
      final controller = _playlistPageController();

      final data = await controller.loadInitialDetail('1');

      expect(data.localDetail, isNull);
      expect(data.localPlaylist, isNull);
      expect(data.localState, PlaylistLocalDetailState.empty);
    });

    test('loads initial detail as partial when local database contains first page only', () async {
      final repository = _playlistRepository(totalTracks: 100);
      await repository.fetchPlaylistSongs(
        playlistId: '1',
        likedSongIds: const [],
        offset: 0,
        limit: 30,
      );
      final controller = _playlistPageController(repository: repository);

      final data = await controller.loadInitialDetail('1');

      expect(data.localPlaylist?.trackCount, 100);
      expect(data.localDetail?.songs, hasLength(30));
      expect(data.localState, PlaylistLocalDetailState.partial);
    });

    test('loads initial detail as complete when local tracks cover playlist index', () async {
      final repository = _playlistRepository(totalTracks: 30);
      await repository.fetchPlaylistSongs(
        playlistId: '1',
        likedSongIds: const [],
        offset: 0,
        limit: 30,
      );
      final controller = _playlistPageController(repository: repository);

      final data = await controller.loadInitialDetail('1');

      expect(data.localPlaylist?.trackCount, 30);
      expect(data.localDetail?.songs, hasLength(30));
      expect(data.localState, PlaylistLocalDetailState.complete);
    });

    test('page loading methods use first page, remaining, and full refresh requests', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 250);
      final controller = _playlistPageController(
        repository: _playlistRepository(remoteDataSource: remoteDataSource),
      );

      await controller.fetchFirstPage('1');
      await controller.fetchRemaining('1', offset: 30);
      await controller.refreshFull('1');

      expect(remoteDataSource.songRequests, const [
        (offset: 0, limit: 30),
        (offset: 0, limit: -1),
        (offset: 0, limit: -1),
      ]);
    });
  });

  group('PlaylistRepository remote loading', () {
    test('previews first page in memory and then saves full remote result', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 250);
      final repository = _playlistRepository(remoteDataSource: remoteDataSource);

      final firstPage = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: 30,
      );
      expect(firstPage.songs, hasLength(30));
      expect(firstPage.isComplete, isFalse);
      expect(
        await repository.loadLocalPlaylistDetail(
          playlistId: '1',
          likedSongIds: const [],
          currentUserId: null,
        ),
        isNull,
      );

      final completed = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 30,
        limit: -1,
      );
      expect(completed.songs, hasLength(250));
      expect(completed.isComplete, isTrue);
      expect(completed.songs[29].sourceId, '29');
      expect(completed.songs[30].sourceId, '30');
      expect(remoteDataSource.songRequests, const [
        (offset: 0, limit: 30),
        (offset: 0, limit: -1),
      ]);

      final localDetail = await repository.loadLocalPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
      );
      expect(localDetail?.songs, hasLength(250));
    });

    test('keeps first page songs in cache when remaining load fails', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 150);
      final repository = _playlistRepository(remoteDataSource: remoteDataSource);

      await repository.fetchPlaylistSongs(
        playlistId: '1',
        likedSongIds: const [],
        offset: 0,
        limit: 30,
      );
      remoteDataSource.failOffsets.add(0);

      await expectLater(
        repository.fetchPlaylistDetail(
          playlistId: '1',
          likedSongIds: const [],
          currentUserId: null,
          offset: 30,
          limit: -1,
        ),
        throwsStateError,
      );

      final localDetail = await repository.loadLocalPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
      );
      expect(localDetail?.songs, hasLength(30));
    });

    test('fetches playlist songs with saved local audio resources', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 3);
      final tracks = <String, Track>{};
      final musicDataRepository = _FakeMusicDataRepository(
        tracks,
        resourcesByTrackId: {
          'netease:1': TrackResourceBundle(
            audio: _audioResource(
              trackId: 'netease:1',
              path: '/cache/audio/playlist-1.mp3',
            ),
          ),
        },
      );
      final repository = PlaylistRepository(
        appCacheDataSource: _InMemoryAppCacheDataSource(),
        musicDataRepository: musicDataRepository,
        localLibraryDataSource: _FakeLocalLibraryDataSource(tracks),
        remoteDataSource: remoteDataSource,
        playlistSubscriptionDataSource: _FakePlaylistSubscriptionDataSource(),
      );

      final songs = await repository.fetchPlaylistSongs(
        playlistId: '1',
        likedSongIds: const [1],
        offset: 1,
        limit: 1,
      );

      expect(musicDataRepository.requestedResourceIds, contains('netease:1'));
      expect(songs, hasLength(1));
      expect(songs.single.id, 'netease:1');
      expect(songs.single.mediaType, MediaType.local);
      expect(songs.single.playbackUrl, '/cache/audio/playlist-1.mp3');
      expect(songs.single.isCached, isTrue);
      expect(songs.single.isLiked, isTrue);
    });

    test('first page preview keeps remote metadata while using local audio resources', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 3);
      final repository = _playlistRepository(
        remoteDataSource: remoteDataSource,
        resourcesByTrackId: {
          'netease:0': TrackResourceBundle(
            audio: _audioResource(
              trackId: 'netease:0',
              path: '/cache/audio/playlist-0.mp3',
            ),
          ),
        },
      );

      await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: -1,
      );
      remoteDataSource.titleVersion = 1;

      final preview = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: 1,
      );

      expect(preview.songs, hasLength(1));
      expect(preview.songs.single.title, 'Song v1 0');
      expect(preview.songs.single.mediaType, MediaType.local);
      expect(preview.songs.single.playbackUrl, '/cache/audio/playlist-0.mp3');
      expect(preview.songs.single.isCached, isTrue);
    });

    test('first page preview does not overwrite complete cached songs', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 250);
      final repository = _playlistRepository(remoteDataSource: remoteDataSource);

      await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: -1,
      );
      remoteDataSource.titleVersion = 1;

      final preview = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: 30,
      );
      final localDetail = await repository.loadLocalPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
      );

      expect(preview.songs, hasLength(30));
      expect(preview.isComplete, isFalse);
      expect(preview.songs.first.title, 'Song v1 0');
      expect(localDetail?.songs, hasLength(250));
      expect(localDetail?.songs.first.title, 'Song 0');
    });

    test('full refresh drops local suffix removed from latest index', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 250);
      final repository = _playlistRepository(remoteDataSource: remoteDataSource);

      await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: -1,
      );
      remoteDataSource
        ..totalTracks = 120
        ..titleVersion = 1;

      final refreshed = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: -1,
      );
      final localDetail = await repository.loadLocalPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
      );

      expect(refreshed.songs, hasLength(120));
      expect(refreshed.isComplete, isTrue);
      expect(refreshed.songs.first.title, 'Song v1 0');
      expect(refreshed.songs[30].title, 'Song v1 30');
      expect(refreshed.songs.last.sourceId, '119');
      expect(localDetail?.songs, hasLength(120));
    });

    test('refreshes first page when latest index contains raw track ids', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 120);
      final repository = _playlistRepository(remoteDataSource: remoteDataSource);

      await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: -1,
      );
      remoteDataSource
        ..usesPlaylistTrackRefs = true
        ..prefixPlaylistTrackRefs = false
        ..titleVersion = 1;

      final refreshed = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: -1,
      );

      expect(refreshed.songs, hasLength(120));
      expect(refreshed.songs.first.id, 'netease:0');
      expect(refreshed.songs.first.title, 'Song v1 0');
      expect(refreshed.songs[30].title, 'Song v1 30');
    });

    test('full refresh treats returned subset as complete local playlist', () async {
      final remoteDataSource = _FakePlaylistRemoteDataSource(totalTracks: 120)..maxReturnedTracks = 80;
      final repository = _playlistRepository(remoteDataSource: remoteDataSource);

      final refreshed = await repository.fetchPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
        offset: 0,
        limit: -1,
      );
      final localDetail = await repository.loadLocalPlaylistDetail(
        playlistId: '1',
        likedSongIds: const [],
        currentUserId: null,
      );
      final controller = _playlistPageController(repository: repository);
      final initialData = await controller.loadInitialDetail('1');

      expect(refreshed.songs, hasLength(80));
      expect(refreshed.isComplete, isTrue);
      expect(localDetail?.songs, hasLength(80));
      expect(localDetail?.expectedTrackCount, 80);
      expect(initialData.localState, PlaylistLocalDetailState.complete);
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
  AppCacheDataSource? cacheDataSource,
  Map<String, TrackResourceBundle> resourcesByTrackId = const {},
}) {
  final tracks = <String, Track>{};
  return PlaylistRepository(
    appCacheDataSource: cacheDataSource ?? _InMemoryAppCacheDataSource(),
    musicDataRepository: _FakeMusicDataRepository(
      tracks,
      resourcesByTrackId: resourcesByTrackId,
    ),
    localLibraryDataSource: _FakeLocalLibraryDataSource(tracks),
    remoteDataSource: remoteDataSource ?? _FakePlaylistRemoteDataSource(totalTracks: totalTracks),
    playlistSubscriptionDataSource: _FakePlaylistSubscriptionDataSource(),
  );
}

PlaylistPageController _playlistPageController({
  PlaylistRepository? repository,
}) {
  return PlaylistPageController(
    repository: repository ?? _playlistRepository(),
    likedSongIds: () => const [],
    currentUserId: () => '',
  );
}

class _FakePlaylistRemoteDataSource implements NeteasePlaylistRemoteDataSource {
  _FakePlaylistRemoteDataSource({required this.totalTracks});

  int totalTracks;
  int titleVersion = 0;
  bool usesPlaylistTrackRefs = false;
  bool prefixPlaylistTrackRefs = true;
  int? maxReturnedTracks;
  final Set<int> failOffsets = <int>{};
  final List<({int offset, int limit})> songRequests = <({int offset, int limit})>[];

  @override
  Future<
      ({
        PlaylistEntity? playlist,
        List<String> trackIds,
        bool isSubscribed,
        String name,
        String? creatorUserId,
        bool isLikedSongs,
      })> fetchPlaylistIndex(String playlistId) async {
    return (
      playlist: PlaylistEntity(
        id: 'netease:$playlistId',
        sourceType: SourceType.netease,
        sourceId: playlistId,
        title: 'playlist',
        trackCount: totalTracks,
        trackRefs: usesPlaylistTrackRefs
            ? List.generate(
                totalTracks,
                (index) => PlaylistTrackRef(
                  trackId: prefixPlaylistTrackRefs ? 'netease:$index' : '$index',
                  order: index,
                ),
              )
            : const [],
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
    songRequests.add((offset: offset, limit: limit));
    if (failOffsets.contains(offset)) {
      throw StateError('failed offset $offset');
    }
    final targetIds = songIds.skip(offset);
    var ids = limit == -1 ? targetIds : targetIds.take(limit);
    if (maxReturnedTracks != null) {
      ids = ids.take(maxReturnedTracks!);
    }
    return ids.map((id) => _track(int.parse(id), titleVersion: titleVersion)).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeMusicDataRepository implements MusicDataRepository {
  _FakeMusicDataRepository(
    this._tracks, {
    this.resourcesByTrackId = const {},
  });

  final Map<String, Track> _tracks;
  final Map<String, TrackResourceBundle> resourcesByTrackId;
  final List<String> requestedResourceIds = [];

  @override
  Future<void> saveTracks(
    List<Track> tracks, {
    bool precacheArtwork = true,
  }) async {
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
    requestedResourceIds.addAll(trackIds);
    return trackIds
        .map((trackId) => _tracks[trackId])
        .whereType<Track>()
        .map(
          (track) => TrackWithResources(
            track: track,
            resources: resourcesByTrackId[track.id] ?? const TrackResourceBundle(),
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
  _FakeLocalLibraryDataSource(this._tracks);

  final Map<String, PlaylistEntity> _playlists = <String, PlaylistEntity>{};
  final Map<String, Track> _tracks;

  @override
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    return _playlists[playlistId];
  }

  @override
  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {
    for (final playlist in playlists) {
      _playlists[playlist.id] = playlist;
    }
  }

  @override
  Future<void> clearPlaylistTrackRefs(String playlistId) async {
    final playlist = _playlists[playlistId];
    if (playlist == null) {
      return;
    }
    _playlists[playlistId] = playlist.copyWith(trackRefs: const []);
  }

  @override
  Future<void> saveTracks(List<Track> tracks) async {
    for (final track in tracks) {
      _tracks[track.id] = track;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakePlaylistSubscriptionDataSource implements PlaylistSubscriptionDataSource {
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

Track _track(int index, {int titleVersion = 0}) {
  return Track(
    id: 'netease:$index',
    sourceType: SourceType.netease,
    sourceId: '$index',
    title: titleVersion == 0 ? 'Song $index' : 'Song v$titleVersion $index',
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

LocalResourceEntry _audioResource({
  required String trackId,
  required String path,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: trackId,
    kind: LocalResourceKind.audio,
    path: path,
    origin: TrackResourceOrigin.managedDownload,
    sizeBytes: 1,
    createdAt: now,
    lastAccessedAt: now,
  );
}
