import 'package:bujuan/core/entities/local_song_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/features/download/local_song_list_controller.dart';
import 'package:flutter/material.dart';

/// 本地歌曲页 tab 标题栏。
class LocalSongTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// 创建本地歌曲页 tab 标题栏。
  const LocalSongTabBar({
    super.key,
    required this.controller,
    required this.tabController,
  });

  /// 全部本地资源控制器，用于统计各来源数量。
  final LocalSongListController controller;

  /// 页面 tab 控制器。
  final TabController tabController;

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoadState<List<LocalSongEntry>>>(
      valueListenable: controller.state,
      builder: (context, state, child) {
        final items = state.data ?? const <LocalSongEntry>[];
        final cacheCount = _countOrigin(
          items,
          TrackResourceOrigin.playbackCache,
        );
        final downloadCount = _countOrigin(
          items,
          TrackResourceOrigin.managedDownload,
        );
        final importCount = _countOrigin(
          items,
          TrackResourceOrigin.localImport,
        );
        return TabBar(
          controller: tabController,
          tabs: [
            Tab(text: '全部 ${items.length}'),
            Tab(text: '缓存 $cacheCount'),
            Tab(text: '已下载 $downloadCount'),
            Tab(text: '本地导入 $importCount'),
          ],
        );
      },
    );
  }

  int _countOrigin(
    List<LocalSongEntry> items,
    TrackResourceOrigin origin,
  ) {
    return items.where((item) => item.origin == origin).length;
  }
}
