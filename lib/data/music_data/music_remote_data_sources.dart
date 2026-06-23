// ignore_for_file: public_member_api_docs

import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/user_profile_data.dart';
import 'package:bujuan/core/entities/user_session_data.dart';

typedef AuthQrCodeKeyResult = ({
  bool success,
  String unikey,
  String? message,
});

typedef AuthQrCodeStatusResult = ({
  int code,
  String? message,
});

typedef RemoteOperationResult = ({
  bool success,
  String? message,
});

typedef AlbumRemoteDetail = ({
  AlbumEntity? album,
  List<Track> tracks,
});

typedef ArtistRemoteDetail = ({
  ArtistEntity? artist,
  List<Track> topTracks,
  List<AlbumEntity> hotAlbums,
});

typedef CloudRemoteSongPage = ({
  List<Track> tracks,
  int itemCount,
});

typedef CommentRemotePage = ({
  List<CommentData> items,
  bool hasMore,
  String? nextCursor,
});

typedef FloorCommentRemotePage = ({
  List<CommentData> items,
  bool hasMore,
  int nextTime,
});

typedef ExplorePlaylistCatalogueRemoteData = ({
  List<String> categoryNames,
  Map<String, List<String>> tagsByCategory,
});

typedef PlaylistRemoteIndex = ({
  PlaylistEntity? playlist,
  List<String> trackIds,
  bool isSubscribed,
  String name,
  String? creatorUserId,
  bool isLikedSongs,
});

typedef RadioSummaryRemotePage = ({
  List<RadioSummaryData> items,
  int itemCount,
});

typedef RadioProgramRemotePage = ({
  List<RadioProgramData> items,
  int itemCount,
});

abstract interface class AuthRemoteDataSource {
  Future<AuthQrCodeKeyResult> createQrCodeKey();

  String buildQrCodeUrl(String unikey);

  Future<AuthQrCodeStatusResult> checkQrCodeStatus(String unikey);

  Future<UserSessionData> fetchLoginAccountInfo();
}

abstract interface class UserRemoteDataSource {
  Future<UserProfileData> fetchUserDetail(String userId);

  Future<List<int>> fetchLikedSongIds(String userId);

  Future<List<PlaylistEntity>> fetchRecommendedPlaylists({
    required int offset,
    required int limit,
  });

  Future<List<PlaylistEntity>> fetchUserPlaylists(String userId);

  Future<List<Track>> fetchTodayRecommendSongs();

  Future<List<Track>> fetchFmSongs();

  Future<List<Track>> fetchHeartBeatSongs({
    required String startSongId,
    required String randomLikedSongId,
    required bool fromPlayAll,
  });

  Future<List<Track>> fetchSongsByIds({
    required List<String> ids,
  });

  Future<String> fetchSongAlbumUrl(String songId);

  Future<RemoteOperationResult> toggleLikeSong(String songId, bool like);

  Future<RemoteOperationResult> logout();
}

abstract interface class PlaylistRemoteDataSource {
  Future<PlaylistRemoteIndex> fetchPlaylistIndex(String playlistId);

  Future<List<Track>> fetchPlaylistSongs({
    required List<String> songIds,
    required int offset,
    required int limit,
  });

  Future<RemoteOperationResult> toggleSubscription(
    String playlistId, {
    required bool subscribe,
  });

  Future<RemoteOperationResult> manipulateTracks(
    String playlistId,
    String songId, {
    required bool add,
  });
}

abstract interface class AlbumRemoteDataSource {
  Future<AlbumRemoteDetail> fetchAlbumDetail({
    required String albumId,
  });
}

abstract interface class ArtistRemoteDataSource {
  Future<ArtistRemoteDetail> fetchArtistDetail({
    required String artistId,
  });
}

abstract interface class CloudRemoteDataSource {
  Future<CloudRemoteSongPage> fetchCloudSongs({
    required int offset,
    required int limit,
  });
}

abstract interface class RadioRemoteDataSource {
  Future<RadioSummaryRemotePage> fetchSubscribedRadios({
    bool total = true,
    required int offset,
    required int limit,
  });

  Future<RadioProgramRemotePage> fetchPrograms(
    String radioId, {
    required int offset,
    required int limit,
    required bool asc,
  });
}

abstract interface class SearchRemoteDataSource {
  Future<List<String>> fetchHotKeywords();
}

abstract interface class CommentRemoteDataSource {
  Future<CommentRemotePage> fetchComments(
    String id,
    String type, {
    required int pageNo,
    required int pageSize,
    required bool showInner,
    required int sortType,
    required String cursor,
  });

  Future<FloorCommentRemotePage> fetchFloorComments(
    String id,
    String type,
    String parentCommentId, {
    required int time,
    required int limit,
  });

  Future<RemoteOperationResult> sendComment(
    String id,
    String type,
    String operation, {
    required String content,
    String? commentId,
  });

  Future<RemoteOperationResult> toggleCommentLike(
    String id,
    String type,
    String commentId,
    bool like,
  );
}

abstract interface class ExploreRemoteDataSource {
  Future<ExplorePlaylistCatalogueRemoteData> fetchPlaylistCatalogue();

  Future<List<PlaylistEntity>> fetchCategoryPlaylists(String category);
}
