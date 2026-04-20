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

  Future<void> removeDownloadedTrack(String trackId) async {
    await _repository.removeDownloadedTrack(trackId);
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
    final itemData = <DownloadTaskListItemData>[];
    for (final task in tasks) {
      itemData.add(
        DownloadTaskListItemData(
          task: task,
          track: await _libraryRepository.getTrack(task.trackId),
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
