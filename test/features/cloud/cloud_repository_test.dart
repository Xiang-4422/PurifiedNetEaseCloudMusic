import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_cloud_remote_data_source.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudRepository', () {
    test('ignores blank user id before cache or remote access', () async {
      final remoteDataSource = _FakeNeteaseCloudRemoteDataSource(
        tracks: [_track('netease:1')],
      );
      final musicDataRepository = _FakeMusicDataRepository(
        resourcesByTrackId: const {},
      );
      final trackListDataSource = _FakeUserTrackListDataSource();
      final repository = CloudRepository(
        musicDataRepository: musicDataRepository,
        userTrackListDataSource: trackListDataSource,
        remoteDataSource: remoteDataSource,
      );

      final cachedSongs = await repository.loadCachedSongs(
        userId: '   ',
        likedSongIds: const [1],
      );
      final page = await repository.fetchCloudSongs(
        userId: '   ',
        offset: 0,
        limit: 30,
        likedSongIds: const [1],
      );

      expect(cachedSongs, isEmpty);
      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
      expect(page.nextOffset, 0);
      expect(remoteDataSource.fetchCallCount, 0);
      expect(musicDataRepository.savedTrackIds, isEmpty);
      expect(musicDataRepository.requestedResourceIds, isEmpty);
      expect(trackListDataSource.loadedUserIds, isEmpty);
      expect(trackListDataSource.replacedUserIds, isEmpty);
    });

    test('builds fetched cloud songs from saved track resources', () async {
      final remoteDataSource = _FakeNeteaseCloudRemoteDataSource(
        tracks: [_track('netease:1')],
      );
      final musicDataRepository = _FakeMusicDataRepository(
        resourcesByTrackId: {
          'netease:1': TrackResourceBundle(
            audio: _audioResource(
              trackId: 'netease:1',
              path: '/cache/audio/cloud.mp3',
            ),
          ),
        },
      );
      final trackListDataSource = _FakeUserTrackListDataSource();
      final repository = CloudRepository(
        musicDataRepository: musicDataRepository,
        userTrackListDataSource: trackListDataSource,
        remoteDataSource: remoteDataSource,
      );

      final page = await repository.fetchCloudSongs(
        userId: 'user-1',
        offset: 0,
        limit: 30,
        likedSongIds: const [1],
      );

      expect(musicDataRepository.savedTrackIds, ['netease:1']);
      expect(musicDataRepository.requestedResourceIds, ['netease:1']);
      expect(trackListDataSource.replacedTrackIds, ['netease:1']);
      expect(trackListDataSource.replacedKind, UserTrackListKind.cloud);
      expect(page.hasMore, isFalse);
      expect(page.nextOffset, 1);
      expect(page.items, hasLength(1));
      expect(page.items.single.mediaType, MediaType.local);
      expect(page.items.single.playbackUrl, '/cache/audio/cloud.mp3');
      expect(page.items.single.isCached, isTrue);
      expect(page.items.single.isLiked, isTrue);
    });
  });
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
    origin: TrackResourceOrigin.managedDownload,
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

class _FakeNeteaseCloudRemoteDataSource implements NeteaseCloudRemoteDataSource {
  _FakeNeteaseCloudRemoteDataSource({required this.tracks});

  final List<Track> tracks;
  int fetchCallCount = 0;

  @override
  Future<({int itemCount, List<Track> tracks})> fetchCloudSongs({
    required int offset,
    required int limit,
  }) async {
    fetchCallCount++;
    return (tracks: tracks, itemCount: tracks.length);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeUserTrackListDataSource implements UserTrackListDataSource {
  final List<String> loadedUserIds = [];
  final List<String> replacedUserIds = [];
  List<String> replacedTrackIds = [];
  UserTrackListKind? replacedKind;

  @override
  Future<List<String>> loadTrackIds(
    String userId,
    UserTrackListKind kind,
  ) async {
    loadedUserIds.add(userId);
    return const [];
  }

  @override
  Future<void> replaceTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds,
  ) async {
    replacedUserIds.add(userId);
    replacedKind = kind;
    replacedTrackIds = trackIds;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
