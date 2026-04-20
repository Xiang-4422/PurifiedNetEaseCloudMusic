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
  IsarLocalLibraryDataSource({
    required Isar isar,
    required LocalLibraryDataSource fallbackDataSource,
  })  : _isar = isar,
        _fallbackDataSource = fallbackDataSource;

  final Isar _isar;
  final LocalLibraryDataSource _fallbackDataSource;

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
    return _fallbackDataSource.searchPlaylists(keyword);
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) {
    return _fallbackDataSource.searchAlbums(keyword);
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) {
    return _fallbackDataSource.searchArtists(keyword);
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
    return _fallbackDataSource.getPlaylist(playlistId);
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
    return _fallbackDataSource.savePlaylists(playlists);
  }

  @override
  Future<void> saveAlbums(List<AlbumEntity> albums) {
    return _fallbackDataSource.saveAlbums(albums);
  }

  @override
  Future<void> saveArtists(List<ArtistEntity> artists) {
    return _fallbackDataSource.saveArtists(artists);
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {
    final entity = LocalLibraryCodec.encodeLyricsEntity(trackId, lyrics);
    await _isar.writeTxn(() async {
      await _isar.isarTrackLyricsEntitys.putByTrackId(entity);
    });
  }
}
