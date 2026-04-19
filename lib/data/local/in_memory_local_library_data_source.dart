import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/features/playback/playback_restore_state.dart';

import 'local_library_data_source.dart';

class InMemoryLocalLibraryDataSource implements LocalLibraryDataSource {
  InMemoryLocalLibraryDataSource._();

  // 过渡期 repository 还会在多个位置直接 new，自带共享实例能先把
  // “本地优先”语义跑通，避免接入正式数据库前每条链路都读到各自孤岛缓存。
  static final InMemoryLocalLibraryDataSource shared =
      InMemoryLocalLibraryDataSource._();

  final Map<String, Track> _tracks = {};
  final Map<String, TrackLyrics> _lyrics = {};
  final Map<String, PlaylistEntity> _playlists = {};
  final Map<String, AlbumEntity> _albums = {};
  final Map<String, ArtistEntity> _artists = {};
  PlaybackRestoreState? _playbackRestoreState;

  @override
  Future<List<Track>> searchTracks(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final normalizedKeyword = keyword.toLowerCase();
    return _tracks.values.where((track) {
      final artist = track.artistNames.join(' ').toLowerCase();
      return track.title.toLowerCase().contains(normalizedKeyword) ||
          artist.contains(normalizedKeyword) ||
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
    return _playlists.values
        .where((playlist) => playlist.title.toLowerCase().contains(
              normalizedKeyword,
            ))
        .toList();
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    if (keyword.isEmpty) {
      return const [];
    }
    final normalizedKeyword = keyword.toLowerCase();
    return _albums.values.where((album) {
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
    return _artists.values
        .where((artist) => artist.name.toLowerCase().contains(
              normalizedKeyword,
            ))
        .toList();
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    return _tracks[trackId];
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async {
    return _lyrics[trackId];
  }

  @override
  Future<PlaybackRestoreState?> getPlaybackRestoreState() async {
    return _playbackRestoreState;
  }

  @override
  Future<PlaylistEntity?> getPlaylist(String playlistId) async {
    return _playlists[playlistId];
  }

  @override
  Future<void> saveTracks(List<Track> tracks) async {
    for (final track in tracks) {
      _tracks[track.id] = track;
    }
  }

  @override
  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {
    for (final playlist in playlists) {
      _playlists[playlist.id] = playlist;
    }
  }

  @override
  Future<void> saveAlbums(List<AlbumEntity> albums) async {
    for (final album in albums) {
      _albums[album.id] = album;
    }
  }

  @override
  Future<void> saveArtists(List<ArtistEntity> artists) async {
    for (final artist in artists) {
      _artists[artist.id] = artist;
    }
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {
    _lyrics[trackId] = lyrics;
  }

  @override
  Future<void> savePlaybackRestoreState(PlaybackRestoreState state) async {
    _playbackRestoreState = state;
  }
}
