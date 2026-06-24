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
      expect(musicDataRepository.awaitArtworkPrecacheValues, [false]);
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

    test('normalizes artist id for local detail queries', () async {
      final musicDataRepository = _FakeMusicDataRepository(
        resourcesByTrackId: const {},
        artistsById: {
          'netease:artist-1': _artist('netease:artist-1'),
        },
        tracksByArtistSourceId: {
          'artist-1': [_track('netease:1')],
        },
        localAlbums: [_album('netease:album-1')],
      );
      final repository = ArtistRepository(
        musicDataRepository: musicDataRepository,
        remoteDataSource: _FakeNeteaseArtistRemoteDataSource(
          artist: null,
          topTracks: const [],
          hotAlbums: const [],
        ),
      );

      final detail = await repository.loadLocalArtistDetail(
        artistId: ' netease:artist-1 ',
        likedSongIds: const [],
      );

      expect(detail?.artist.id, 'netease:artist-1');
      expect(musicDataRepository.requestedArtistIds, ['netease:artist-1']);
      expect(musicDataRepository.requestedArtistTrackSourceIds, ['artist-1']);
      expect(musicDataRepository.requestedResourceIds, ['netease:1']);
    });

    test('normalizes artist id before remote detail fetch', () async {
      final remoteDataSource = _FakeNeteaseArtistRemoteDataSource(
        artist: _artist('netease:artist-1'),
        topTracks: const [],
        hotAlbums: const [],
      );
      final repository = ArtistRepository(
        musicDataRepository: _FakeMusicDataRepository(
          resourcesByTrackId: const {},
        ),
        remoteDataSource: remoteDataSource,
      );

      await repository.fetchArtistDetail(
        artistId: ' netease:artist-1 ',
        likedSongIds: const [],
      );

      expect(remoteDataSource.requestedArtistIds, ['artist-1']);
    });

    test('rejects blank artist id before remote detail fetch', () async {
      final remoteDataSource = _FakeNeteaseArtistRemoteDataSource(
        artist: _artist('netease:artist-1'),
        topTracks: const [],
        hotAlbums: const [],
      );
      final repository = ArtistRepository(
        musicDataRepository: _FakeMusicDataRepository(
          resourcesByTrackId: const {},
        ),
        remoteDataSource: remoteDataSource,
      );

      await expectLater(
        repository.fetchArtistDetail(
          artistId: ' local:artist-1 ',
          likedSongIds: const [],
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(remoteDataSource.requestedArtistIds, isEmpty);
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
  _FakeMusicDataRepository({
    required this.resourcesByTrackId,
    this.artistsById = const {},
    this.tracksByArtistSourceId = const {},
    this.localAlbums = const [],
  });

  final Map<String, TrackResourceBundle> resourcesByTrackId;
  final Map<String, ArtistEntity> artistsById;
  final Map<String, List<Track>> tracksByArtistSourceId;
  final List<AlbumEntity> localAlbums;
  final List<String> savedArtistIds = [];
  final List<String> savedAlbumIds = [];
  final List<String> savedTrackIds = [];
  final List<bool> awaitArtworkPrecacheValues = [];
  final List<String> requestedArtistIds = [];
  final List<String> requestedArtistTrackSourceIds = [];
  final List<String> requestedResourceIds = [];

  @override
  Future<ArtistEntity?> getArtist(String artistId) async {
    requestedArtistIds.add(artistId);
    return artistsById[artistId];
  }

  @override
  Future<List<Track>> getTracksByArtistId(String artistSourceId) async {
    requestedArtistTrackSourceIds.add(artistSourceId);
    return tracksByArtistSourceId[artistSourceId] ?? const [];
  }

  @override
  Future<List<AlbumEntity>> searchLocalAlbums(String keyword) async {
    return localAlbums;
  }

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
    bool awaitArtworkPrecache = true,
  }) async {
    savedTrackIds.addAll(tracks.map((track) => track.id));
    awaitArtworkPrecacheValues.add(awaitArtworkPrecache);
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
  final List<String> requestedArtistIds = [];

  @override
  Future<
      ({
        ArtistEntity? artist,
        List<Track> topTracks,
        List<AlbumEntity> hotAlbums,
      })> fetchArtistDetail({
    required String artistId,
  }) async {
    requestedArtistIds.add(artistId);
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
