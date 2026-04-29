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
import 'package:bujuan/features/playlist/application/playlist_detail_service.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_detail_controller.dart';
import 'package:bujuan/features/radio/radio_list_controller.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/application/search_application_service.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_profile_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';

/// 页面级控制器工厂，集中承接 GetX 装配到构造函数注入的边界。
class FeatureControllerFactory {
  /// 创建页面级控制器工厂，并注入页面控制器需要的仓库和共享控制器。
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
    required SearchApplicationService searchApplicationService,
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
        _searchApplicationService = searchApplicationService,
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
  final SearchApplicationService _searchApplicationService;
  final UserRepository _userRepository;
  final UserSessionController _userSessionController;
  final UserLibraryController _userLibraryController;

  /// 创建专辑详情页控制器。
  AlbumPageController albumPage() {
    return AlbumPageController(repository: _albumRepository);
  }

  /// 创建歌手详情页控制器。
  ArtistPageController artistPage() {
    return ArtistPageController(repository: _artistRepository);
  }

  /// 创建云盘页控制器。
  CloudPageController cloudPage({int pageSize = 30}) {
    return CloudPageController(
      repository: _cloudRepository,
      userId: _userSessionController.userInfo.value.userId,
      likedSongIds: _userLibraryController.likedSongIds.toList(),
      pageSize: pageSize,
    );
  }

  /// 创建评论列表控制器。
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

  /// 创建楼层评论控制器。
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

  /// 创建本地歌曲列表控制器。
  LocalSongListController localSongList({
    Set<TrackResourceOrigin>? origins,
  }) {
    return LocalSongListController(
      libraryRepository: _libraryRepository,
      downloadRepository: _downloadRepository,
      origins: origins,
    );
  }

  /// 创建本地媒体扫描控制器。
  LocalMediaScanController localMediaScan() {
    return LocalMediaScanController(
      scanRepository: LocalMediaScanRepository(
        localMediaRepository: _localMediaRepository,
      ),
    );
  }

  /// 创建歌单详情页控制器。
  PlaylistPageController playlistPage() {
    return PlaylistPageController(
      detailService: PlaylistDetailService(
        repository: _playlistRepository,
        likedSongIds: () => _userLibraryController.likedSongIds.toList(),
        currentUserId: () => _userSessionController.userInfo.value.userId,
      ),
    );
  }

  /// 创建电台列表控制器。
  RadioListController radioList({int pageSize = 30}) {
    return RadioListController(
      userId: _userSessionController.userInfo.value.userId,
      repository: _radioRepository,
      pageSize: pageSize,
    );
  }

  /// 创建电台详情控制器。
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

  /// 创建搜索面板控制器。
  SearchPanelController searchPanel() {
    return SearchPanelController(service: _searchApplicationService);
  }

  /// 创建用户资料页控制器。
  UserProfileController userProfile() {
    return UserProfileController(
      userId: _userSessionController.userInfo.value.userId,
      repository: _userRepository,
    );
  }
}
