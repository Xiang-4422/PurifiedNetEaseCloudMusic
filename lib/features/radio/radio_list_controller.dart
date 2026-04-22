import 'dart:async';

import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/features/radio/radio_data.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:flutter/foundation.dart';

class RadioListController {
  RadioListController({
    required String userId,
    RadioRepository? repository,
    this.pageSize = 30,
  })  : _userId = userId,
        _repository = repository ?? RadioRepository();

  final String _userId;
  final RadioRepository _repository;
  final int pageSize;
  final ValueNotifier<PagedState<RadioSummaryData>> state =
      ValueNotifier(PagedState.initialLoading());

  int _offset = 0;

  Future<void> loadInitial() async {
    if (_userId.isEmpty) {
      state.value = const PagedState(items: [], hasMore: false);
      return;
    }
    final cachedItems = await _repository.loadCachedSubscribedRadios(_userId);
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
      final page = await _repository.fetchSubscribedRadios(
        userId: _userId,
        offset: _offset,
        limit: pageSize,
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
      final page = await _repository.fetchSubscribedRadios(
        userId: _userId,
        offset: 0,
        limit: pageSize,
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
