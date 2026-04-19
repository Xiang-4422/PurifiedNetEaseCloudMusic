import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:flutter/foundation.dart';

/// 顶部搜索面板只需要维护一次热搜加载状态，单独拆出来可以避免页面在
/// build 阶段继续构造请求描述，也能避免同一面板反复触发首屏请求。
class SearchPanelController {
  SearchPanelController({SearchRepository? repository})
      : _repository = repository ?? SearchRepository();

  final SearchRepository _repository;
  final ValueNotifier<LoadState<List<String>>> hotKeywordState =
      ValueNotifier(const LoadState.loading());

  bool _loadedOnce = false;

  Future<void> loadInitial({bool force = false}) async {
    if (_loadedOnce && !force) {
      return;
    }
    hotKeywordState.value = const LoadState.loading();
    try {
      final keywords = await _repository.fetchHotKeywords();
      hotKeywordState.value =
          keywords.isEmpty ? const LoadState.empty() : LoadState.data(keywords);
      _loadedOnce = true;
    } catch (error, stackTrace) {
      hotKeywordState.value = LoadState.error(error, stackTrace: stackTrace);
    }
  }

  void dispose() {
    hotKeywordState.dispose();
  }
}
