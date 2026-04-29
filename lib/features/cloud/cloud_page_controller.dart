import 'dart:async';

import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CloudPageController {
  CloudPageController({
    required CloudRepository repository,
    required String userId,
    required List<int> likedSongIds,
    this.pageSize = 30,
  })  : _repository = repository,
        _userId = userId,
        _likedSongIds = likedSongIds;

  factory CloudPageController.currentUser({int pageSize = 30}) {
    return CloudPageController(
      repository: Get.find<CloudRepository>(),
      userId: UserSessionController.to.userInfo.value.userId,
      likedSongIds: UserLibraryController.to.likedSongIds.toList(),
      pageSize: pageSize,
    );
  }

  final CloudRepository _repository;
  final String _userId;
  final List<int> _likedSongIds;
  final int pageSize;
  final ValueNotifier<PagedState<PlaybackQueueItem>> state =
      ValueNotifier(PagedState.initialLoading());

  int _offset = 0;

  Future<void> loadInitial() async {
    if (_userId.isEmpty) {
      state.value = const PagedState(items: [], hasMore: false);
      return;
    }
    final cachedSongs = await _repository.loadCachedSongs(
      userId: _userId,
      likedSongIds: _likedSongIds,
    );
    if (cachedSongs.isNotEmpty) {
      _offset = cachedSongs.length;
      state.value = PagedState.data(
        cachedSongs,
        hasMore: true,
      );
      unawaited(refresh());
      return;
    }
    state.value = PagedState.initialLoading();
    await _reload();
  }

  Future<bool> refresh() async {
    state.value = state.value.copyWith(
      refreshing: true,
      error: null,
    );
    return _reload();
  }

  Future<bool> loadMore() async {
    final currentState = state.value;
    if (currentState.loadingMore || !currentState.hasMore) {
      return true;
    }
    state.value = currentState.copyWith(
      loadingMore: true,
      error: null,
    );
    try {
      final page = await _repository.fetchCloudSongs(
        userId: _userId,
        offset: _offset,
        limit: pageSize,
        likedSongIds: _likedSongIds,
      );
      _offset = page.nextOffset;
      state.value = PagedState(
        items: [...currentState.items, ...page.items],
        hasMore: page.hasMore,
      );
      return true;
    } catch (error, stackTrace) {
      state.value = currentState.copyWith(
        loadingMore: false,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _reload() async {
    try {
      final page = await _repository.fetchCloudSongs(
        userId: _userId,
        offset: 0,
        limit: pageSize,
        likedSongIds: _likedSongIds,
      );
      _offset = page.nextOffset;
      state.value = PagedState.data(
        page.items,
        hasMore: page.hasMore,
      );
      return true;
    } catch (error, stackTrace) {
      state.value = PagedState.error(
        error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void dispose() {
    state.dispose();
  }
}
