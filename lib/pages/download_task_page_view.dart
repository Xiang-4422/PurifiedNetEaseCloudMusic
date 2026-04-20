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

class _DownloadTaskPageViewState extends State<DownloadTaskPageView> {
  late final DownloadTaskListController _controller;
  static const _retryFailedAction = 'retry_failed';
  static const _clearFailedAction = 'clear_failed';
  static const _clearCompletedAction = 'clear_completed';

  @override
  void initState() {
    super.initState();
    _controller = DownloadTaskListController();
    _controller.loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理'),
        actions: [
          ValueListenableBuilder<LoadState<List<DownloadTaskListItemData>>>(
            valueListenable: _controller.state,
            builder: (context, state, child) {
              if (!state.hasData) {
                return const SizedBox.shrink();
              }

              final items = state.data!;
              final hasFailed = items.any(
                (item) => item.task.status == DownloadTaskStatus.failed,
              );
              final hasCompleted = items.any(
                (item) => item.task.status == DownloadTaskStatus.completed,
              );
              if (!hasFailed && !hasCompleted) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                tooltip: '批量操作',
                onSelected: _handleBulkAction,
                itemBuilder: (context) => [
                  if (hasFailed)
                    const PopupMenuItem<String>(
                      value: _retryFailedAction,
                      child: Text('重试全部失败任务'),
                    ),
                  if (hasFailed)
                    const PopupMenuItem<String>(
                      value: _clearFailedAction,
                      child: Text('清除失败记录'),
                    ),
                  if (hasCompleted)
                    const PopupMenuItem<String>(
                      value: _clearCompletedAction,
                      child: Text('清除已完成记录'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<LoadState<List<DownloadTaskListItemData>>>(
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
      ),
    );
  }

  Future<void> _handleBulkAction(String action) async {
    switch (action) {
      case _retryFailedAction:
        await _controller.retryAllFailedTasks();
        break;
      case _clearFailedAction:
        await _controller.clearFailedTasks();
        break;
      case _clearCompletedAction:
        await _controller.clearCompletedTasks();
        break;
    }
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
        final reason = task.failureReason?.isNotEmpty == true
            ? task.failureReason!
            : '下载失败';
        return '$base\n$reason';
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
