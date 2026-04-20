import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'download_repository.dart';

class DownloadTaskListItemData {
  const DownloadTaskListItemData({
    required this.task,
    this.track,
  });

  final DownloadTask task;
  final Track? track;
}

class DownloadTaskListController {
  DownloadTaskListController({
    DownloadRepository? repository,
    LibraryRepository? libraryRepository,
    this.statuses,
  })  : _repository = repository ?? DownloadRepository(),
        _libraryRepository = libraryRepository ?? LibraryRepository();

  final DownloadRepository _repository;
  final LibraryRepository _libraryRepository;
  final Set<DownloadTaskStatus>? statuses;
  StreamSubscription<List<DownloadTask>>? _tasksSubscription;
  final ValueNotifier<LoadState<List<DownloadTaskListItemData>>> state =
      ValueNotifier(const LoadState.loading());

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

  Future<void> refresh() {
    return _reload();
  }

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

  Future<void> clearTask(String trackId) async {
    await _repository.clearTask(trackId);
    await _reload();
  }

  Future<void> cancelTask(String trackId) async {
    await _repository.cancelTask(trackId);
    await _reload();
  }

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

  Future<void> removeDownloadedTrack(String trackId) async {
    await _repository.removeDownloadedTrack(trackId);
    await _reload();
  }

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
      for (final track
          in await _libraryRepository.getTracksByIds(tasks.map((task) => task.trackId)))
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

  void dispose() {
    _tasksSubscription?.cancel();
    state.dispose();
  }
}
