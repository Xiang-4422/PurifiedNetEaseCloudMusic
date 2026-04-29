import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';

export 'package:bujuan/features/playlist/playlist_repository.dart'
    show PlaylistDetailData, PlaylistSnapshotData;

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

  /// 读取本地歌单详情。
  Future<PlaylistDetailData?> loadLocalDetail(String playlistId) {
    return _repository.loadLocalPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      currentUserId: _currentUserId(),
    );
  }

  /// 读取缓存的歌单快照。
  Future<PlaylistSnapshotData?> loadCachedSnapshot(String playlistId) {
    return _repository.loadCachedSnapshot(playlistId);
  }

  /// 拉取远程歌单详情。
  Future<PlaylistDetailData> fetchDetail(String playlistId) {
    return _repository.fetchPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      currentUserId: _currentUserId(),
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
