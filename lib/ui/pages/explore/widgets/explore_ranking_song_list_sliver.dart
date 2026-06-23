import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 探索页榜单歌曲列表。
class ExploreRankingSongListSliver extends StatelessWidget {
  /// 创建榜单歌曲列表。
  const ExploreRankingSongListSliver({
    super.key,
    required this.songs,
    required this.playlistName,
    required this.onPlay,
  });

  /// 当前榜单歌曲。
  final List<PlaybackQueueItem> songs;

  /// 当前榜单名称。
  final String playlistName;

  /// 播放回调。
  final Future<void> Function(
    List<PlaybackQueueItem> playlist,
    int index, {
    String playListName,
    String playListNameHeader,
  }) onPlay;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => SongItem(
          index: index,
          playlist: songs,
          playListName: playlistName,
          showIndex: true,
          onPlay: onPlay,
        ).paddingSymmetric(horizontal: AppDimensions.paddingSmall),
        addAutomaticKeepAlives: false,
        childCount: songs.length,
      ),
    );
  }
}
