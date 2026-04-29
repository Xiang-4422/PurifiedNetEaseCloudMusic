import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/local_song_entry.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/download/local_song_list_controller.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/load_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

/// DownloadTaskPageView。
class DownloadTaskPageView extends StatefulWidget {
  /// 创建 DownloadTaskPageView。
  const DownloadTaskPageView({super.key});

  @override
  State<DownloadTaskPageView> createState() => _DownloadTaskPageViewState();
}

class _DownloadTaskPageViewState extends State<DownloadTaskPageView>
    with SingleTickerProviderStateMixin {
  static const _clearPlaybackCacheAction = 'clear_playback_cache';

  late final TabController _tabController;
  late final LocalSongListController _allController;
  late final LocalSongListController _cacheController;
  late final LocalSongListController _downloadController;
  late final LocalSongListController _importController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final controllerFactory = Get.find<FeatureControllerFactory>();
    _allController = controllerFactory.localSongList()..loadInitial();
    _cacheController = controllerFactory.localSongList(
      origins: const {TrackResourceOrigin.playbackCache},
    )..loadInitial();
    _downloadController = controllerFactory.localSongList(
      origins: const {TrackResourceOrigin.managedDownload},
    )..loadInitial();
    _importController = controllerFactory.localSongList(
      origins: const {TrackResourceOrigin.localImport},
    )..loadInitial();
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
                      (item) =>
                          item.origin == TrackResourceOrigin.playbackCache,
                    )
                    .length;
                final downloadCount = items
                    .where(
                      (item) =>
                          item.origin == TrackResourceOrigin.managedDownload,
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
            _LocalSongTabView(
              controller: _allController,
              onMutated: _refreshAllTabs,
            ),
            _LocalSongTabView(
              controller: _cacheController,
              onMutated: _refreshAllTabs,
            ),
            _LocalSongTabView(
              controller: _downloadController,
              onMutated: _refreshAllTabs,
            ),
            _LocalSongTabView(
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

class _LocalSongTabView extends StatelessWidget {
  const _LocalSongTabView({
    required this.controller,
    required this.onMutated,
  });

  final LocalSongListController controller;
  final Future<void> Function() onMutated;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoadState<List<LocalSongEntry>>>(
      valueListenable: controller.state,
      builder: (context, state, child) {
        return LoadStateView<List<LocalSongEntry>>(
          state: state,
          emptyView: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 160),
                EmptyView(),
              ],
            ),
          ),
          builder: (items) {
            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: AppDimensions.paddingSmall,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = items[index];
                  return _LocalSongTile(
                    entry: entry,
                    onDelete: () async {
                      await controller.removeLocalTrack(entry.track.id);
                      await onMutated();
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _LocalSongTile extends StatelessWidget {
  const _LocalSongTile({
    required this.entry,
    required this.onDelete,
  });

  final LocalSongEntry entry;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingSmall / 2,
        ),
        title: Text(
          entry.track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${entry.track.artistNames.join(' / ')}\n${_originLabel(entry.origin)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).hintColor,
          ),
        ),
        trailing: IconButton(
          tooltip: '删除本地资源',
          onPressed: onDelete,
          icon: const Icon(TablerIcons.trash),
        ),
      ),
    );
  }

  static String _originLabel(TrackResourceOrigin origin) {
    switch (origin) {
      case TrackResourceOrigin.artworkCache:
        return '封面缓存';
      case TrackResourceOrigin.playbackCache:
        return '缓存';
      case TrackResourceOrigin.managedDownload:
        return '已下载';
      case TrackResourceOrigin.localImport:
        return '本地导入';
      case TrackResourceOrigin.none:
        return '本地资源';
    }
  }
}
