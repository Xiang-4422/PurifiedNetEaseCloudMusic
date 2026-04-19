import 'package:bujuan/data/netease/api/src/api/dj/bean.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:flutter/foundation.dart';

class RadioDetailController {
  RadioDetailController({
    required this.radioId,
    RadioRepository? repository,
    this.pageSize = 30,
    this.asc = true,
  }) : _repository = repository ?? RadioRepository();

  final String radioId;
  final RadioRepository _repository;
  final int pageSize;
  final bool asc;
  final ValueNotifier<PagedState<DjProgram>> state =
      ValueNotifier(PagedState.initialLoading());

  int _offset = 0;

  Future<void> loadInitial() async {
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
