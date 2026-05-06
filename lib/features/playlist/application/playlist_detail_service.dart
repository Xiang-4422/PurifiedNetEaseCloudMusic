import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';

export 'package:bujuan/features/playlist/playlist_repository.dart' show PlaylistDetailData, PlaylistLocalInitialData;

/// 歌单详情应用服务，统一补齐当前用户和喜欢歌曲参数。
class PlaylistDetailService {
  /// 创建歌单详情应用服务。
  PlaylistDetailService({
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
  Future<PlaylistDetailData?> loadLocalDetail(String playlistId) {
    return _repository.loadLocalPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      currentUserId: _currentUserId(),
    );
  }

  /// 读取页面初始化所需的本地详情和歌单元信息。
  Future<PlaylistLocalInitialData> loadLocalInitialDetail(String playlistId) {
    return _repository.loadLocalInitialDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      currentUserId: _currentUserId(),
    );
  }

  /// 拉取远程歌单详情。
  Future<PlaylistDetailData> fetchDetail(
    String playlistId, {
    int offset = 0,
    int limit = -1,
  }) {
    return _repository.fetchPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      currentUserId: _currentUserId(),
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

  /// 切换当前用户对歌单的收藏状态。
  Future<OperationResult> toggleSubscription(
    String playlistId, {
    required bool subscribe,
  }) {
    return _repository.toggleSubscription(
      playlistId,
      subscribe: subscribe,
      currentUserId: _currentUserId(),
    );
  }
}
