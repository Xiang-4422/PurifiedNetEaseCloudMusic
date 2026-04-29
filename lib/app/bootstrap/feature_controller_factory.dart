import 'package:bujuan/features/album/album_page_controller.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/artist/artist_page_controller.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/cloud/cloud_page_controller.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/comment/comment_list_controller.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/download/local_song_list_controller.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_detail_controller.dart';
import 'package:bujuan/features/radio/radio_list_controller.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_profile_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';

/// 页面级控制器工厂，集中承接 GetX 装配到构造函数注入的边界。
class FeatureControllerFactory {
  const FeatureControllerFactory({
    required AlbumRepository albumRepository,
    required ArtistRepository artistRepository,
    required CloudRepository cloudRepository,
    required CommentRepository commentRepository,
    required DownloadRepository downloadRepository,
    required LibraryRepository libraryRepository,
    required LocalMediaRepository localMediaRepository,
    required PlaylistRepository playlistRepository,
    required RadioRepository radioRepository,
    required SearchRepository searchRepository,
    required UserRepository userRepository,
    required UserSessionController userSessionController,
    required UserLibraryController userLibraryController,
  })  : _albumRepository = albumRepository,
        _artistRepository = artistRepository,
        _cloudRepository = cloudRepository,
        _commentRepository = commentRepository,
        _downloadRepository = downloadRepository,
        _libraryRepository = libraryRepository,
        _localMediaRepository = localMediaRepository,
        _playlistRepository = playlistRepository,
        _radioRepository = radioRepository,
        _searchRepository = searchRepository,
        _userRepository = userRepository,
        _userSessionController = userSessionController,
        _userLibraryController = userLibraryController;

  final AlbumRepository _albumRepository;
  final ArtistRepository _artistRepository;
  final CloudRepository _cloudRepository;
  final CommentRepository _commentRepository;
  final DownloadRepository _downloadRepository;
  final LibraryRepository _libraryRepository;
  final LocalMediaRepository _localMediaRepository;
  final PlaylistRepository _playlistRepository;
  final RadioRepository _radioRepository;
  final SearchRepository _searchRepository;
  final UserRepository _userRepository;
  final UserSessionController _userSessionController;
  final UserLibraryController _userLibraryController;

  AlbumPageController albumPage() {
    return AlbumPageController(repository: _albumRepository);
  }

  ArtistPageController artistPage() {
    return ArtistPageController(repository: _artistRepository);
  }

  CloudPageController cloudPage({int pageSize = 30}) {
    return CloudPageController(
      repository: _cloudRepository,
      userId: _userSessionController.userInfo.value.userId,
      likedSongIds: _userLibraryController.likedSongIds.toList(),
      pageSize: pageSize,
    );
  }

  CommentListController commentList({
    required String id,
    required String type,
    required int sortType,
    int pageSize = 10,
  }) {
    return CommentListController(
      id: id,
      type: type,
      sortType: sortType,
      repository: _commentRepository,
      pageSize: pageSize,
    );
  }

  FloorCommentController floorComment({
    required String id,
    required String type,
    required String parentCommentId,
    int pageSize = 20,
  }) {
    return FloorCommentController(
      id: id,
      type: type,
      parentCommentId: parentCommentId,
      repository: _commentRepository,
      pageSize: pageSize,
    );
  }

  LocalSongListController localSongList({
    Set<TrackResourceOrigin>? origins,
  }) {
    return LocalSongListController(
      libraryRepository: _libraryRepository,
      downloadRepository: _downloadRepository,
      origins: origins,
    );
  }

  LocalMediaScanController localMediaScan() {
    return LocalMediaScanController(
      scanRepository: LocalMediaScanRepository(
        localMediaRepository: _localMediaRepository,
      ),
    );
  }

  PlaylistPageController playlistPage() {
    return PlaylistPageController(repository: _playlistRepository);
  }

  RadioListController radioList({int pageSize = 30}) {
    return RadioListController(
      userId: _userSessionController.userInfo.value.userId,
      repository: _radioRepository,
      pageSize: pageSize,
    );
  }

  RadioDetailController radioDetail({
    required String radioId,
    int pageSize = 30,
    bool asc = true,
  }) {
    return RadioDetailController(
      radioId: radioId,
      userId: _userSessionController.userInfo.value.userId,
      repository: _radioRepository,
      pageSize: pageSize,
      asc: asc,
    );
  }

  SearchPanelController searchPanel() {
    return SearchPanelController(repository: _searchRepository);
  }

  UserProfileController userProfile() {
    return UserProfileController(
      userId: _userSessionController.userInfo.value.userId,
      repository: _userRepository,
    );
  }
}
