import 'dart:async';

import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/radio_data.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:flutter/foundation.dart';

class RadioDetailController {
  RadioDetailController({
    required this.radioId,
    required String userId,
    required RadioRepository repository,
    this.pageSize = 30,
    this.asc = true,
  })  : _userId = userId,
        _repository = repository;

  final String radioId;
  final String _userId;
  final RadioRepository _repository;
  final int pageSize;
  final bool asc;
  final ValueNotifier<PagedState<RadioProgramData>> state =
      ValueNotifier(PagedState.initialLoading());

  int _offset = 0;

  Future<void> loadInitial() async {
    if (_userId.isEmpty) {
      state.value = const PagedState(items: [], hasMore: false);
      return;
    }
    final cachedItems = await _repository.loadCachedPrograms(
      _userId,
      radioId,
      asc: asc,
    );
    if (cachedItems.isNotEmpty) {
      _offset = cachedItems.length;
      state.value = PagedState.data(
        cachedItems,
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
      final page = await _repository.fetchPrograms(
        _userId,
        radioId,
        offset: _offset,
        limit: pageSize,
        asc: asc,
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
      final page = await _repository.fetchPrograms(
        _userId,
        radioId,
        offset: 0,
        limit: pageSize,
        asc: asc,
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
