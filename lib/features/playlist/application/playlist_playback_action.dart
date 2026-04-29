import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';

/// 歌单卡片触发播放时的应用动作，避免 UI 组件直接读取 repository。
class PlaylistPlaybackAction {
  PlaylistPlaybackAction({
    required PlaylistRepository repository,
    required String Function() currentPlaylistName,
    required Future<void> Function() toggleCurrentPlayback,
    required Future<void> Function(
      List<PlaybackQueueItem> playlist,
      int index, {
      required String playListName,
      String playListNameHeader,
    }) playPlaylist,
  })  : _repository = repository,
        _currentPlaylistName = currentPlaylistName,
        _toggleCurrentPlayback = toggleCurrentPlayback,
        _playPlaylist = playPlaylist;

  final PlaylistRepository _repository;
  final String Function() _currentPlaylistName;
  final Future<void> Function() _toggleCurrentPlayback;
  final Future<void> Function(
    List<PlaybackQueueItem> playlist,
    int index, {
    required String playListName,
    String playListNameHeader,
  }) _playPlaylist;

  Future<void> play(PlaylistSummaryData playlist) async {
    if (_currentPlaylistName() == playlist.title) {
      await _toggleCurrentPlayback();
      return;
    }
    final details = await _repository.fetchPlaylistSnapshot(playlist.id);
    final songs = await _repository.fetchPlaylistSongs(
      playlistId: playlist.id,
      likedSongIds: UserLibraryController.to.likedSongIds.toList(),
      playlistSnapshot: details,
    );
    await _playPlaylist(
      songs,
      0,
      playListName: details.name,
      playListNameHeader: '歌单',
    );
  }
}
