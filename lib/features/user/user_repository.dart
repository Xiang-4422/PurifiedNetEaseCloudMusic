import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_media_item_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';
import 'package:bujuan/features/user/user_profile_data.dart';
import 'package:bujuan/features/user/user_session_data.dart';
import 'package:get_it/get_it.dart';

class UserRepository {
  UserRepository({LibraryRepository? libraryRepository})
      : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository());

  final LibraryRepository _libraryRepository;

  Future<UserSessionData> fetchLoginSession() async {
    final accountInfo = await NeteaseMusicApi().loginAccountInfo();
    final profile = accountInfo.profile;
    return UserSessionData(
      userId: profile?.userId ?? '',
      nickname: profile?.nickname ?? '',
      avatarUrl: profile?.avatarUrl ?? '',
    );
  }

  Future<UserProfileData> fetchUserDetail(String userId) async {
    final detail = await NeteaseMusicApi().userDetail(userId);
    final profile = detail.profile;
    return UserProfileData(
      userId: profile.userId,
      nickname: profile.nickname ?? '',
      signature: profile.signature ?? '',
      follows: profile.follows ?? 0,
      followeds: profile.followeds ?? 0,
      playlistCount: profile.playlistCount ?? 0,
      avatarUrl: profile.avatarUrl ?? '',
    );
  }

  Future<List<int>> fetchLikedSongIds(String userId) async {
    final likedList = await NeteaseMusicApi().likeSongList(userId);
    return likedList.ids;
  }

  Future<List<PlaylistSummaryData>> fetchRecommendedPlaylists({
    required int offset,
    int limit = 10,
  }) async {
    final wrap = await NeteaseMusicApi()
        .personalizedPlaylist(offset: offset, limit: limit);
    final playlists = NeteasePlaylistMapper.fromPlaylistList(
      wrap.result ?? const [],
    );
    await _libraryRepository.savePlaylists(
      playlists,
    );
    return playlists.map(PlaylistSummaryData.fromEntity).toList();
  }

  Future<List<PlaylistSummaryData>> fetchUserPlaylists(String userId) async {
    final wrap = await NeteaseMusicApi().userPlayLists(userId);
    final playlists = NeteasePlaylistMapper.fromPlaylistList(
      wrap.playlists ?? const [],
    );
    await _libraryRepository.savePlaylists(
      playlists,
    );
    return playlists.map(PlaylistSummaryData.fromEntity).toList();
  }

  Future<List<MediaItem>> fetchTodayRecommendSongs({
    required List<int> likedSongIds,
  }) async {
    final wrap = await NeteaseMusicApi().recommendSongList();
    if (wrap.code != 200) {
      return const [];
    }
    final tracks = NeteaseTrackMapper.fromSong2List(
      wrap.data.dailySongs ?? const [],
    );
    await _libraryRepository.saveTracks(tracks);
    return MediaItemMapper.fromTrackList(
      tracks,
      likedSongIds: likedSongIds,
    );
  }

  Future<List<MediaItem>> fetchFmSongs({
    required List<int> likedSongIds,
  }) async {
    final wrap = await NeteaseMusicApi().userRadio();
    if (wrap.code != 200) {
      return const [];
    }
    await _libraryRepository.saveTracks(
      NeteaseTrackMapper.fromSongList(wrap.data ?? const []),
    );
    return NeteaseMediaItemMapper.fromFmSongs(
      wrap.data ?? const [],
      likedSongIds: likedSongIds,
    );
  }

  Future<List<MediaItem>> fetchHeartBeatSongs({
    required String startSongId,
    required String randomLikedSongId,
    required bool fromPlayAll,
    required List<int> likedSongIds,
  }) async {
    final wrap = await NeteaseMusicApi().playmodeIntelligenceList(
      startSongId,
      randomLikedSongId,
      fromPlayAll,
      count: 20,
    );
    if (wrap.code != 200) {
      return const [];
    }

    final validSongs = (wrap.data ?? [])
        .where((song) => song.songInfo != null && song.songInfo!.id.isNotEmpty)
        .map((song) => song.songInfo!)
        .toList();
    final tracks = NeteaseTrackMapper.fromSong2List(validSongs);
    await _libraryRepository.saveTracks(tracks);
    return MediaItemMapper.fromTrackList(
      tracks,
      likedSongIds: likedSongIds,
    );
  }

  Future<List<MediaItem>> fetchSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final songs = <MediaItem>[];
    var loadedSongCount = 0;
    while (loadedSongCount != ids.length) {
      final wrap = await NeteaseMusicApi().songDetail(
        ids.sublist(loadedSongCount, min(loadedSongCount + 1000, ids.length)),
      );
      final tracks = NeteaseTrackMapper.fromSong2List(wrap.songs ?? const []);
      songs.addAll(
        MediaItemMapper.fromTrackList(
          tracks,
          likedSongIds: likedSongIds,
        ),
      );
      await _libraryRepository.saveTracks(tracks);
      loadedSongCount = songs.length;
    }
    return songs;
  }

  Future<String> fetchSongAlbumUrl(String songId) async {
    final songDetailWrap = await NeteaseMusicApi().songDetail([songId]);
    final songs = songDetailWrap.songs ?? [];
    if (songs.isEmpty) {
      return '';
    }
    final tracks = NeteaseTrackMapper.fromSong2List(songs);
    await _libraryRepository.saveTracks(tracks);
    if (tracks.isEmpty) {
      return '';
    }
    return '${tracks.first.artworkUrl ?? ''}?param=500y500';
  }

  Future<OperationResult> toggleLikeSong(String songId, bool like) async {
    final result = await NeteaseMusicApi().likeSong(songId, like);
    return OperationResult(
      success: result.code == 200,
      message: result.message,
    );
  }

  Future<OperationResult> logout() async {
    final result = await NeteaseMusicApi().logout();
    return OperationResult(
      success: result.code == 200,
      message: result.message,
    );
  }
}
