import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
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
  PlaylistPageController({required PlaylistDetailService detailService}) : _detailService = detailService;

  final PlaylistDetailService _detailService;

  /// 读取本地歌单详情。
  Future<PlaylistDetailData?> loadLocalDetail(String playlistId) {
    return _detailService.loadLocalDetail(playlistId);
  }

  /// 读取歌单详情页初始化所需的本地数据。
  Future<PlaylistInitialDetailData> loadInitialDetail(String playlistId) async {
    final initialData = await _detailService.loadLocalInitialDetail(playlistId);
    return PlaylistInitialDetailData(
      localDetail: initialData.localDetail,
      localPlaylist: initialData.localPlaylist,
      localState: resolveLocalDetailState(initialData.localDetail),
    );
  }

  /// 拉取远程歌单详情。
  Future<PlaylistDetailData> fetchDetail(
    String playlistId, {
    int offset = 0,
    int limit = -1,
  }) {
    return _detailService.fetchDetail(
      playlistId,
      offset: offset,
      limit: limit,
    );
  }

  /// 拉取歌单首屏歌曲。
  Future<PlaylistDetailData> fetchFirstPage(String playlistId) {
    return _detailService.fetchFirstPage(playlistId);
  }

  /// 从指定偏移开始拉取歌单剩余歌曲。
  Future<PlaylistDetailData> fetchRemaining(
    String playlistId, {
    required int offset,
  }) {
    return _detailService.fetchRemaining(
      playlistId,
      offset: offset,
    );
  }

  /// 拉取完整歌单。
  Future<PlaylistDetailData> refreshFull(String playlistId) {
    return _detailService.refreshFull(playlistId);
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
    return _detailService.toggleSubscription(
      playlistId,
      subscribe: subscribe,
    );
  }
}
