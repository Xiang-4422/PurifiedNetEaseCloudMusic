import 'dart:convert';

import 'package:bujuan/core/database/isar_album_entity.dart';
import 'package:bujuan/core/database/isar_artist_entity.dart';
import 'package:bujuan/core/database/isar_playlist_entity.dart';
import 'package:bujuan/core/database/isar_track_entity.dart';
import 'package:bujuan/core/database/isar_track_lyrics_entity.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/playlist_track_ref.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';

class LocalLibraryCodec {
  const LocalLibraryCodec._();

  static Map<String, Object?> encodeTrack(Track track) {
    return {
      'id': track.id,
      'sourceType': track.sourceType.name,
      'sourceId': track.sourceId,
      'title': track.title,
      'artistNames': track.artistNames,
      'albumTitle': track.albumTitle,
      'durationMs': track.durationMs,
      'artworkUrl': track.artworkUrl,
      'remoteUrl': track.remoteUrl,
      'localPath': track.localPath,
      'localArtworkPath': track.localArtworkPath,
      'localLyricsPath': track.localLyricsPath,
      'lyricKey': track.lyricKey,
      'availability': track.availability.name,
      'downloadState': track.downloadState.name,
      'resourceOrigin': track.resourceOrigin.name,
      'downloadProgress': track.downloadProgress,
      'downloadFailureReason': track.downloadFailureReason,
      'metadata': Map<String, Object?>.from(track.metadata),
    };
  }

  static Track? decodeTrack(Object? value) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }
    final artistNames = _asStringList(map['artistNames']);
    return Track(
      id: _readString(map, 'id'),
      sourceType: _sourceTypeFromName(map['sourceType'] as String?),
      sourceId: _readString(map, 'sourceId'),
      title: _readString(map, 'title'),
      artistNames: artistNames,
      albumTitle: map['albumTitle'] as String?,
      durationMs: (map['durationMs'] as num?)?.toInt(),
      artworkUrl: map['artworkUrl'] as String?,
      remoteUrl: map['remoteUrl'] as String?,
      localPath: map['localPath'] as String?,
      localArtworkPath: map['localArtworkPath'] as String?,
      localLyricsPath: map['localLyricsPath'] as String?,
      lyricKey: map['lyricKey'] as String?,
      availability: _availabilityFromName(map['availability'] as String?),
      downloadState: _downloadStateFromName(map['downloadState'] as String?),
      resourceOrigin: _resourceOriginFromName(map['resourceOrigin'] as String?),
      downloadProgress: (map['downloadProgress'] as num?)?.toDouble(),
      downloadFailureReason: map['downloadFailureReason'] as String?,
      metadata: _asObjectMap(map['metadata']),
    );
  }

  static IsarTrackEntity encodeTrackEntity(Track track) {
    return IsarTrackEntity(
      schemaVersion: 1,
      trackId: track.id,
      sourceType: track.sourceType.name,
      sourceId: track.sourceId,
      title: track.title,
      artistNames: track.artistNames,
      albumTitle: track.albumTitle,
      durationMs: track.durationMs,
      artworkUrl: track.artworkUrl,
      remoteUrl: track.remoteUrl,
      localPath: track.localPath,
      localArtworkPath: track.localArtworkPath,
      localLyricsPath: track.localLyricsPath,
      lyricKey: track.lyricKey,
      availability: track.availability.name,
      downloadState: track.downloadState.name,
      resourceOrigin: track.resourceOrigin.name,
      downloadProgress: track.downloadProgress,
      downloadFailureReason: track.downloadFailureReason,
      metadataJson: jsonEncode(track.metadata),
    );
  }

  static Track decodeTrackEntity(IsarTrackEntity entity) {
    final metadata = jsonDecode(entity.metadataJson);
    return Track(
      id: entity.trackId,
      sourceType: _sourceTypeFromName(entity.sourceType),
      sourceId: entity.sourceId,
      title: entity.title,
      artistNames: entity.artistNames,
      albumTitle: entity.albumTitle,
      durationMs: entity.durationMs,
      artworkUrl: entity.artworkUrl,
      remoteUrl: entity.remoteUrl,
      localPath: entity.localPath,
      localArtworkPath: entity.localArtworkPath,
      localLyricsPath: entity.localLyricsPath,
      lyricKey: entity.lyricKey,
      availability: _availabilityFromName(entity.availability),
      downloadState: _downloadStateFromName(entity.downloadState),
      resourceOrigin: _resourceOriginFromName(entity.resourceOrigin),
      downloadProgress: entity.downloadProgress,
      downloadFailureReason: entity.downloadFailureReason,
      metadata: metadata is Map
          ? Map<String, Object?>.from(
              metadata.map((key, value) => MapEntry('$key', value)),
            )
          : const {},
    );
  }

  static Map<String, Object?> encodePlaylist(PlaylistEntity playlist) {
    return {
      'id': playlist.id,
      'sourceType': playlist.sourceType.name,
      'sourceId': playlist.sourceId,
      'title': playlist.title,
      'description': playlist.description,
      'coverUrl': playlist.coverUrl,
      'trackCount': playlist.trackCount,
      'trackRefs': playlist.trackRefs
          .map(
            (trackRef) => {
              'trackId': trackRef.trackId,
              'order': trackRef.order,
              'addedAt': trackRef.addedAt,
            },
          )
          .toList(),
    };
  }

  static PlaylistEntity? decodePlaylist(Object? value) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }
    final rawTrackRefs = map['trackRefs'] as List?;
    return PlaylistEntity(
      id: _readString(map, 'id'),
      sourceType: _sourceTypeFromName(map['sourceType'] as String?),
      sourceId: _readString(map, 'sourceId'),
      title: _readString(map, 'title'),
      description: map['description'] as String?,
      coverUrl: map['coverUrl'] as String?,
      trackCount: (map['trackCount'] as num?)?.toInt(),
      trackRefs: rawTrackRefs == null
          ? const []
          : rawTrackRefs
              .map((item) => _asMap(item))
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => PlaylistTrackRef(
                  trackId: _readString(item, 'trackId'),
                  order: (item['order'] as num?)?.toInt() ?? 0,
                  addedAt: (item['addedAt'] as num?)?.toInt(),
                ),
              )
              .toList(),
    );
  }

  static IsarPlaylistEntity encodePlaylistEntity(PlaylistEntity playlist) {
    return IsarPlaylistEntity(
      schemaVersion: 1,
      playlistId: playlist.id,
      sourceType: playlist.sourceType.name,
      sourceId: playlist.sourceId,
      title: playlist.title,
      description: playlist.description,
      coverUrl: playlist.coverUrl,
      trackCount: playlist.trackCount,
      trackRefsJson: jsonEncode(
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
    );
  }

  static PlaylistEntity decodePlaylistEntity(IsarPlaylistEntity entity) {
    final rawTrackRefs = jsonDecode(entity.trackRefsJson);
    final refs = rawTrackRefs is List
        ? rawTrackRefs
            .map((item) => _asMap(item))
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => PlaylistTrackRef(
                trackId: _readString(item, 'trackId'),
                order: (item['order'] as num?)?.toInt() ?? 0,
                addedAt: (item['addedAt'] as num?)?.toInt(),
              ),
            )
            .toList()
        : const <PlaylistTrackRef>[];
    return PlaylistEntity(
      id: entity.playlistId,
      sourceType: _sourceTypeFromName(entity.sourceType),
      sourceId: entity.sourceId,
      title: entity.title,
      description: entity.description,
      coverUrl: entity.coverUrl,
      trackCount: entity.trackCount,
      trackRefs: refs,
    );
  }

  static Map<String, Object?> encodeAlbum(AlbumEntity album) {
    return {
      'id': album.id,
      'sourceType': album.sourceType.name,
      'sourceId': album.sourceId,
      'title': album.title,
      'artworkUrl': album.artworkUrl,
      'artistNames': album.artistNames,
      'description': album.description,
      'trackCount': album.trackCount,
      'publishTime': album.publishTime,
    };
  }

  static AlbumEntity? decodeAlbum(Object? value) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }
    return AlbumEntity(
      id: _readString(map, 'id'),
      sourceType: _sourceTypeFromName(map['sourceType'] as String?),
      sourceId: _readString(map, 'sourceId'),
      title: _readString(map, 'title'),
      artworkUrl: map['artworkUrl'] as String?,
      artistNames: _asStringList(map['artistNames']),
      description: map['description'] as String?,
      trackCount: (map['trackCount'] as num?)?.toInt(),
      publishTime: (map['publishTime'] as num?)?.toInt(),
    );
  }

  static IsarAlbumEntity encodeAlbumEntity(AlbumEntity album) {
    return IsarAlbumEntity(
      schemaVersion: 1,
      albumId: album.id,
      sourceType: album.sourceType.name,
      sourceId: album.sourceId,
      title: album.title,
      artworkUrl: album.artworkUrl,
      artistNames: album.artistNames,
      description: album.description,
      trackCount: album.trackCount,
      publishTime: album.publishTime,
    );
  }

  static AlbumEntity decodeAlbumEntity(IsarAlbumEntity entity) {
    return AlbumEntity(
      id: entity.albumId,
      sourceType: _sourceTypeFromName(entity.sourceType),
      sourceId: entity.sourceId,
      title: entity.title,
      artworkUrl: entity.artworkUrl,
      artistNames: entity.artistNames,
      description: entity.description,
      trackCount: entity.trackCount,
      publishTime: entity.publishTime,
    );
  }

  static Map<String, Object?> encodeArtist(ArtistEntity artist) {
    return {
      'id': artist.id,
      'sourceType': artist.sourceType.name,
      'sourceId': artist.sourceId,
      'name': artist.name,
      'artworkUrl': artist.artworkUrl,
      'description': artist.description,
    };
  }

  static ArtistEntity? decodeArtist(Object? value) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }
    return ArtistEntity(
      id: _readString(map, 'id'),
      sourceType: _sourceTypeFromName(map['sourceType'] as String?),
      sourceId: _readString(map, 'sourceId'),
      name: _readString(map, 'name'),
      artworkUrl: map['artworkUrl'] as String?,
      description: map['description'] as String?,
    );
  }

  static IsarArtistEntity encodeArtistEntity(ArtistEntity artist) {
    return IsarArtistEntity(
      schemaVersion: 1,
      artistId: artist.id,
      sourceType: artist.sourceType.name,
      sourceId: artist.sourceId,
      name: artist.name,
      artworkUrl: artist.artworkUrl,
      description: artist.description,
    );
  }

  static ArtistEntity decodeArtistEntity(IsarArtistEntity entity) {
    return ArtistEntity(
      id: entity.artistId,
      sourceType: _sourceTypeFromName(entity.sourceType),
      sourceId: entity.sourceId,
      name: entity.name,
      artworkUrl: entity.artworkUrl,
      description: entity.description,
    );
  }

  static Map<String, Object?> encodeLyrics(TrackLyrics lyrics) {
    return {
      'main': lyrics.main,
      'translated': lyrics.translated,
    };
  }

  static TrackLyrics? decodeLyrics(Object? value) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }
    return TrackLyrics(
      main: map['main'] as String? ?? '',
      translated: map['translated'] as String? ?? '',
    );
  }

  static IsarTrackLyricsEntity encodeLyricsEntity(
    String trackId,
    TrackLyrics lyrics,
  ) {
    return IsarTrackLyricsEntity(
      schemaVersion: 1,
      trackId: trackId,
      main: lyrics.main,
      translated: lyrics.translated,
    );
  }

  static TrackLyrics decodeLyricsEntity(IsarTrackLyricsEntity entity) {
    return TrackLyrics(
      main: entity.main,
      translated: entity.translated,
    );
  }

  static TrackAvailability _availabilityFromName(String? name) {
    return TrackAvailability.values.firstWhere(
      (item) => item.name == name,
      orElse: () => TrackAvailability.unknown,
    );
  }

  static DownloadState _downloadStateFromName(String? name) {
    return DownloadState.values.firstWhere(
      (item) => item.name == name,
      orElse: () => DownloadState.none,
    );
  }

  static TrackResourceOrigin _resourceOriginFromName(String? name) {
    return TrackResourceOrigin.values.firstWhere(
      (item) => item.name == name,
      orElse: () => TrackResourceOrigin.none,
    );
  }

  static SourceType _sourceTypeFromName(String? name) {
    return SourceType.values.firstWhere(
      (item) => item.name == name,
      orElse: () => SourceType.unknown,
    );
  }

  static List<String> _asStringList(Object? value) {
    final rawList = value as List?;
    if (rawList == null) {
      return const [];
    }
    return rawList.whereType<String>().toList();
  }

  static Map<String, Object?> _asObjectMap(Object? value) {
    final map = _asMap(value);
    if (map == null) {
      return const {};
    }
    return Map<String, Object?>.from(map);
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry('$key', value));
    }
    return null;
  }

  static String _readString(Map<String, dynamic> map, String key) {
    return map[key] as String? ?? '';
  }
}
