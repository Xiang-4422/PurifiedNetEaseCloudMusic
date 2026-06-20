import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_artist_remote_data_source.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArtistRepository', () {
    test('builds remote top songs from saved local resources', () async {
      final remoteDataSource = _FakeNeteaseArtistRemoteDataSource(
        artist: _artist('netease:artist-1'),
        topTracks: [_track('netease:1')],
        hotAlbums: [_album('netease:album-1')],
      );
      final musicDataRepository = _FakeMusicDataRepository(
        resourcesByTrackId: {
          'netease:1': TrackResourceBundle(
            audio: _audioResource(
              trackId: 'netease:1',
              path: '/cache/audio/artist-1.mp3',
            ),
          ),
        },
      );
      final repository = ArtistRepository(
        musicDataRepository: musicDataRepository,
        remoteDataSource: remoteDataSource,
      );

      final detail = await repository.fetchArtistDetail(
        artistId: 'artist-1',
        likedSongIds: const [1],
      );

      expect(musicDataRepository.savedArtistIds, ['netease:artist-1']);
      expect(musicDataRepository.savedTrackIds, ['netease:1']);
      expect(musicDataRepository.savedAlbumIds, ['netease:album-1']);
      expect(musicDataRepository.requestedResourceIds, ['netease:1']);
      expect(detail.artist.id, 'netease:artist-1');
      expect(detail.topSongs, hasLength(1));
      expect(detail.topSongs.single.mediaType, MediaType.local);
      expect(detail.topSongs.single.playbackUrl, '/cache/audio/artist-1.mp3');
      expect(detail.topSongs.single.isCached, isTrue);
      expect(detail.topSongs.single.isLiked, isTrue);
      expect(detail.hotAlbums.single.id, 'netease:album-1');
    });
  });
}

ArtistEntity _artist(String id) {
  return ArtistEntity(
    id: id,
    sourceType: SourceType.netease,
    sourceId: id.split(':').last,
    name: 'Artist',
  );
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
    artistIds: const ['artist-1'],
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
  final List<String> savedArtistIds = [];
  final List<String> savedAlbumIds = [];
  final List<String> savedTrackIds = [];
  final List<String> requestedResourceIds = [];

  @override
  Future<void> saveArtists(List<ArtistEntity> artists) async {
    savedArtistIds.addAll(artists.map((artist) => artist.id));
  }

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

class _FakeNeteaseArtistRemoteDataSource implements NeteaseArtistRemoteDataSource {
  _FakeNeteaseArtistRemoteDataSource({
    required this.artist,
    required this.topTracks,
    required this.hotAlbums,
  });

  final ArtistEntity? artist;
  final List<Track> topTracks;
  final List<AlbumEntity> hotAlbums;

  @override
  Future<
      ({
        ArtistEntity? artist,
        List<Track> topTracks,
        List<AlbumEntity> hotAlbums,
      })> fetchArtistDetail({
    required String artistId,
  }) async {
    return (
      artist: artist,
      topTracks: topTracks,
      hotAlbums: hotAlbums,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
