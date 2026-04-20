import 'dart:convert';

import 'package:bujuan/core/database/drift_database.dart' as db;
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:drift/drift.dart' as drift;

import 'local_library_codec.dart';
import 'local_library_data_source.dart';

class DriftLocalLibraryDataSource implements LocalLibraryDataSource {
  DriftLocalLibraryDataSource({required db.BujuanDriftDatabase database})
      : _database = database;

  final db.BujuanDriftDatabase _database;

  @override
  Future<List<Track>> searchTracks(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final likeKeyword = '%$keyword%';
    final rows = await (_database.select(_database.tracks)
          ..where(
            (tbl) =>
                tbl.title.like(likeKeyword) |
                tbl.artistSearchText.like(likeKeyword) |
                (tbl.albumTitle.isNotNull() & tbl.albumTitle.like(likeKeyword)),
          ))
        .get();
    return rows
        .map((row) => LocalLibraryCodec.decodeTrack(_decodePayload(row.payloadJson)))
        .whereType<Track>()
        .toList();
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final rows = await (_database.select(_database.playlists)
          ..where((tbl) => tbl.title.like('%$keyword%')))
        .get();
    return rows
        .map(
          (row) =>
              LocalLibraryCodec.decodePlaylist(_decodePayload(row.payloadJson)),
        )
        .whereType<PlaylistEntity>()
        .toList();
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final likeKeyword = '%$keyword%';
    final rows = await (_database.select(_database.albums)
          ..where(
            (tbl) =>
                tbl.title.like(likeKeyword) |
                tbl.artistSearchText.like(likeKeyword),
          ))
        .get();
    return rows
        .map((row) => LocalLibraryCodec.decodeAlbum(_decodePayload(row.payloadJson)))
        .whereType<AlbumEntity>()
        .toList();
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final rows = await (_database.select(_database.artists)
          ..where((tbl) => tbl.name.like('%$keyword%')))
        .get();
    return rows
        .map((row) => LocalLibraryCodec.decodeArtist(_decodePayload(row.payloadJson)))
        .whereType<ArtistEntity>()
        .toList();
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    final row = await (_database.select(_database.tracks)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return LocalLibraryCodec.decodeTrack(_decodePayload(row.payloadJson));
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async {
    final row = await (_database.select(_database.trackLyricsEntries)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return TrackLyrics(main: row.main, translated: row.translated);
  }

  @override
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    final row = await (_database.select(_database.playlists)
          ..where((tbl) => tbl.playlistId.equals(playlistId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return LocalLibraryCodec.decodePlaylist(_decodePayload(row.payloadJson));
  }

  @override
  Future<void> saveTracks(List<Track> tracks) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.tracks,
        tracks
            .map(
              (track) => db.TracksCompanion(
                trackId: drift.Value(track.id),
                title: drift.Value(track.title),
                artistSearchText: drift.Value(track.artistNames.join(' ')),
                albumTitle: drift.Value(track.albumTitle),
                payloadJson: drift.Value(
                  jsonEncode(LocalLibraryCodec.encodeTrack(track)),
                ),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.playlists,
        playlists
            .map(
              (playlist) => db.PlaylistsCompanion(
                playlistId: drift.Value(playlist.id),
                title: drift.Value(playlist.title),
                payloadJson: drift.Value(
                  jsonEncode(LocalLibraryCodec.encodePlaylist(playlist)),
                ),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> saveAlbums(List<AlbumEntity> albums) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.albums,
        albums
            .map(
              (album) => db.AlbumsCompanion(
                albumId: drift.Value(album.id),
                title: drift.Value(album.title),
                artistSearchText: drift.Value(album.artistNames.join(' ')),
                payloadJson: drift.Value(
                  jsonEncode(LocalLibraryCodec.encodeAlbum(album)),
                ),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> saveArtists(List<ArtistEntity> artists) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.artists,
        artists
            .map(
              (artist) => db.ArtistsCompanion(
                artistId: drift.Value(artist.id),
                name: drift.Value(artist.name),
                payloadJson: drift.Value(
                  jsonEncode(LocalLibraryCodec.encodeArtist(artist)),
                ),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) {
    return _database.into(_database.trackLyricsEntries).insertOnConflictUpdate(
          db.TrackLyricsEntriesCompanion(
            trackId: drift.Value(trackId),
            main: drift.Value(lyrics.main),
            translated: drift.Value(lyrics.translated),
          ),
        );
  }

  Map<String, Object?> _decodePayload(String payloadJson) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is Map) {
      return Map<String, Object?>.from(
        decoded.map((key, value) => MapEntry('$key', value)),
      );
    }
    return const {};
  }
}
