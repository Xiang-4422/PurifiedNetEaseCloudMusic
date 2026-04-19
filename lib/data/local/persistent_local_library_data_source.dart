import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';

import 'local_library_codec.dart';
import 'local_library_data_source.dart';

class PersistentLocalLibraryDataSource implements LocalLibraryDataSource {
  const PersistentLocalLibraryDataSource();

  static const String _tracksKey = 'LOCAL_LIBRARY_TRACKS';
  static const String _lyricsKey = 'LOCAL_LIBRARY_LYRICS';
  static const String _playlistsKey = 'LOCAL_LIBRARY_PLAYLISTS';
  static const String _albumsKey = 'LOCAL_LIBRARY_ALBUMS';
  static const String _artistsKey = 'LOCAL_LIBRARY_ARTISTS';

  @override
  Future<List<Track>> searchTracks(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final normalizedKeyword = keyword.toLowerCase();
    return _readBucket(_tracksKey)
        .values
        .map(LocalLibraryCodec.decodeTrack)
        .whereType<Track>()
        .where((track) {
      final artists = track.artistNames.join(' ').toLowerCase();
      return track.title.toLowerCase().contains(normalizedKeyword) ||
          artists.contains(normalizedKeyword) ||
          (track.albumTitle?.toLowerCase().contains(normalizedKeyword) ??
              false);
    }).toList();
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final normalizedKeyword = keyword.toLowerCase();
    return _readBucket(_playlistsKey)
        .values
        .map(LocalLibraryCodec.decodePlaylist)
        .whereType<PlaylistEntity>()
        .where(
          (playlist) =>
              playlist.title.toLowerCase().contains(normalizedKeyword),
        )
        .toList();
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final normalizedKeyword = keyword.toLowerCase();
    return _readBucket(_albumsKey)
        .values
        .map(LocalLibraryCodec.decodeAlbum)
        .whereType<AlbumEntity>()
        .where((album) {
      final artists = album.artistNames.join(' ').toLowerCase();
      return album.title.toLowerCase().contains(normalizedKeyword) ||
          artists.contains(normalizedKeyword);
    }).toList();
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final normalizedKeyword = keyword.toLowerCase();
    return _readBucket(_artistsKey)
        .values
        .map(LocalLibraryCodec.decodeArtist)
        .whereType<ArtistEntity>()
        .where(
          (artist) => artist.name.toLowerCase().contains(normalizedKeyword),
        )
        .toList();
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    return LocalLibraryCodec.decodeTrack(_readBucket(_tracksKey)[trackId]);
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async {
    return LocalLibraryCodec.decodeLyrics(_readBucket(_lyricsKey)[trackId]);
  }

  @override
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    return LocalLibraryCodec.decodePlaylist(
      _readBucket(_playlistsKey)[playlistId],
    );
  }

  @override
  Future<void> saveTracks(List<Track> tracks) async {
    final bucket = _readBucket(_tracksKey);
    for (final track in tracks) {
      bucket[track.id] = LocalLibraryCodec.encodeTrack(track);
    }
    await _writeBucket(_tracksKey, bucket);
  }

  @override
  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {
    final bucket = _readBucket(_playlistsKey);
    for (final playlist in playlists) {
      bucket[playlist.id] = LocalLibraryCodec.encodePlaylist(playlist);
    }
    await _writeBucket(_playlistsKey, bucket);
  }

  @override
  Future<void> saveAlbums(List<AlbumEntity> albums) async {
    final bucket = _readBucket(_albumsKey);
    for (final album in albums) {
      bucket[album.id] = LocalLibraryCodec.encodeAlbum(album);
    }
    await _writeBucket(_albumsKey, bucket);
  }

  @override
  Future<void> saveArtists(List<ArtistEntity> artists) async {
    final bucket = _readBucket(_artistsKey);
    for (final artist in artists) {
      bucket[artist.id] = LocalLibraryCodec.encodeArtist(artist);
    }
    await _writeBucket(_artistsKey, bucket);
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {
    final bucket = _readBucket(_lyricsKey);
    bucket[trackId] = LocalLibraryCodec.encodeLyrics(lyrics);
    await _writeBucket(_lyricsKey, bucket);
  }

  Map<String, dynamic> _readBucket(String key) {
    final storedValue = CacheBox.instance.get(key);
    if (storedValue is Map) {
      return storedValue.map((key, value) => MapEntry('$key', value));
    }
    return <String, dynamic>{};
  }

  Future<void> _writeBucket(String key, Map<String, dynamic> bucket) {
    return CacheBox.instance.put(key, bucket);
  }
}
