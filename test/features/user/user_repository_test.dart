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
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_user_remote_data_source.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRepository', () {
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
  _FakeUserPlaylistListDataSource? playlistListDataSource,
}) {
  return UserRepository(
    musicDataRepository: musicDataRepository,
    remoteDataSource: remoteDataSource,
    userProfileDataSource: _FakeUserProfileDataSource(),
    userTrackListDataSource: trackListDataSource,
    userPlaylistListDataSource: playlistListDataSource ?? _FakeUserPlaylistListDataSource(),
    userSyncMarkerDataSource: _FakeUserSyncMarkerDataSource(),
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

  @override
  Future<List<int>> fetchLikedSongIds(String userId) async {
    return likedSongIds;
  }

  @override
  Future<List<PlaylistEntity>> fetchUserPlaylists(String userId) async {
    final error = userPlaylistsError;
    if (error != null) {
      throw error;
    }
    return userPlaylists;
  }

  @override
  Future<List<Track>> fetchFmSongs() async {
    return fmSongs;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserProfileDataSource implements UserProfileDataSource {
  @override
  Future<UserProfileData?> loadProfile(String userId) async {
    return null;
  }

  @override
  Future<void> saveProfile(UserProfileData profile) async {}
}

class _FakeUserTrackListDataSource implements UserTrackListDataSource {
  List<String> replacedTrackIds = [];
  UserTrackListKind? replacedKind;

  @override
  Future<List<String>> loadTrackIds(
    String userId,
    UserTrackListKind kind,
  ) async {
    return const [];
  }

  @override
  Future<void> replaceTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds,
  ) async {
    replacedKind = kind;
    replacedTrackIds = trackIds;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserPlaylistListDataSource implements UserPlaylistListDataSource {
  final Map<UserPlaylistListKind, List<PlaylistSummaryData>> replacedPlaylistItems = {};

  @override
  Future<List<PlaylistSummaryData>> loadPlaylistItems(
    String userId,
    UserPlaylistListKind kind, {
    String? keyword,
  }) async {
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
    replacedPlaylistItems[kind] = playlists;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserSyncMarkerDataSource implements UserSyncMarkerDataSource {
  @override
  Future<DateTime?> loadSyncMarker(
    String userId,
    String markerKey,
  ) async {
    return null;
  }

  @override
  Future<void> markSyncMarkerUpdated(
    String userId,
    String markerKey,
  ) async {}

  @override
  Future<void> clearSyncMarker(
    String userId,
    String markerKey,
  ) async {}
}
