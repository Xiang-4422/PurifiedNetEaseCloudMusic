import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/features/playlist/application/playlist_detail_service.dart';

/// 本地歌单详情可用于首屏展示的完整性状态。
enum PlaylistLocalDetailState {
  /// 没有可展示的本地歌曲。
  empty,

  /// 有部分本地歌曲，但仍需补全。
  partial,

  /// 本地歌曲已满足预期数量。
  complete,
}

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
    return detail.isComplete
        ? PlaylistLocalDetailState.complete
        : PlaylistLocalDetailState.partial;
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
