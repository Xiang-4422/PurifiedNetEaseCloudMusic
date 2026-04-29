import 'dart:convert';

import 'package:bujuan/core/database/drift_database.dart' as db;
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:drift/drift.dart' as drift;

class TrackDao {
  TrackDao({required db.BujuanDriftDatabase database}) : _database = database;

  final db.BujuanDriftDatabase _database;

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
    return rows.map(_mapTrackRow).toList();
  }

  Future<Track?> getTrack(String trackId) async {
    final row = await (_database.select(_database.tracks)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapTrackRow(row);
  }

  Future<List<Track>> getTracksByIds(Iterable<String> trackIds) async {
    final ids = trackIds.toSet().toList();
    if (ids.isEmpty) {
      return const [];
    }
    final rows = await (_database.select(_database.tracks)
          ..where((tbl) => tbl.trackId.isIn(ids)))
        .get();
    return rows.map(_mapTrackRow).toList();
  }

  Future<List<Track>> getTracksByAlbumId(String albumSourceId) async {
    final rows = await _database.select(_database.tracks).get();
    return rows
        .map(_mapTrackRow)
        .where((track) => '${track.metadata['albumId'] ?? ''}' == albumSourceId)
        .toList();
  }

  Future<List<Track>> getTracksByArtistId(String artistSourceId) async {
    final rows = await _database.select(_database.tracks).get();
    return rows.map(_mapTrackRow).where((track) {
      final artistIds = (track.metadata['artistIds'] as List? ?? const [])
          .map((item) => '$item')
          .toList();
      return artistIds.contains(artistSourceId);
    }).toList();
  }

  Future<void> saveTracks(List<Track> tracks) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.tracks,
        tracks
            .map(
              (track) => db.TracksCompanion(
                trackId: drift.Value(track.id),
                sourceType: drift.Value(track.sourceType.name),
                sourceId: drift.Value(track.sourceId),
                title: drift.Value(track.title),
                artistSearchText: drift.Value(track.artistNames.join(' ')),
                artistNamesJson: drift.Value(jsonEncode(track.artistNames)),
                albumTitle: drift.Value(track.albumTitle),
                durationMs: drift.Value(track.durationMs),
                artworkUrl: drift.Value(track.artworkUrl),
                remoteUrl: drift.Value(track.remoteUrl),
                lyricKey: drift.Value(track.lyricKey),
                availability: drift.Value(track.availability.name),
                metadataJson: drift.Value(jsonEncode(track.metadata)),
              ),
            )
            .toList(),
      );
    });
  }

  Future<TrackLyrics?> getLyrics(String trackId) async {
    final row = await (_database.select(_database.trackLyricsEntries)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return TrackLyrics(main: row.main, translated: row.translated);
  }

  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) {
    return _database.into(_database.trackLyricsEntries).insertOnConflictUpdate(
          db.TrackLyricsEntriesCompanion(
            trackId: drift.Value(trackId),
            main: drift.Value(lyrics.main),
            translated: drift.Value(lyrics.translated),
          ),
        );
  }

  Future<void> removeTrack(String trackId) {
    return (_database.delete(_database.tracks)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .go();
  }

  Future<void> removeLyrics(String trackId) {
    return (_database.delete(_database.trackLyricsEntries)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .go();
  }

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
    return rows.map(_mapAlbumRow).toList();
  }

  Future<AlbumEntity?> getAlbum(String albumId) async {
    final row = await (_database.select(_database.albums)
          ..where((tbl) => tbl.albumId.equals(albumId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapAlbumRow(row);
  }

  Future<void> saveAlbums(List<AlbumEntity> albums) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.albums,
        albums
            .map(
              (album) => db.AlbumsCompanion(
                albumId: drift.Value(album.id),
                sourceType: drift.Value(album.sourceType.name),
                sourceId: drift.Value(album.sourceId),
                title: drift.Value(album.title),
                artistSearchText: drift.Value(album.artistNames.join(' ')),
                artistNamesJson: drift.Value(jsonEncode(album.artistNames)),
                artworkUrl: drift.Value(album.artworkUrl),
                description: drift.Value(album.description),
                trackCount: drift.Value(album.trackCount),
                publishTime: drift.Value(album.publishTime),
              ),
            )
            .toList(),
      );
    });
  }

  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final rows = await (_database.select(_database.artists)
          ..where((tbl) => tbl.name.like('%$keyword%')))
        .get();
    return rows.map(_mapArtistRow).toList();
  }

  Future<ArtistEntity?> getArtist(String artistId) async {
    final row = await (_database.select(_database.artists)
          ..where((tbl) => tbl.artistId.equals(artistId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapArtistRow(row);
  }

  Future<void> saveArtists(List<ArtistEntity> artists) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.artists,
        artists
            .map(
              (artist) => db.ArtistsCompanion(
                artistId: drift.Value(artist.id),
                sourceType: drift.Value(artist.sourceType.name),
                sourceId: drift.Value(artist.sourceId),
                name: drift.Value(artist.name),
                artworkUrl: drift.Value(artist.artworkUrl),
                description: drift.Value(artist.description),
              ),
            )
            .toList(),
      );
    });
  }

  Track _mapTrackRow(db.Track row) {
    final artistNames =
        (jsonDecode(row.artistNamesJson) as List?)?.cast<String>() ??
            const <String>[];
    final metadataDecoded = jsonDecode(row.metadataJson);
    final metadata = metadataDecoded is Map
        ? Map<String, Object?>.from(
            metadataDecoded.map((key, value) => MapEntry('$key', value)),
          )
        : const <String, Object?>{};
    return Track(
      id: row.trackId,
      sourceType: SourceType.values.firstWhere(
        (item) => item.name == row.sourceType,
        orElse: () => SourceType.unknown,
      ),
      sourceId: row.sourceId,
      title: row.title,
      artistNames: artistNames,
      albumTitle: row.albumTitle,
      durationMs: row.durationMs,
      artworkUrl: row.artworkUrl,
      remoteUrl: row.remoteUrl,
      lyricKey: row.lyricKey,
      availability: TrackAvailability.values.firstWhere(
        (item) => item.name == row.availability,
        orElse: () => TrackAvailability.unknown,
      ),
      metadata: metadata,
    );
  }

  AlbumEntity _mapAlbumRow(db.Album row) {
    final artistNames =
        (jsonDecode(row.artistNamesJson) as List?)?.cast<String>() ??
            const <String>[];
    return AlbumEntity(
      id: row.albumId,
      sourceType: SourceType.values.firstWhere(
        (item) => item.name == row.sourceType,
        orElse: () => SourceType.unknown,
      ),
      sourceId: row.sourceId,
      title: row.title,
      artworkUrl: row.artworkUrl,
      artistNames: artistNames,
      description: row.description,
      trackCount: row.trackCount,
      publishTime: row.publishTime,
    );
  }

  ArtistEntity _mapArtistRow(db.Artist row) {
    return ArtistEntity(
      id: row.artistId,
      sourceType: SourceType.values.firstWhere(
        (item) => item.name == row.sourceType,
        orElse: () => SourceType.unknown,
      ),
      sourceId: row.sourceId,
      name: row.name,
      artworkUrl: row.artworkUrl,
      description: row.description,
    );
  }
}
