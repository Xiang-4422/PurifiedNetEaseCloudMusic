import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:get/get.dart';

/// 歌单卡片触发播放时的应用动作，避免 UI 组件直接读取 repository。
class PlaylistPlaybackAction {
  PlaylistPlaybackAction({required PlaylistRepository repository})
      : _repository = repository;

  static PlaylistPlaybackAction get to => Get.find<PlaylistPlaybackAction>();

  final PlaylistRepository _repository;

  Future<void> play(PlaylistSummaryData playlist) async {
    if (PlayerController.to.sessionState.value.playlistName == playlist.title) {
      await PlayerController.to.playOrPause();
      return;
    }
    final details = await _repository.fetchPlaylistSnapshot(playlist.id);
    final songs = await _repository.fetchPlaylistSongs(
      playlistId: playlist.id,
      likedSongIds: UserLibraryController.to.likedSongIds.toList(),
      playlistSnapshot: details,
    );
    await PlayerController.to.playPlaylist(
      songs,
      0,
      playListName: details.name,
      playListNameHeader: '歌单',
    );
  }
}
