import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
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

    test('keeps local track results when remote track search fails', () async {
      final musicDataRepository = _FakeMusicDataRepository(
        localTracks: [
          _track('local:1', sourceType: SourceType.local),
        ],
        remoteTrackError: Exception('offline'),
      );
      final repository = SearchRepository(
        musicDataRepository: musicDataRepository,
        remoteDataSource: _FakeNeteaseSearchRemoteDataSource(),
        cacheStore: _FakeSearchCacheStore(),
        userPlaylistListDataSource: _FakeUserPlaylistListDataSource(),
      );

      final items = await repository.searchTrackQueueItems(
        'keyword',
        likedSongIds: const [],
      );

      expect(musicDataRepository.loadedTrackIds, ['local:1']);
      expect(items.map((item) => item.id), ['local:1']);
    });

    test('skips blank track ids before loading track resources', () async {
      final musicDataRepository = _FakeMusicDataRepository(
        localTracks: [
          _track('   ', sourceType: SourceType.local),
          _track('local:1', sourceType: SourceType.local),
        ],
        remoteTracks: [
          _track(''),
          _track('netease:2'),
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
        likedSongIds: const [],
      );

      expect(musicDataRepository.loadedTrackIds, ['local:1', 'netease:2']);
      expect(items.map((item) => item.id), ['local:1', 'netease:2']);
    });

    test('propagates remote track failure when no local result exists', () async {
      final repository = SearchRepository(
        musicDataRepository: _FakeMusicDataRepository(
          remoteTrackError: Exception('offline'),
        ),
        remoteDataSource: _FakeNeteaseSearchRemoteDataSource(),
        cacheStore: _FakeSearchCacheStore(),
        userPlaylistListDataSource: _FakeUserPlaylistListDataSource(),
      );

      await expectLater(
        repository.searchTrackQueueItems(
          'keyword',
          likedSongIds: const [],
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('keeps local non-track results first and appends unique remote results', () async {
      final repository = SearchRepository(
        musicDataRepository: _FakeMusicDataRepository(
          localPlaylists: [_playlist('netease:playlist-1')],
          remotePlaylists: [
            _playlist('netease:playlist-1'),
            _playlist('netease:playlist-2'),
          ],
          localAlbums: [_album('netease:album-1')],
          remoteAlbums: [
            _album('netease:album-1'),
            _album('netease:album-2'),
          ],
          localArtists: [_artist('netease:artist-1')],
          remoteArtists: [
            _artist('netease:artist-1'),
            _artist('netease:artist-2'),
          ],
        ),
        remoteDataSource: _FakeNeteaseSearchRemoteDataSource(),
        cacheStore: _FakeSearchCacheStore(),
        userPlaylistListDataSource: _FakeUserPlaylistListDataSource(),
      );

      final playlists = await repository.searchPlaylists(
        'keyword',
        currentUserId: '',
      );
      final albums = await repository.searchAlbums('keyword');
      final artists = await repository.searchArtists('keyword');

      expect(playlists.map((playlist) => playlist.id), [
        'netease:playlist-1',
        'netease:playlist-2',
      ]);
      expect(albums.map((album) => album.id), [
        'netease:album-1',
        'netease:album-2',
      ]);
      expect(artists.map((artist) => artist.id), [
        'netease:artist-1',
        'netease:artist-2',
      ]);
    });

    test('skips blank ids while merging non-track search results', () async {
      final repository = SearchRepository(
        musicDataRepository: _FakeMusicDataRepository(
          localPlaylists: [_playlist('   ', sourceType: SourceType.local)],
          remotePlaylists: [_playlist('netease:playlist')],
          localAlbums: [_album('')],
          remoteAlbums: [_album('netease:album')],
          localArtists: [_artist(' ')],
          remoteArtists: [_artist('netease:artist')],
        ),
        remoteDataSource: _FakeNeteaseSearchRemoteDataSource(),
        cacheStore: _FakeSearchCacheStore(),
        userPlaylistListDataSource: _FakeUserPlaylistListDataSource(),
      );

      final playlists = await repository.searchPlaylists(
        'keyword',
        currentUserId: '',
      );
      final albums = await repository.searchAlbums('keyword');
      final artists = await repository.searchArtists('keyword');

      expect(playlists.map((playlist) => playlist.id), ['netease:playlist']);
      expect(albums.map((album) => album.id), ['netease:album']);
      expect(artists.map((artist) => artist.id), ['netease:artist']);
    });

    test('skips user playlist cache for blank current user id', () async {
      final userPlaylistListDataSource = _FakeUserPlaylistListDataSource(
        userPlaylists: const [
          PlaylistSummaryData(id: 'user-playlist', title: 'User Playlist'),
        ],
      );
      final repository = SearchRepository(
        musicDataRepository: _FakeMusicDataRepository(
          localPlaylists: [_playlist('local:playlist', sourceType: SourceType.local)],
        ),
        remoteDataSource: _FakeNeteaseSearchRemoteDataSource(),
        cacheStore: _FakeSearchCacheStore(),
        userPlaylistListDataSource: userPlaylistListDataSource,
      );

      final playlists = await repository.searchPlaylists(
        'keyword',
        currentUserId: '   ',
      );

      expect(userPlaylistListDataSource.requestedUserIds, isEmpty);
      expect(playlists.map((playlist) => playlist.id), ['local:playlist']);
    });

    test('trims current user id before searching user playlist cache', () async {
      final userPlaylistListDataSource = _FakeUserPlaylistListDataSource(
        userPlaylists: const [
          PlaylistSummaryData(id: 'user-playlist', title: 'User Playlist'),
        ],
      );
      final repository = SearchRepository(
        musicDataRepository: _FakeMusicDataRepository(),
        remoteDataSource: _FakeNeteaseSearchRemoteDataSource(),
        cacheStore: _FakeSearchCacheStore(),
        userPlaylistListDataSource: userPlaylistListDataSource,
      );

      final playlists = await repository.searchPlaylists(
        'keyword',
        currentUserId: ' 42 ',
      );

      expect(userPlaylistListDataSource.requestedUserIds, ['42']);
      expect(playlists.map((playlist) => playlist.id), ['netease:user-playlist']);
    });

    test('normalizes user playlist summary ids before merging search playlists', () async {
      final userPlaylistListDataSource = _FakeUserPlaylistListDataSource(
        userPlaylists: const [
          PlaylistSummaryData(id: ' user-playlist ', title: 'User Playlist'),
          PlaylistSummaryData(id: ' netease:prefixed-playlist ', title: 'Prefixed Playlist'),
          PlaylistSummaryData(id: ' ', title: 'Blank Playlist'),
        ],
      );
      final repository = SearchRepository(
        musicDataRepository: _FakeMusicDataRepository(
          remotePlaylists: [
            _playlist('netease:prefixed-playlist'),
            _playlist('netease:remote-playlist'),
          ],
        ),
        remoteDataSource: _FakeNeteaseSearchRemoteDataSource(),
        cacheStore: _FakeSearchCacheStore(),
        userPlaylistListDataSource: userPlaylistListDataSource,
      );

      final playlists = await repository.searchPlaylists(
        'keyword',
        currentUserId: '42',
      );

      expect(playlists.map((playlist) => playlist.id), [
        'netease:user-playlist',
        'netease:prefixed-playlist',
        'netease:remote-playlist',
      ]);
      expect(playlists.map((playlist) => playlist.sourceId), [
        'user-playlist',
        'prefixed-playlist',
        'remote-playlist',
      ]);
    });

    test('keeps local non-track category results when remote search fails', () async {
      final repository = SearchRepository(
        musicDataRepository: _FakeMusicDataRepository(
          localPlaylists: [
            _playlist('local:playlist', sourceType: SourceType.local),
          ],
          localAlbums: [_album('netease:album')],
          localArtists: [_artist('netease:artist')],
          remotePlaylistError: Exception('offline'),
          remoteAlbumError: Exception('offline'),
          remoteArtistError: Exception('offline'),
        ),
        remoteDataSource: _FakeNeteaseSearchRemoteDataSource(),
        cacheStore: _FakeSearchCacheStore(),
        userPlaylistListDataSource: _FakeUserPlaylistListDataSource(
          userPlaylists: const [
            PlaylistSummaryData(id: 'user-playlist', title: 'User Playlist'),
          ],
        ),
      );

      final playlists = await repository.searchPlaylists(
        'keyword',
        currentUserId: '42',
      );
      final albums = await repository.searchAlbums('keyword');
      final artists = await repository.searchArtists('keyword');

      expect(playlists.map((playlist) => playlist.id), [
        'local:playlist',
        'netease:user-playlist',
      ]);
      expect(albums.map((album) => album.id), ['netease:album']);
      expect(artists.map((artist) => artist.id), ['netease:artist']);
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

PlaylistEntity _playlist(String id, {SourceType sourceType = SourceType.netease}) {
  final sourceId = id.contains(':') ? id.split(':').last : id;
  return PlaylistEntity(
    id: id,
    sourceType: sourceType,
    sourceId: sourceId,
    title: 'Playlist $sourceId',
  );
}

AlbumEntity _album(String id, {SourceType sourceType = SourceType.netease}) {
  final sourceId = id.contains(':') ? id.split(':').last : id;
  return AlbumEntity(
    id: id,
    sourceType: sourceType,
    sourceId: sourceId,
    title: 'Album $sourceId',
  );
}

ArtistEntity _artist(String id, {SourceType sourceType = SourceType.netease}) {
  final sourceId = id.contains(':') ? id.split(':').last : id;
  return ArtistEntity(
    id: id,
    sourceType: sourceType,
    sourceId: sourceId,
    name: 'Artist $sourceId',
  );
}

class _FakeMusicDataRepository implements MusicDataRepository {
  _FakeMusicDataRepository({
    this.localTracks = const [],
    this.remoteTracks = const [],
    this.localPlaylists = const [],
    this.remotePlaylists = const [],
    this.localAlbums = const [],
    this.remoteAlbums = const [],
    this.localArtists = const [],
    this.remoteArtists = const [],
    this.remoteTrackError,
    this.remotePlaylistError,
    this.remoteAlbumError,
    this.remoteArtistError,
  });

  final List<Track> localTracks;
  final List<Track> remoteTracks;
  final List<PlaylistEntity> localPlaylists;
  final List<PlaylistEntity> remotePlaylists;
  final List<AlbumEntity> localAlbums;
  final List<AlbumEntity> remoteAlbums;
  final List<ArtistEntity> localArtists;
  final List<ArtistEntity> remoteArtists;
  final Object? remoteTrackError;
  final Object? remotePlaylistError;
  final Object? remoteAlbumError;
  final Object? remoteArtistError;
  List<String> loadedTrackIds = const [];

  @override
  Future<List<Track>> searchLocalTracks(String keyword) async => localTracks;

  @override
  Future<List<Track>> searchTracks({
    required String sourceKey,
    required String keyword,
  }) async {
    if (remoteTrackError != null) {
      throw remoteTrackError!;
    }
    return remoteTracks;
  }

  @override
  Future<List<PlaylistEntity>> searchLocalPlaylists(String keyword) async => localPlaylists;

  @override
  Future<List<PlaylistEntity>> searchPlaylists({
    required String sourceKey,
    required String keyword,
  }) async {
    if (remotePlaylistError != null) {
      throw remotePlaylistError!;
    }
    return remotePlaylists;
  }

  @override
  Future<List<AlbumEntity>> searchLocalAlbums(String keyword) async => localAlbums;

  @override
  Future<List<AlbumEntity>> searchAlbums({
    required String sourceKey,
    required String keyword,
  }) async {
    if (remoteAlbumError != null) {
      throw remoteAlbumError!;
    }
    return remoteAlbums;
  }

  @override
  Future<List<ArtistEntity>> searchLocalArtists(String keyword) async => localArtists;

  @override
  Future<List<ArtistEntity>> searchArtists({
    required String sourceKey,
    required String keyword,
  }) async {
    if (remoteArtistError != null) {
      throw remoteArtistError!;
    }
    return remoteArtists;
  }

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
  _FakeUserPlaylistListDataSource({
    this.userPlaylists = const [],
  });

  final List<PlaylistSummaryData> userPlaylists;
  final List<String> requestedUserIds = <String>[];

  @override
  Future<List<PlaylistSummaryData>> searchPlaylistItems(
    String userId,
    String keyword,
  ) async {
    requestedUserIds.add(userId);
    return userPlaylists;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
