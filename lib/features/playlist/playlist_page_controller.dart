import 'package:bujuan/core/entities/liked_song_ids.dart';
import 'package:bujuan/core/state/operation_result.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/playlist/playlist_detail_data.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';

/// 本地歌单详情可用于首屏展示的完整性状态。
enum PlaylistLocalDetailState {
  /// 没有可展示的本地歌曲。
  empty,

  /// 有部分本地歌曲，但仍需补全。
  partial,

  /// 本地歌曲已满足预期数量。
  complete,
}

/// 歌单详情页初始化所需的本地数据。
class PlaylistInitialDetailData {
  /// 创建歌单详情页初始化数据。
  const PlaylistInitialDetailData({
    required this.localDetail,
    required this.localPlaylist,
    required this.localState,
  });

  /// 本地可展示的歌单详情。
  final PlaylistDetailData? localDetail;

  /// 本地保存的歌单元信息。
  final PlaylistEntity? localPlaylist;

  /// 本地详情可用于首屏展示的完整性状态。
  final PlaylistLocalDetailState localState;
}

/// 歌单详情页的应用入口，集中处理用户态、喜欢态与歌单 repository 参数。
class PlaylistPageController {
  /// 创建歌单页面控制器。
  PlaylistPageController({
    required PlaylistRepository repository,
    required List<int> Function() likedSongIds,
    required String Function() currentUserId,
  })  : _repository = repository,
        _likedSongIds = likedSongIds,
        _currentUserId = currentUserId;

  final PlaylistRepository _repository;
  final List<int> Function() _likedSongIds;
  final String Function() _currentUserId;

  static const int _firstPageSize = 30;

  /// 读取本地歌单详情。
  Future<PlaylistDetailData?> loadLocalDetail(String playlistId) async {
    try {
      return await _repository.loadLocalPlaylistDetail(
        playlistId: playlistId,
        likedSongIds: _likedSongIdsSnapshot(),
        currentUserId: _currentUserIdSnapshot(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 读取歌单详情页初始化所需的本地数据。
  Future<PlaylistInitialDetailData> loadInitialDetail(String playlistId) async {
    try {
      final initialData = await _repository.loadLocalInitialDetail(
        playlistId: playlistId,
        likedSongIds: _likedSongIdsSnapshot(),
        currentUserId: _currentUserIdSnapshot(),
      );
      return PlaylistInitialDetailData(
        localDetail: initialData.localDetail,
        localPlaylist: initialData.localPlaylist,
        localState: resolveLocalDetailState(initialData.localDetail),
      );
    } catch (_) {
      return const PlaylistInitialDetailData(
        localDetail: null,
        localPlaylist: null,
        localState: PlaylistLocalDetailState.empty,
      );
    }
  }

  /// 拉取远程歌单详情。
  Future<PlaylistDetailData> fetchDetail(
    String playlistId, {
    int offset = 0,
    int limit = -1,
  }) {
    return _repository.fetchPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIdsSnapshot(),
      currentUserId: _currentUserIdSnapshot(),
      offset: offset,
      limit: limit,
    );
  }

  /// 拉取歌单首屏歌曲。
  Future<PlaylistDetailData> fetchFirstPage(String playlistId) {
    return fetchDetail(
      playlistId,
      offset: 0,
      limit: _firstPageSize,
    );
  }

  /// 从指定偏移开始拉取歌单剩余歌曲。
  Future<PlaylistDetailData> fetchRemaining(
    String playlistId, {
    required int offset,
  }) {
    return fetchDetail(
      playlistId,
      offset: offset,
      limit: -1,
    );
  }

  /// 拉取完整歌单。
  Future<PlaylistDetailData> refreshFull(String playlistId) {
    return fetchDetail(
      playlistId,
      offset: 0,
      limit: -1,
    );
  }

  /// 判断本地详情适合以哪种状态展示。
  PlaylistLocalDetailState resolveLocalDetailState(
    PlaylistDetailData? detail,
  ) {
    return resolveLocalDetailDisplayState(detail);
  }

  /// 判断本地详情适合以哪种状态展示。
  static PlaylistLocalDetailState resolveLocalDetailDisplayState(
    PlaylistDetailData? detail,
  ) {
    if (detail == null || detail.songs.isEmpty) {
      return PlaylistLocalDetailState.empty;
    }
    return detail.isComplete ? PlaylistLocalDetailState.complete : PlaylistLocalDetailState.partial;
  }

  /// 切换歌单收藏状态。
  Future<OperationResult> toggleSubscription(
    String playlistId, {
    required bool subscribe,
  }) {
    return _repository.toggleSubscription(
      playlistId,
      subscribe: subscribe,
      currentUserId: _currentUserIdSnapshot(),
    );
  }

  String _currentUserIdSnapshot() {
    return _normalizedCurrentUserId(_currentUserId());
  }

  List<int> _likedSongIdsSnapshot() {
    return normalizeLikedSongIds(_likedSongIds());
  }

  static String _normalizedCurrentUserId(String userId) {
    return userId.trim();
  }
}
