import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'download_repository.dart';

/// 下载任务列表展示项，合并任务状态和可选曲目信息。
class DownloadTaskListItemData {
  /// 创建下载任务列表展示项。
  const DownloadTaskListItemData({
    required this.task,
    this.track,
  });

  /// 下载任务状态。
  final DownloadTask task;

  /// 任务对应的曲目信息，曲库缺失时为空。
  final Track? track;
}

/// 下载任务列表控制器。
class DownloadTaskListController {
  /// 创建下载任务列表控制器。
  DownloadTaskListController({
    required DownloadRepository repository,
    required LibraryRepository libraryRepository,
    this.statuses,
  })  : _repository = repository,
        _libraryRepository = libraryRepository;

  final DownloadRepository _repository;
  final LibraryRepository _libraryRepository;

  /// 当前列表需要展示的任务状态集合。
  final Set<DownloadTaskStatus>? statuses;
  StreamSubscription<List<DownloadTask>>? _tasksSubscription;

  /// 下载任务列表加载状态。
  final ValueNotifier<LoadState<List<DownloadTaskListItemData>>> state =
      ValueNotifier(const LoadState.loading());

  /// 首次加载任务列表并订阅任务变化。
  Future<void> loadInitial() async {
    state.value = const LoadState.loading();
    await _tasksSubscription?.cancel();
    _tasksSubscription = _repository
        .watchTasks(statuses: statuses)
        .listen(_publishTasks, onError: (error, stackTrace) {
      state.value = LoadState.error(
        error,
        stackTrace: stackTrace is StackTrace ? stackTrace : null,
      );
    });
    await _reload();
  }

  /// 重新加载当前任务列表。
  Future<void> refresh() {
    return _reload();
  }

  /// 重试指定任务。
  Future<void> retryTask(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    await _repository.retryTask(
      trackId,
      preferHighQuality: preferHighQuality,
    );
    await _reload();
  }

  /// 清除指定任务记录。
  Future<void> clearTask(String trackId) async {
    await _repository.clearTask(trackId);
    await _reload();
  }

  /// 取消指定任务。
  Future<void> cancelTask(String trackId) async {
    await _repository.cancelTask(trackId);
    await _reload();
  }

  /// 取消全部排队中和下载中的任务。
  Future<void> cancelActiveTasks() async {
    final activeTasks = await _repository.getTasks(
      statuses: const {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      },
    );
    for (final task in activeTasks) {
      await _repository.cancelTask(task.trackId);
    }
    await _reload();
  }

  /// 删除指定曲目的下载资源。
  Future<void> removeDownloadedTrack(String trackId) async {
    await _repository.removeDownloadedTrack(trackId);
    await _reload();
  }

  /// 重试全部失败任务。
  Future<void> retryAllFailedTasks({
    bool preferHighQuality = true,
  }) async {
    final failedTasks = await _repository.getTasks(
      statuses: const {
        DownloadTaskStatus.failed,
      },
    );
    for (final task in failedTasks) {
      await _repository.retryTask(
        task.trackId,
        preferHighQuality: preferHighQuality,
      );
    }
    await _reload();
  }

  /// 清除全部失败任务记录。
  Future<void> clearFailedTasks() async {
    final failedTasks = await _repository.getTasks(
      statuses: const {
        DownloadTaskStatus.failed,
      },
    );
    for (final task in failedTasks) {
      await _repository.clearTask(task.trackId);
    }
    await _reload();
  }

  /// 清除全部已完成任务记录。
  Future<void> clearCompletedTasks() async {
    final completedTasks = await _repository.getTasks(
      statuses: const {
        DownloadTaskStatus.completed,
      },
    );
    for (final task in completedTasks) {
      await _repository.clearTask(task.trackId);
    }
    await _reload();
  }

  /// 删除全部已完成下载的曲目资源。
  Future<void> removeAllDownloadedTracks() async {
    final completedTasks = await _repository.getTasks(
      statuses: const {
        DownloadTaskStatus.completed,
      },
    );
    for (final task in completedTasks) {
      await _repository.removeDownloadedTrack(task.trackId);
    }
    await _reload();
  }

  Future<void> _reload() async {
    try {
      await _publishTasks(await _repository.getTasks(statuses: statuses));
    } catch (error, stackTrace) {
      state.value = LoadState.error(
        error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _publishTasks(List<DownloadTask> tasks) async {
    if (tasks.isEmpty) {
      state.value = const LoadState.empty();
      return;
    }
    final tracksById = {
      for (final track in await _libraryRepository
          .getTracksByIds(tasks.map((task) => task.trackId)))
        track.id: track,
    };
    final itemData = <DownloadTaskListItemData>[];
    for (final task in tasks) {
      itemData.add(
        DownloadTaskListItemData(
          task: task,
          track: tracksById[task.trackId],
        ),
      );
    }
    state.value = LoadState.data(itemData);
  }

  /// 释放任务订阅和状态监听器。
  void dispose() {
    _tasksSubscription?.cancel();
    state.dispose();
  }
}
