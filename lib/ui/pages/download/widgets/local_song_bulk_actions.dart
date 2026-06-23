import 'package:flutter/material.dart';

/// 本地歌曲页批量操作菜单。
class LocalSongBulkActions extends StatelessWidget {
  /// 创建本地歌曲页批量操作菜单。
  const LocalSongBulkActions({
    super.key,
    required this.onClearPlaybackCache,
  });

  static const _clearPlaybackCacheAction = 'clear_playback_cache';

  /// 清理播放缓存动作。
  final Future<void> Function() onClearPlaybackCache;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '批量操作',
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: _clearPlaybackCacheAction,
          child: Text('删除所有缓存'),
        ),
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
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
    if (confirmed == true) {
      await onClearPlaybackCache();
    }
  }
}
