import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
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
  });
}

UserRepository _buildRepository({
  required _FakeMusicDataRepository musicDataRepository,
  required _FakeNeteaseUserRemoteDataSource remoteDataSource,
  required _FakeUserTrackListDataSource trackListDataSource,
}) {
  return UserRepository(
    musicDataRepository: musicDataRepository,
    remoteDataSource: remoteDataSource,
    userProfileDataSource: _FakeUserProfileDataSource(),
    userTrackListDataSource: trackListDataSource,
    userPlaylistListDataSource: _FakeUserPlaylistListDataSource(),
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
  _FakeMusicDataRepository({required this.resourcesByTrackId});

  final Map<String, TrackResourceBundle> resourcesByTrackId;
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
  _FakeNeteaseUserRemoteDataSource({required this.fmSongs});

  final List<Track> fmSongs;

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
