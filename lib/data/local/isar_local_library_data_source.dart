import 'package:bujuan/core/database/isar_album_entity.dart';
import 'package:bujuan/core/database/isar_artist_entity.dart';
import 'package:bujuan/core/database/isar_playlist_entity.dart';
import 'package:bujuan/core/database/isar_track_entity.dart';
import 'package:bujuan/core/database/isar_track_lyrics_entity.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:isar/isar.dart';

import 'local_library_codec.dart';
import 'local_library_data_source.dart';

class IsarLocalLibraryDataSource implements LocalLibraryDataSource {
  IsarLocalLibraryDataSource({required Isar isar}) : _isar = isar;

  final Isar _isar;

  @override
  Future<List<Track>> searchTracks(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final normalizedKeyword = keyword.toLowerCase();
    final entities = await _isar.isarTrackEntitys.where().findAll();
    return entities
        .map(LocalLibraryCodec.decodeTrackEntity)
        .where((track) {
          final artists = track.artistNames.join(' ').toLowerCase();
          return track.title.toLowerCase().contains(normalizedKeyword) ||
              artists.contains(normalizedKeyword) ||
              (track.albumTitle?.toLowerCase().contains(normalizedKeyword) ??
                  false);
        })
        .toList();
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String keyword) {
    if (keyword.isEmpty) {
      return Future.value(const []);
    }
    final normalizedKeyword = keyword.toLowerCase();
    return _isar.isarPlaylistEntitys.where().findAll().then(
          (entities) => entities
              .map(LocalLibraryCodec.decodePlaylistEntity)
              .where(
                (playlist) =>
                    playlist.title.toLowerCase().contains(normalizedKeyword),
              )
              .toList(),
        );
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) {
    if (keyword.isEmpty) {
      return Future.value(const []);
    }
    final normalizedKeyword = keyword.toLowerCase();
    return _isar.isarAlbumEntitys.where().findAll().then(
          (entities) => entities
              .map(LocalLibraryCodec.decodeAlbumEntity)
              .where((album) {
                final artists = album.artistNames.join(' ').toLowerCase();
                return album.title.toLowerCase().contains(normalizedKeyword) ||
                    artists.contains(normalizedKeyword);
              })
              .toList(),
        );
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) {
    if (keyword.isEmpty) {
      return Future.value(const []);
    }
    final normalizedKeyword = keyword.toLowerCase();
    return _isar.isarArtistEntitys.where().findAll().then(
          (entities) => entities
              .map(LocalLibraryCodec.decodeArtistEntity)
              .where(
                (artist) =>
                    artist.name.toLowerCase().contains(normalizedKeyword),
              )
              .toList(),
        );
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    final entity =
        await _isar.isarTrackEntitys.where().trackIdEqualTo(trackId).findFirst();
    if (entity == null) {
      return null;
    }
    return LocalLibraryCodec.decodeTrackEntity(entity);
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async {
    final entity = await _isar.isarTrackLyricsEntitys
        .where()
        .trackIdEqualTo(trackId)
        .findFirst();
    if (entity == null) {
      return null;
    }
    return LocalLibraryCodec.decodeLyricsEntity(entity);
  }

  @override
  Future<PlaylistEntity?> getPlaylist(String playlistId) {
    return _isar.isarPlaylistEntitys
        .where()
        .playlistIdEqualTo(playlistId)
        .findFirst()
        .then((entity) {
      if (entity == null) {
        return null;
      }
      return LocalLibraryCodec.decodePlaylistEntity(entity);
    });
  }

  @override
  Future<void> saveTracks(List<Track> tracks) async {
    final entities = tracks.map(LocalLibraryCodec.encodeTrackEntity).toList();
    await _isar.writeTxn(() async {
      await _isar.isarTrackEntitys.putAllByTrackId(entities);
    });
  }

  @override
  Future<void> savePlaylists(List<PlaylistEntity> playlists) {
    final entities =
        playlists.map(LocalLibraryCodec.encodePlaylistEntity).toList();
    return _isar.writeTxn(() async {
      await _isar.isarPlaylistEntitys.putAllByPlaylistId(entities);
    });
  }

  @override
  Future<void> saveAlbums(List<AlbumEntity> albums) {
    final entities = albums.map(LocalLibraryCodec.encodeAlbumEntity).toList();
    return _isar.writeTxn(() async {
      await _isar.isarAlbumEntitys.putAllByAlbumId(entities);
    });
  }

  @override
  Future<void> saveArtists(List<ArtistEntity> artists) {
    final entities = artists.map(LocalLibraryCodec.encodeArtistEntity).toList();
    return _isar.writeTxn(() async {
      await _isar.isarArtistEntitys.putAllByArtistId(entities);
    });
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {
    final entity = LocalLibraryCodec.encodeLyricsEntity(trackId, lyrics);
    await _isar.writeTxn(() async {
      await _isar.isarTrackLyricsEntitys.putByTrackId(entity);
    });
  }
}
