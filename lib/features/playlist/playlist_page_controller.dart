import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/features/playlist/application/playlist_detail_service.dart';

/// 歌单详情页的应用入口，集中处理用户态、喜欢态与歌单 repository 参数。
class PlaylistPageController {
  PlaylistPageController({required PlaylistDetailService detailService})
      : _detailService = detailService;

  final PlaylistDetailService _detailService;

  Future<PlaylistDetailData?> loadLocalDetail(String playlistId) {
    return _detailService.loadLocalDetail(playlistId);
  }

  Future<PlaylistSnapshotData?> loadCachedSnapshot(String playlistId) {
    return _detailService.loadCachedSnapshot(playlistId);
  }

  Future<PlaylistDetailData> fetchDetail(String playlistId) {
    return _detailService.fetchDetail(playlistId);
  }

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
