import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:bujuan/ui/widgets/playlist/playlist_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 个人页“常用歌单”区域。
class FrequentPlaylistSection extends StatelessWidget {
  /// 创建常用歌单区域。
  const FrequentPlaylistSection({
    super.key,
    required this.libraryController,
    required this.recommendationController,
    required this.playbackAction,
    required this.albumCountInWidget,
    this.headerHeight = AppDimensions.headerHeight,
    this.headerTopMargin = 0,
  });

  /// 用户资料库控制器。
  final UserLibraryController libraryController;

  /// 首页推荐控制器。
  final RecommendationController recommendationController;

  /// 播放控制器。
  final PlayerController playbackAction;

  /// 横向区域中一屏展示的歌单卡片数量。
  final double albumCountInWidget;

  /// 标题高度。
  final double headerHeight;

  /// 标题顶部间距。
  final double headerTopMargin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Header(
          '常用歌单',
          padding: AppDimensions.paddingSmall,
          height: headerHeight,
        ).marginOnly(top: headerTopMargin),
        Obx(
          () => PlayListWidget(
            playLists: libraryController.homeFrequentPlaylists,
            albumCountInWidget: albumCountInWidget,
            albumMargin: AppDimensions.paddingSmall,
            showSongCount: false,
            isPlaying: playbackAction.isPlaying.value,
            playingPlaylistName: playbackAction.sessionState.value.playlistName,
            onPlayPlaylist: (playlist) => _playPlaylistSummary(
              recommendationController,
              playbackAction,
              playlist,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _playPlaylistSummary(
  RecommendationController recommendationController,
  PlayerController playerController,
  PlaylistSummaryData playlist,
) async {
  if (playerController.sessionState.value.playlistName == playlist.title) {
    await playerController.playOrPause();
    return;
  }
  final plan = await recommendationController.resolveFrequentPlaylistPlayback(
    playlist,
  );
  await playerController.playPlaylist(
    plan.songs,
    0,
    playListName: plan.playlistName,
    playListNameHeader: '歌单',
  );
}
