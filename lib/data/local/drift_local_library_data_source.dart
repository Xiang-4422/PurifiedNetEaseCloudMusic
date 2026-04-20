import 'dart:convert';

import 'package:bujuan/core/database/drift_database.dart' as db;
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/playlist_track_ref.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:drift/drift.dart' as drift;

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
        .map(_mapTrackRow)
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
    return rows.map(_mapPlaylistRow).toList();
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
    return rows.map(_mapAlbumRow).toList();
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final rows = await (_database.select(_database.artists)
          ..where((tbl) => tbl.name.like('%$keyword%')))
        .get();
    return rows.map(_mapArtistRow).toList();
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    final row = await (_database.select(_database.tracks)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapTrackRow(row);
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
    return _mapPlaylistRow(row);
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
                sourceType: drift.Value(track.sourceType.name),
                sourceId: drift.Value(track.sourceId),
                title: drift.Value(track.title),
                artistSearchText: drift.Value(track.artistNames.join(' ')),
                artistNamesJson: drift.Value(jsonEncode(track.artistNames)),
                albumTitle: drift.Value(track.albumTitle),
                durationMs: drift.Value(track.durationMs),
                artworkUrl: drift.Value(track.artworkUrl),
                remoteUrl: drift.Value(track.remoteUrl),
                localPath: drift.Value(track.localPath),
                localArtworkPath: drift.Value(track.localArtworkPath),
                localLyricsPath: drift.Value(track.localLyricsPath),
                lyricKey: drift.Value(track.lyricKey),
                availability: drift.Value(track.availability.name),
                downloadState: drift.Value(track.downloadState.name),
                resourceOrigin: drift.Value(track.resourceOrigin.name),
                downloadProgress: drift.Value(track.downloadProgress),
                downloadFailureReason:
                    drift.Value(track.downloadFailureReason),
                metadataJson: drift.Value(jsonEncode(track.metadata)),
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
                sourceType: drift.Value(playlist.sourceType.name),
                sourceId: drift.Value(playlist.sourceId),
                title: drift.Value(playlist.title),
                description: drift.Value(playlist.description),
                coverUrl: drift.Value(playlist.coverUrl),
                trackCount: drift.Value(playlist.trackCount),
                trackRefsJson: drift.Value(
                  jsonEncode(
                    playlist.trackRefs
                        .map(
                          (trackRef) => {
                            'trackId': trackRef.trackId,
                            'order': trackRef.order,
                            'addedAt': trackRef.addedAt,
                          },
                        )
                        .toList(),
                  ),
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

  @override
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

  PlaylistEntity _mapPlaylistRow(db.Playlist row) {
    final rawTrackRefs =
        (jsonDecode(row.trackRefsJson) as List?) ?? const <Object?>[];
    final trackRefs = rawTrackRefs
        .map((item) => item is Map ? Map<String, dynamic>.from(item) : null)
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => PlaylistTrackRef(
            trackId: item['trackId'] as String? ?? '',
            order: (item['order'] as num?)?.toInt() ?? 0,
            addedAt: (item['addedAt'] as num?)?.toInt(),
          ),
        )
        .toList();
    return PlaylistEntity(
      id: row.playlistId,
      sourceType: SourceType.values.firstWhere(
        (item) => item.name == row.sourceType,
        orElse: () => SourceType.unknown,
      ),
      sourceId: row.sourceId,
      title: row.title,
      description: row.description,
      coverUrl: row.coverUrl,
      trackCount: row.trackCount,
      trackRefs: trackRefs,
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
      localPath: row.localPath,
      localArtworkPath: row.localArtworkPath,
      localLyricsPath: row.localLyricsPath,
      lyricKey: row.lyricKey,
      availability: TrackAvailability.values.firstWhere(
        (item) => item.name == row.availability,
        orElse: () => TrackAvailability.unknown,
      ),
      downloadState: DownloadState.values.firstWhere(
        (item) => item.name == row.downloadState,
        orElse: () => DownloadState.none,
      ),
      resourceOrigin: TrackResourceOrigin.values.firstWhere(
        (item) => item.name == row.resourceOrigin,
        orElse: () => TrackResourceOrigin.none,
      ),
      downloadProgress: row.downloadProgress,
      downloadFailureReason: row.downloadFailureReason,
      metadata: metadata,
    );
  }
}
