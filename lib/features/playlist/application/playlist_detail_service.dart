import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';

export 'package:bujuan/features/playlist/playlist_repository.dart'
    show PlaylistDetailData, PlaylistSnapshotData;

/// PlaylistDetailService。
class PlaylistDetailService {
  /// 创建 PlaylistDetailService。
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

  /// loadLocalDetail。
  Future<PlaylistDetailData?> loadLocalDetail(String playlistId) {
    return _repository.loadLocalPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      currentUserId: _currentUserId(),
    );
  }

  /// loadCachedSnapshot。
  Future<PlaylistSnapshotData?> loadCachedSnapshot(String playlistId) {
    return _repository.loadCachedSnapshot(playlistId);
  }

  /// fetchDetail。
  Future<PlaylistDetailData> fetchDetail(String playlistId) {
    return _repository.fetchPlaylistDetail(
      playlistId: playlistId,
      likedSongIds: _likedSongIds(),
      currentUserId: _currentUserId(),
    );
  }

  /// toggleSubscription。
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
