import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:flutter/foundation.dart';

import 'download_repository.dart';

class DownloadTaskListController {
  DownloadTaskListController({
    DownloadRepository? repository,
    this.statuses,
  }) : _repository = repository ?? DownloadRepository();

  final DownloadRepository _repository;
  final Set<DownloadTaskStatus>? statuses;
  final ValueNotifier<LoadState<List<DownloadTask>>> state =
      ValueNotifier(const LoadState.loading());

  Future<void> loadInitial() async {
    state.value = const LoadState.loading();
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
      final tasks = await _repository.getTasks(statuses: statuses);
      if (tasks.isEmpty) {
        state.value = const LoadState.empty();
        return;
      }
      state.value = LoadState.data(tasks);
    } catch (error, stackTrace) {
      state.value = LoadState.error(
        error,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    state.dispose();
  }
}
