import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_album_remote_data_source.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlbumRepository', () {
    test('builds remote album songs from saved local resources', () async {
      final remoteDataSource = _FakeNeteaseAlbumRemoteDataSource(
        album: _album('netease:album-1'),
        tracks: [_track('netease:1')],
      );
      final musicDataRepository = _FakeMusicDataRepository(
        resourcesByTrackId: {
          'netease:1': TrackResourceBundle(
            audio: _audioResource(
              trackId: 'netease:1',
              path: '/cache/audio/album-1.mp3',
            ),
          ),
        },
      );
      final repository = AlbumRepository(
        musicDataRepository: musicDataRepository,
        remoteDataSource: remoteDataSource,
      );

      final detail = await repository.fetchAlbumDetail(
        albumId: 'album-1',
        likedSongIds: const [1],
      );

      expect(musicDataRepository.savedAlbumIds, ['netease:album-1']);
      expect(musicDataRepository.savedTrackIds, ['netease:1']);
      expect(musicDataRepository.requestedResourceIds, ['netease:1']);
      expect(detail.album.id, 'netease:album-1');
      expect(detail.albumSongs, hasLength(1));
      expect(detail.albumSongs.single.mediaType, MediaType.local);
      expect(detail.albumSongs.single.playbackUrl, '/cache/audio/album-1.mp3');
      expect(detail.albumSongs.single.isCached, isTrue);
      expect(detail.albumSongs.single.isLiked, isTrue);
    });
  });
}

AlbumEntity _album(String id) {
  return AlbumEntity(
    id: id,
    sourceType: SourceType.netease,
    sourceId: id.split(':').last,
    title: 'Album $id',
    artistNames: const ['Artist'],
  );
}

Track _track(String id) {
  return Track(
    id: id,
    sourceType: SourceType.netease,
    sourceId: id.split(':').last,
    title: 'Track $id',
    artistNames: const ['Artist'],
    albumId: 'album-1',
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
  final List<String> savedAlbumIds = [];
  final List<String> savedTrackIds = [];
  final List<String> requestedResourceIds = [];

  @override
  Future<void> saveAlbums(List<AlbumEntity> albums) async {
    savedAlbumIds.addAll(albums.map((album) => album.id));
  }

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

class _FakeNeteaseAlbumRemoteDataSource implements NeteaseAlbumRemoteDataSource {
  _FakeNeteaseAlbumRemoteDataSource({
    required this.album,
    required this.tracks,
  });

  final AlbumEntity? album;
  final List<Track> tracks;

  @override
  Future<({AlbumEntity? album, List<Track> tracks})> fetchAlbumDetail({
    required String albumId,
  }) async {
    return (album: album, tracks: tracks);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
