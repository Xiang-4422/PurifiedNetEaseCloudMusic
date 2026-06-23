import 'package:bujuan/core/entities/local_song_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/features/download/local_song_list_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/feedback/load_state_view.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

const double _localSongListCacheExtent = 360;

/// 本地歌曲 tab 内容。
class LocalSongTabView extends StatelessWidget {
  /// 创建本地歌曲 tab 内容。
  const LocalSongTabView({
    super.key,
    required this.controller,
    required this.onMutated,
  });

  /// 当前 tab 的本地歌曲控制器。
  final LocalSongListController controller;

  /// 删除或清理资源后触发的跨 tab 刷新。
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
                cacheExtent: _localSongListCacheExtent,
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
