import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';

/// 歌单详情页的应用入口，集中处理用户态、喜欢态与歌单 repository 参数。
class PlaylistPageController {
  PlaylistPageController({required PlaylistRepository repository})
      : _repository = repository;

  final PlaylistRepository _repository;

  Future<PlaylistDetailData?> loadLocalDetail(String playlistId) {
    return _repository.loadLocalPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds,
      currentUserId: _currentUserId,
    );
  }

  Future<PlaylistSnapshotData?> loadCachedSnapshot(String playlistId) {
    return _repository.loadCachedSnapshot(playlistId);
  }

  Future<PlaylistDetailData> fetchDetail(String playlistId) {
    return _repository.fetchPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds,
      currentUserId: _currentUserId,
    );
  }

  Future<OperationResult> toggleSubscription(
    String playlistId, {
    required bool subscribe,
  }) {
    return _repository.toggleSubscription(
      playlistId,
      subscribe: subscribe,
      currentUserId: _currentUserId,
    );
  }

  List<int> get _likedSongIds => UserLibraryController.to.likedSongIds.toList();

  String get _currentUserId => UserSessionController.to.userInfo.value.userId;
}
