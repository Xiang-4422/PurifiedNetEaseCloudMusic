import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/download/download_task_list_controller.dart';
import 'package:bujuan/widget/common_widgets.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/load_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class DownloadTaskPageView extends StatefulWidget {
  const DownloadTaskPageView({super.key});

  @override
  State<DownloadTaskPageView> createState() => _DownloadTaskPageViewState();
}

class _DownloadTaskPageViewState extends State<DownloadTaskPageView>
    with SingleTickerProviderStateMixin {
  static const _cancelActiveAction = 'cancel_active';
  static const _retryFailedAction = 'retry_failed';
  static const _clearFailedAction = 'clear_failed';
  static const _removeDownloadedAction = 'remove_downloaded';
  static const _clearCompletedAction = 'clear_completed';

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('下载管理'),
          actions: [
            PopupMenuButton<String>(
              tooltip: '批量操作',
              onSelected: _handleBulkAction,
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: _cancelActiveAction,
                  child: Text('取消全部进行中任务'),
                ),
                PopupMenuItem<String>(
                  value: _retryFailedAction,
                  child: Text('重试全部失败任务'),
                ),
                PopupMenuItem<String>(
                  value: _clearFailedAction,
                  child: Text('清除失败记录'),
                ),
                PopupMenuItem<String>(
                  value: _removeDownloadedAction,
                  child: Text('删除全部已下载文件'),
                ),
                PopupMenuItem<String>(
                  value: _clearCompletedAction,
                  child: Text('清除已完成记录'),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '全部'),
              Tab(text: '进行中'),
              Tab(text: '失败'),
              Tab(text: '已完成'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _DownloadTaskTabView(),
            _DownloadTaskTabView(
              statuses: {
                DownloadTaskStatus.queued,
                DownloadTaskStatus.downloading,
              },
            ),
            _DownloadTaskTabView(
              statuses: {
                DownloadTaskStatus.failed,
              },
            ),
            _DownloadTaskTabView(
              statuses: {
                DownloadTaskStatus.completed,
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBulkAction(String action) async {
    final requiresConfirmation = switch (action) {
      _cancelActiveAction => true,
      _clearFailedAction => true,
      _removeDownloadedAction => true,
      _clearCompletedAction => true,
      _retryFailedAction => false,
      _ => false,
    };
    if (requiresConfirmation) {
      final confirmed = await _confirmBulkAction(action);
      if (!confirmed) {
        return;
      }
    }

    final controller = DownloadTaskListController();
    try {
      switch (action) {
        case _cancelActiveAction:
          await controller.cancelActiveTasks();
          break;
        case _retryFailedAction:
          await controller.retryAllFailedTasks();
          break;
        case _clearFailedAction:
          await controller.clearFailedTasks();
          break;
        case _removeDownloadedAction:
          await controller.removeAllDownloadedTracks();
          break;
        case _clearCompletedAction:
          await controller.clearCompletedTasks();
          break;
      }
    } finally {
      controller.dispose();
    }
  }

  Future<bool> _confirmBulkAction(String action) async {
    final (title, content) = switch (action) {
      _cancelActiveAction => ('取消全部进行中任务', '这会停止当前排队中和下载中的任务。'),
      _clearFailedAction => ('清除失败记录', '这只会删除失败任务记录，不会删除本地文件。'),
      _removeDownloadedAction => ('删除全部已下载文件', '这会删除所有已下载的本地文件和对应下载记录。'),
      _clearCompletedAction => ('清除已完成记录', '这只会删除已完成任务记录，不会删除本地文件。'),
      _ => ('确认操作', '确定继续执行这个批量操作吗？'),
    };
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
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
    return result ?? false;
  }
}

class _DownloadTaskTabView extends StatefulWidget {
  const _DownloadTaskTabView({
    this.statuses,
  });

  final Set<DownloadTaskStatus>? statuses;

  @override
  State<_DownloadTaskTabView> createState() => _DownloadTaskTabViewState();
}

class _DownloadTaskTabViewState extends State<_DownloadTaskTabView> {
  late final DownloadTaskListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DownloadTaskListController(statuses: widget.statuses);
    _controller.loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoadState<List<DownloadTaskListItemData>>>(
      valueListenable: _controller.state,
      builder: (context, state, child) {
        return LoadStateView<List<DownloadTaskListItemData>>(
          state: state,
          emptyView: RefreshIndicator(
            onRefresh: _controller.refresh,
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
              onRefresh: _controller.refresh,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: AppDimensions.paddingSmall,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _DownloadTaskTile(
                    item: item,
                    onCancel: () => _controller.cancelTask(item.task.trackId),
                    onRetry: () => _controller.retryTask(item.task.trackId),
                    onRemoveDownloaded: () =>
                        _controller.removeDownloadedTrack(item.task.trackId),
                    onClear: () => _controller.clearTask(item.task.trackId),
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

class _DownloadTaskTile extends StatelessWidget {
  const _DownloadTaskTile({
    required this.item,
    required this.onCancel,
    required this.onRetry,
    required this.onRemoveDownloaded,
    required this.onClear,
  });

  final DownloadTaskListItemData item;
  final Future<void> Function() onCancel;
  final Future<void> Function() onRetry;
  final Future<void> Function() onRemoveDownloaded;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    final task = item.task;
    final track = item.track;
    final title = track?.title ?? task.trackId;
    final subtitle = _buildSubtitle(track, task);
    final progress = (task.progress ?? 0).clamp(0, 1).toDouble();

    return Material(
      color: Theme.of(context).cardColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingSmall / 2,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).hintColor,
          ),
        ),
        trailing: _buildTrailing(context, task, progress),
      ),
    );
  }

  String _buildSubtitle(Track? track, DownloadTask task) {
    final artist = track?.artistNames.join(' / ');
    final base = (artist?.isNotEmpty == true) ? artist! : task.trackId;
    switch (task.status) {
      case DownloadTaskStatus.queued:
        return '$base\n等待下载';
      case DownloadTaskStatus.downloading:
        return '$base\n下载中 ${(task.progress ?? 0) * 100 ~/ 1}%';
      case DownloadTaskStatus.completed:
        return '$base\n已下载到本地';
      case DownloadTaskStatus.failed:
        final reason = _readableFailureReason(task.failureReason);
        return '$base\n$reason';
    }
  }

  String _readableFailureReason(String? reason) {
    switch (reason) {
      case null:
      case '':
        return '下载失败';
      case 'download_interrupted':
        return '下载被中断，请重试';
      case 'playback_url_unavailable':
        return '当前无法获取播放地址';
      case 'track_not_found':
        return '本地未找到歌曲信息';
      default:
        return reason;
    }
  }

  Widget _buildTrailing(
    BuildContext context,
    DownloadTask task,
    double progress,
  ) {
    switch (task.status) {
      case DownloadTaskStatus.queued:
      case DownloadTaskStatus.downloading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularPlaybackProgress(
                    progress: progress <= 0 ? 0.04 : progress,
                    size: 40,
                    strokeWidth: 3,
                    progressColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .15),
                  ),
                  Text(
                    '${progress * 100 ~/ 1}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: '取消下载',
              onPressed: onCancel,
              icon: const Icon(TablerIcons.x),
            ),
          ],
        );
      case DownloadTaskStatus.completed:
        return IconButton(
          tooltip: '删除下载',
          onPressed: onRemoveDownloaded,
          icon: const Icon(TablerIcons.trash),
        );
      case DownloadTaskStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '重试下载',
              onPressed: onRetry,
              icon: const Icon(TablerIcons.refresh),
            ),
            IconButton(
              tooltip: '清除记录',
              onPressed: onClear,
              icon: const Icon(TablerIcons.x),
            ),
          ],
        );
    }
  }
}
