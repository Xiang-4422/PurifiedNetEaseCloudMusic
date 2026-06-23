import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/local_song_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/download/local_song_list_controller.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/ui/pages/download/widgets/local_song_list_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 本地歌曲与下载缓存管理页面。
class DownloadTaskPageView extends StatefulWidget {
  /// 全部本地资源 tab。
  static const int tabAll = 0;

  /// 播放缓存 tab。
  static const int tabPlaybackCache = 1;

  /// 手动下载 tab。
  static const int tabDownloaded = 2;

  /// 本地导入 tab。
  static const int tabLocalImport = 3;

  /// 创建本地歌曲与下载缓存管理页面。
  const DownloadTaskPageView({
    super.key,
    this.initialTabIndex = tabAll,
  });

  /// 初始展示的 tab 索引。
  final int initialTabIndex;

  @override
  State<DownloadTaskPageView> createState() => _DownloadTaskPageViewState();
}

class _DownloadTaskPageViewState extends State<DownloadTaskPageView> with SingleTickerProviderStateMixin {
  static const _clearPlaybackCacheAction = 'clear_playback_cache';

  late final TabController _tabController;
  late final LocalSongListController _allController;
  late final LocalSongListController _cacheController;
  late final LocalSongListController _downloadController;
  late final LocalSongListController _importController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex
          .clamp(
            DownloadTaskPageView.tabAll,
            DownloadTaskPageView.tabLocalImport,
          )
          .toInt(),
    );
    _allController = _localSongList()..loadInitial();
    _cacheController = _localSongList(
      origins: const {TrackResourceOrigin.playbackCache},
    )..loadInitial();
    _downloadController = _localSongList(
      origins: const {TrackResourceOrigin.managedDownload},
    )..loadInitial();
    _importController = _localSongList(
      origins: const {TrackResourceOrigin.localImport},
    )..loadInitial();
  }

  LocalSongListController _localSongList({
    Set<TrackResourceOrigin>? origins,
  }) {
    return LocalSongListController(
      musicDataRepository: Get.find<MusicDataRepository>(),
      downloadRepository: Get.find<DownloadRepository>(),
      origins: origins,
    );
  }

  @override
  void dispose() {
    _allController.dispose();
    _cacheController.dispose();
    _downloadController.dispose();
    _importController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('本地歌曲'),
          actions: [
            PopupMenuButton<String>(
              tooltip: '批量操作',
              onSelected: _handleBulkAction,
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: _clearPlaybackCacheAction,
                  child: Text('删除所有缓存'),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: ValueListenableBuilder<LoadState<List<LocalSongEntry>>>(
              valueListenable: _allController.state,
              builder: (context, state, child) {
                final items = state.data ?? const <LocalSongEntry>[];
                final cacheCount = items
                    .where(
                      (item) => item.origin == TrackResourceOrigin.playbackCache,
                    )
                    .length;
                final downloadCount = items
                    .where(
                      (item) => item.origin == TrackResourceOrigin.managedDownload,
                    )
                    .length;
                final importCount = items
                    .where(
                      (item) => item.origin == TrackResourceOrigin.localImport,
                    )
                    .length;
                return TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: '全部 ${items.length}'),
                    Tab(text: '缓存 $cacheCount'),
                    Tab(text: '已下载 $downloadCount'),
                    Tab(text: '本地导入 $importCount'),
                  ],
                );
              },
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            LocalSongTabView(
              controller: _allController,
              onMutated: _refreshAllTabs,
            ),
            LocalSongTabView(
              controller: _cacheController,
              onMutated: _refreshAllTabs,
            ),
            LocalSongTabView(
              controller: _downloadController,
              onMutated: _refreshAllTabs,
            ),
            LocalSongTabView(
              controller: _importController,
              onMutated: _refreshAllTabs,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBulkAction(String action) async {
    if (action != _clearPlaybackCacheAction) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除所有缓存'),
        content: const Text('这会删除自动缓存的音频、封面和歌词，不会删除手动下载和本地导入。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('继续'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _cacheController.clearPlaybackCache();
    await _refreshAllTabs();
  }

  Future<void> _refreshAllTabs() async {
    await _allController.refresh();
    await _cacheController.refresh();
    await _downloadController.refresh();
    await _importController.refresh();
  }
}
