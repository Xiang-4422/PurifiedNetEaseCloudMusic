import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/features/playlist/application/playlist_detail_service.dart';

/// 歌单详情页的应用入口，集中处理用户态、喜欢态与歌单 repository 参数。
class PlaylistPageController {
  /// 创建歌单页面控制器。
  PlaylistPageController({required PlaylistDetailService detailService})
      : _detailService = detailService;

  final PlaylistDetailService _detailService;

  /// 读取本地歌单详情。
  Future<PlaylistDetailData?> loadLocalDetail(String playlistId) {
    return _detailService.loadLocalDetail(playlistId);
  }

  /// 读取缓存的歌单快照。
  Future<PlaylistSnapshotData?> loadCachedSnapshot(String playlistId) {
    return _detailService.loadCachedSnapshot(playlistId);
  }

  /// 拉取远程歌单详情。
  Future<PlaylistDetailData> fetchDetail(String playlistId) {
    return _detailService.fetchDetail(playlistId);
  }

  /// 切换歌单收藏状态。
  Future<OperationResult> toggleSubscription(
    String playlistId, {
    required bool subscribe,
  }) {
    return _detailService.toggleSubscription(
      playlistId,
      subscribe: subscribe,
    );
  }
}
