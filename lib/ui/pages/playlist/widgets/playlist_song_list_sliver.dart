import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:flutter/material.dart';

/// 歌单详情页的歌曲列表 sliver。
class PlaylistSongListSliver extends StatelessWidget {
  /// 创建歌单歌曲列表。
  const PlaylistSongListSliver({
    super.key,
    required this.songs,
    required this.playlistName,
    required this.foregroundColor,
    required this.onTapSong,
  });

  /// 当前已加载歌曲。
  final List<PlaybackQueueItem> songs;

  /// 播放队列名称。
  final String playlistName;

  /// 歌曲列表文字颜色。
  final Color foregroundColor;

  /// 点击歌曲时触发播放。
  final Future<void> Function(int index) onTapSong;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final song = songs[index];
            return SongItem(
              item: song,
              index: index,
              playListName: playlistName,
              playListHeader: '歌单',
              stringColor: foregroundColor,
              onTap: () => onTapSong(index),
            );
          },
          childCount: songs.length,
        ),
      ),
    );
  }
}
