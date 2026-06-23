import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_profile_data.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_user_remote_data_source.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRepository', () {
    test('returns empty account scoped data without touching data sources for blank user id', () async {
      final remoteDataSource = _FakeNeteaseUserRemoteDataSource();
      final musicDataRepository = _FakeMusicDataRepository(resourcesByTrackId: const {});
      final profileDataSource = _FakeUserProfileDataSource();
      final trackListDataSource = _FakeUserTrackListDataSource();
      final playlistListDataSource = _FakeUserPlaylistListDataSource();
      final syncMarkerDataSource = _FakeUserSyncMarkerDataSource();
      final repository = _buildRepository(
        musicDataRepository: musicDataRepository,
        remoteDataSource: remoteDataSource,
        profileDataSource: profileDataSource,
        trackListDataSource: trackListDataSource,
        playlistListDataSource: playlistListDataSource,
        syncMarkerDataSource: syncMarkerDataSource,
      );

      expect(await repository.loadCachedUserDetail('   '), isNull);
      expect((await repository.fetchUserDetail('   ')).userId, isEmpty);
      expect(await repository.loadCachedLikedSongIds('   '), isEmpty);
      expect(
        await repository.loadCachedPlaylistList(
          '   ',
          UserPlaylistListKind.userPlaylists,
        ),
        isEmpty,
      );
      expect(
        await repository.loadCachedTrackList(
          userId: '   ',
          kind: UserTrackListKind.liked,
          likedSongIds: const [],
        ),
        isEmpty,
      );
      expect(
        await repository.isSyncMarkerFresh(
          userId: '   ',
          markerKey: 'library',
          ttl: const Duration(minutes: 5),
        ),
        isFalse,
      );
      await repository.markSyncMarkerUpdated(
        userId: '   ',
        markerKey: 'library',
      );
      expect(await repository.fetchLikedSongIds('   '), isEmpty);

      final snapshot = await repository.fetchUserLibrarySnapshot('   ');
      expect(snapshot.likedSongIds, isEmpty);
      expect(snapshot.playlists, isEmpty);

      expect(
        await repository.fetchRecommendedPlaylists(
          userId: '   ',
          offset: 0,
        ),
        isEmpty,
      );
      expect(await repository.fetchUserPlaylists('   '), isEmpty);
      expect(
        await repository.fetchTodayRecommendSongs(
          userId: '   ',
          likedSongIds: const [],
        ),
        isEmpty,
      );
      expect(
        await repository.fetchFmSongs(
          userId: '   ',
          likedSongIds: const [],
        ),
        isEmpty,
      );
      final toggleResult = await repository.toggleLikeSong(
        '   ',
        '101',
        true,
      );
      expect(toggleResult.success, isFalse);

      expect(remoteDataSource.fetchUserDetailCalls, 0);
      expect(remoteDataSource.fetchLikedSongIdsCalls, 0);
      expect(remoteDataSource.fetchUserPlaylistsCalls, 0);
      expect(remoteDataSource.fetchRecommendedPlaylistsCalls, 0);
      expect(remoteDataSource.fetchTodayRecommendSongsCalls, 0);
      expect(remoteDataSource.fetchFmSongsCalls, 0);
      expect(remoteDataSource.toggleLikeSongCalls, 0);
      expect(profileDataSource.loadProfileCalls, 0);
      expect(profileDataSource.saveProfileCalls, 0);
      expect(trackListDataSource.loadTrackIdsCalls, 0);
      expect(trackListDataSource.replaceTrackListCalls, 0);
      expect(trackListDataSource.upsertTrackRefCalls, 0);
      expect(trackListDataSource.deleteTrackRefCalls, 0);
      expect(playlistListDataSource.loadPlaylistItemsCalls, 0);
      expect(playlistListDataSource.replacePlaylistItemsCalls, 0);
      expect(playlistListDataSource.appendPlaylistItemsCalls, 0);
      expect(syncMarkerDataSource.loadSyncMarkerCalls, 0);
      expect(syncMarkerDataSource.markSyncMarkerUpdatedCalls, 0);
      expect(musicDataRepository.savedTrackIds, isEmpty);
      expect(musicDataRepository.requestedResourceIds, isEmpty);
    });

    test('builds fetched FM queue items from saved track resources', () async {
      final remoteDataSource = _FakeNeteaseUserRemoteDataSource(
        fmSongs: [_track('netease:1')],
      );
      final musicDataRepository = _FakeMusicDataRepository(
        resourcesByTrackId: {
          'netease:1': TrackResourceBundle(
            audio: _audioResource(
              trackId: 'netease:1',
              path: '/cache/audio/fm.mp3',
            ),
          ),
        },
      );
      final trackListDataSource = _FakeUserTrackListDataSource();
      final repository = _buildRepository(
        musicDataRepository: musicDataRepository,
        remoteDataSource: remoteDataSource,
        trackListDataSource: trackListDataSource,
      );

      final items = await repository.fetchFmSongs(
        userId: 'user-1',
        likedSongIds: const [1],
      );

      expect(musicDataRepository.savedTrackIds, ['netease:1']);
      expect(musicDataRepository.requestedResourceIds, ['netease:1']);
      expect(trackListDataSource.replacedTrackIds, ['netease:1']);
      expect(trackListDataSource.replacedKind, UserTrackListKind.fm);
      expect(items, hasLength(1));
      expect(items.single.mediaType, MediaType.local);
      expect(items.single.playbackUrl, '/cache/audio/fm.mp3');
      expect(items.single.isCached, isTrue);
      expect(items.single.isLiked, isTrue);
    });

    test('keeps remote FM songs when local resource aggregation is partial', () async {
      final remoteDataSource = _FakeNeteaseUserRemoteDataSource(
        fmSongs: [
          _track('netease:1'),
          _track('netease:2'),
        ],
      );
      final musicDataRepository = _FakeMusicDataRepository(
        resourcesByTrackId: {
          'netease:1': TrackResourceBundle(
            audio: _audioResource(
              trackId: 'netease:1',
              path: '/cache/audio/fm-1.mp3',
            ),
          ),
        },
        missingResourceTrackIds: const {'netease:2'},
      );
      final trackListDataSource = _FakeUserTrackListDataSource();
      final repository = _buildRepository(
        musicDataRepository: musicDataRepository,
        remoteDataSource: remoteDataSource,
        trackListDataSource: trackListDataSource,
      );

      final items = await repository.fetchFmSongs(
        userId: 'user-1',
        likedSongIds: const [],
      );

      expect(musicDataRepository.requestedResourceIds, [
        'netease:1',
        'netease:2',
      ]);
      expect(items.map((item) => item.id), [
        'netease:1',
        'netease:2',
      ]);
      expect(items.first.mediaType, MediaType.local);
      expect(items.first.playbackUrl, '/cache/audio/fm-1.mp3');
      expect(items.first.isCached, isTrue);
      expect(items.last.mediaType, MediaType.fm);
      expect(items.last.playbackUrl, isNull);
      expect(items.last.isCached, isFalse);
    });

    test('writes user library snapshot after all remote branches succeed', () async {
      final remoteDataSource = _FakeNeteaseUserRemoteDataSource(
        likedSongIds: const [101],
        userPlaylists: [
          _playlist('liked', title: 'Liked'),
          _playlist('own', title: 'Own'),
        ],
      );
      final trackListDataSource = _FakeUserTrackListDataSource();
      final playlistListDataSource = _FakeUserPlaylistListDataSource();
      final repository = _buildRepository(
        musicDataRepository: _FakeMusicDataRepository(resourcesByTrackId: const {}),
        remoteDataSource: remoteDataSource,
        trackListDataSource: trackListDataSource,
        playlistListDataSource: playlistListDataSource,
      );

      final snapshot = await repository.fetchUserLibrarySnapshot('user-1');

      expect(snapshot.likedSongIds, [101]);
      expect(snapshot.playlists.map((playlist) => playlist.id), [
        'liked',
        'own',
      ]);
      expect(trackListDataSource.replacedKind, UserTrackListKind.liked);
      expect(trackListDataSource.replacedTrackIds, ['netease:101']);
      expect(
        playlistListDataSource.replacedPlaylistItems[UserPlaylistListKind.likedCollection]?.map((playlist) => playlist.id),
        ['liked'],
      );
      expect(
        playlistListDataSource.replacedPlaylistItems[UserPlaylistListKind.userPlaylists]?.map((playlist) => playlist.id),
        ['own'],
      );
    });

    test('does not replace local library snapshot when a remote branch fails', () async {
      final remoteDataSource = _FakeNeteaseUserRemoteDataSource(
        likedSongIds: const [101],
        userPlaylistsError: StateError('offline'),
      );
      final trackListDataSource = _FakeUserTrackListDataSource();
      final playlistListDataSource = _FakeUserPlaylistListDataSource();
      final repository = _buildRepository(
        musicDataRepository: _FakeMusicDataRepository(resourcesByTrackId: const {}),
        remoteDataSource: remoteDataSource,
        trackListDataSource: trackListDataSource,
        playlistListDataSource: playlistListDataSource,
      );

      await expectLater(
        repository.fetchUserLibrarySnapshot('user-1'),
        throwsA(isA<StateError>()),
      );

      expect(trackListDataSource.replacedKind, isNull);
      expect(trackListDataSource.replacedTrackIds, isEmpty);
      expect(playlistListDataSource.replacedPlaylistItems, isEmpty);
    });
  });
}

UserRepository _buildRepository({
  required _FakeMusicDataRepository musicDataRepository,
  required _FakeNeteaseUserRemoteDataSource remoteDataSource,
  required _FakeUserTrackListDataSource trackListDataSource,
  _FakeUserProfileDataSource? profileDataSource,
  _FakeUserPlaylistListDataSource? playlistListDataSource,
  _FakeUserSyncMarkerDataSource? syncMarkerDataSource,
}) {
  return UserRepository(
    musicDataRepository: musicDataRepository,
    remoteDataSource: remoteDataSource,
    userProfileDataSource: profileDataSource ?? _FakeUserProfileDataSource(),
    userTrackListDataSource: trackListDataSource,
    userPlaylistListDataSource: playlistListDataSource ?? _FakeUserPlaylistListDataSource(),
    userSyncMarkerDataSource: syncMarkerDataSource ?? _FakeUserSyncMarkerDataSource(),
  );
}

Track _track(String id) {
  return Track(
    id: id,
    sourceType: SourceType.netease,
    sourceId: id.split(':').last,
    title: 'Track $id',
  );
}

PlaylistEntity _playlist(String sourceId, {required String title}) {
  return PlaylistEntity(
    id: 'netease:$sourceId',
    sourceType: SourceType.netease,
    sourceId: sourceId,
    title: title,
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
    origin: TrackResourceOrigin.playbackCache,
    sizeBytes: 1,
    createdAt: now,
    lastAccessedAt: now,
  );
}

class _FakeMusicDataRepository implements MusicDataRepository {
  _FakeMusicDataRepository({
    required this.resourcesByTrackId,
    this.missingResourceTrackIds = const {},
  });

  final Map<String, TrackResourceBundle> resourcesByTrackId;
  final Set<String> missingResourceTrackIds;
  final List<String> savedTrackIds = [];
  final List<String> requestedResourceIds = [];

  @override
  Future<void> saveTracks(
    List<Track> tracks, {
    bool precacheArtwork = true,
  }) async {
    savedTrackIds.addAll(tracks.map((track) => track.id));
  }

  @override
  Future<List<TrackWithResources>> getTracksWithResources(
    Iterable<String> trackIds,
  ) async {
    requestedResourceIds.addAll(trackIds);
    return [
      for (final trackId in trackIds)
        if (!missingResourceTrackIds.contains(trackId))
          TrackWithResources(
            track: _track(trackId),
            resources: resourcesByTrackId[trackId] ?? const TrackResourceBundle(),
          ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeNeteaseUserRemoteDataSource implements NeteaseUserRemoteDataSource {
  _FakeNeteaseUserRemoteDataSource({
    this.fmSongs = const [],
    this.likedSongIds = const [],
    this.userPlaylists = const [],
    this.userPlaylistsError,
  });

  final List<Track> fmSongs;
  final List<int> likedSongIds;
  final List<PlaylistEntity> userPlaylists;
  final Object? userPlaylistsError;
  int fetchUserDetailCalls = 0;
  int fetchLikedSongIdsCalls = 0;
  int fetchUserPlaylistsCalls = 0;
  int fetchRecommendedPlaylistsCalls = 0;
  int fetchTodayRecommendSongsCalls = 0;
  int fetchFmSongsCalls = 0;
  int toggleLikeSongCalls = 0;

  @override
  Future<UserProfileData> fetchUserDetail(String userId) async {
    fetchUserDetailCalls++;
    return const UserProfileData(
      userId: 'user-1',
      nickname: 'User 1',
      signature: '',
      follows: 0,
      followeds: 0,
      playlistCount: 0,
      avatarUrl: '',
    );
  }

  @override
  Future<List<int>> fetchLikedSongIds(String userId) async {
    fetchLikedSongIdsCalls++;
    return likedSongIds;
  }

  @override
  Future<List<PlaylistEntity>> fetchUserPlaylists(String userId) async {
    fetchUserPlaylistsCalls++;
    final error = userPlaylistsError;
    if (error != null) {
      throw error;
    }
    return userPlaylists;
  }

  @override
  Future<List<PlaylistEntity>> fetchRecommendedPlaylists({
    required int offset,
    required int limit,
  }) async {
    fetchRecommendedPlaylistsCalls++;
    return const [];
  }

  @override
  Future<List<Track>> fetchTodayRecommendSongs() async {
    fetchTodayRecommendSongsCalls++;
    return const [];
  }

  @override
  Future<List<Track>> fetchFmSongs() async {
    fetchFmSongsCalls++;
    return fmSongs;
  }

  @override
  Future<RemoteOperationResult> toggleLikeSong(String songId, bool like) async {
    toggleLikeSongCalls++;
    return (success: true, message: null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserProfileDataSource implements UserProfileDataSource {
  int loadProfileCalls = 0;
  int saveProfileCalls = 0;

  @override
  Future<UserProfileData?> loadProfile(String userId) async {
    loadProfileCalls++;
    return null;
  }

  @override
  Future<void> saveProfile(UserProfileData profile) async {
    saveProfileCalls++;
  }
}

class _FakeUserTrackListDataSource implements UserTrackListDataSource {
  List<String> replacedTrackIds = [];
  UserTrackListKind? replacedKind;
  int loadTrackIdsCalls = 0;
  int replaceTrackListCalls = 0;
  int upsertTrackRefCalls = 0;
  int deleteTrackRefCalls = 0;

  @override
  Future<List<String>> loadTrackIds(
    String userId,
    UserTrackListKind kind,
  ) async {
    loadTrackIdsCalls++;
    return const [];
  }

  @override
  Future<void> replaceTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds,
  ) async {
    replaceTrackListCalls++;
    replacedKind = kind;
    replacedTrackIds = trackIds;
  }

  @override
  Future<void> upsertTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId, {
    int? sortOrder,
  }) async {
    upsertTrackRefCalls++;
  }

  @override
  Future<void> deleteTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId,
  ) async {
    deleteTrackRefCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserPlaylistListDataSource implements UserPlaylistListDataSource {
  final Map<UserPlaylistListKind, List<PlaylistSummaryData>> replacedPlaylistItems = {};
  int loadPlaylistItemsCalls = 0;
  int replacePlaylistItemsCalls = 0;
  int appendPlaylistItemsCalls = 0;

  @override
  Future<List<PlaylistSummaryData>> loadPlaylistItems(
    String userId,
    UserPlaylistListKind kind, {
    String? keyword,
  }) async {
    loadPlaylistItemsCalls++;
    return const [];
  }

  @override
  Future<List<PlaylistSummaryData>> searchPlaylistItems(
    String userId,
    String keyword,
  ) async {
    return const [];
  }

  @override
  Future<void> replacePlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> playlists,
  ) async {
    replacePlaylistItemsCalls++;
    replacedPlaylistItems[kind] = playlists;
  }

  @override
  Future<void> appendPlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items, {
    required int startOrder,
  }) async {
    appendPlaylistItemsCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserSyncMarkerDataSource implements UserSyncMarkerDataSource {
  int loadSyncMarkerCalls = 0;
  int markSyncMarkerUpdatedCalls = 0;

  @override
  Future<DateTime?> loadSyncMarker(
    String userId,
    String markerKey,
  ) async {
    loadSyncMarkerCalls++;
    return null;
  }

  @override
  Future<void> markSyncMarkerUpdated(
    String userId,
    String markerKey,
  ) async {
    markSyncMarkerUpdatedCalls++;
  }

  @override
  Future<void> clearSyncMarker(
    String userId,
    String markerKey,
  ) async {}
}
