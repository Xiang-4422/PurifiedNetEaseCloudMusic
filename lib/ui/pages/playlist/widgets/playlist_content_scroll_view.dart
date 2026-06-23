import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/pages/playlist/widgets/playlist_header_sliver.dart';
import 'package:bujuan/ui/pages/playlist/widgets/playlist_song_list_sliver.dart';
import 'package:bujuan/ui/pages/playlist/widgets/playlist_status_slivers.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:flutter/material.dart';

/// 歌单详情页的可见滚动内容组合。
class PlaylistContentScrollView extends StatelessWidget {
  /// 创建歌单内容滚动视图。
  const PlaylistContentScrollView({
    required this.playlistName,
    required this.coverUrl,
    required this.trackCount,
    required this.loadedTrackCount,
    required this.songs,
    required this.albumColor,
    required this.foregroundColor,
    required this.isSubscribed,
    required this.isMyPlaylist,
    required this.canPlayLoadedPlaylist,
    required this.isShowingPlaylistSkeleton,
    required this.isShowingStatusFooter,
    required this.completionMessage,
    required this.onRefresh,
    required this.onPlaySequential,
    required this.onPlayShuffle,
    required this.onToggleSubscribe,
    required this.onTapSong,
    super.key,
  });

  /// 歌单名称。
  final String playlistName;

  /// 已解析后的封面地址。
  final String? coverUrl;

  /// 歌单预计歌曲总数。
  final int? trackCount;

  /// 当前已加载的歌曲数量。
  final int loadedTrackCount;

  /// 当前可展示和播放的歌曲列表。
  final List<PlaybackQueueItem> songs;

  /// 页面背景色。
  final Color albumColor;

  /// 前景文字和图标色。
  final Color foregroundColor;

  /// 当前用户是否已收藏歌单。
  final bool isSubscribed;

  /// 歌单是否属于当前用户。
  final bool isMyPlaylist;

  /// 当前歌曲列表是否可以立即播放。
  final bool canPlayLoadedPlaylist;

  /// 是否展示歌曲列表骨架屏。
  final bool isShowingPlaylistSkeleton;

  /// 是否展示底部状态信息。
  final bool isShowingStatusFooter;

  /// 底部状态文案。
  final String completionMessage;

  /// 下拉刷新回调。
  final RefreshCallback onRefresh;

  /// 顺序播放回调。
  final Future<void> Function() onPlaySequential;

  /// 随机播放回调。
  final Future<void> Function() onPlayShuffle;

  /// 收藏/取消收藏回调。
  final Future<void> Function() onToggleSubscribe;

  /// 点击歌曲回调。
  final Future<void> Function(int index) onTapSong;

  @override
  Widget build(BuildContext context) {
    final layoutMetrics = AdaptiveLayoutMetrics.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          PlaylistHeaderSliver(
            playlistName: playlistName,
            coverUrl: coverUrl,
            trackCount: trackCount,
            loadedTrackCount: loadedTrackCount,
            heroExtent: layoutMetrics.heroExtent,
            albumColor: albumColor,
            widgetColor: foregroundColor,
            isSubscribed: isSubscribed,
            isMyPlaylist: isMyPlaylist,
            canPlayLoadedPlaylist: canPlayLoadedPlaylist,
            onPlaySequential: onPlaySequential,
            onPlayShuffle: onPlayShuffle,
            onToggleSubscribe: onToggleSubscribe,
          ),
          if (isShowingPlaylistSkeleton)
            PlaylistSkeletonSliver(foregroundColor: foregroundColor)
          else
            PlaylistSongListSliver(
              songs: songs,
              playlistName: playlistName,
              foregroundColor: foregroundColor,
              onTapSong: onTapSong,
            ),
          if (isShowingStatusFooter)
            PlaylistStatusFooterSliver(
              message: completionMessage,
              foregroundColor: foregroundColor,
            ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: AppDimensions.bottomPanelHeaderHeight,
            ),
          ),
        ],
      ),
    );
  }
}
