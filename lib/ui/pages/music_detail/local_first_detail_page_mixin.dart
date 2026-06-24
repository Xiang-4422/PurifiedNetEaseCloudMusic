import 'dart:async';

import 'package:bujuan/features/music_detail/local_first_detail_controller.dart';
import 'package:flutter/material.dart';

/// 本地优先详情页的页面状态机。
mixin LocalFirstDetailPageMixin<T extends StatefulWidget> on State<T> {
  /// 当前是否处于加载态。
  @protected
  bool detailLoading = true;

  /// 当前是否处于首次加载失败态。
  @protected
  bool detailLoadFailed = false;

  /// 是否已有可展示详情。
  @protected
  bool hasLoadedDetail = false;

  int _detailRefreshGeneration = 0;

  /// 执行本地优先初始加载；有本地详情时立即展示并后台刷新。
  @protected
  Future<void> loadInitialLocalFirstDetail<D>({
    required Future<LocalFirstDetailInitialData<D>> Function() loadInitialDetail,
    required void Function(D detail) applyDetail,
    required Future<void> Function({required bool showLoadingState}) refreshDetail,
    FutureOr<void> Function(D detail)? afterApply,
  }) async {
    final initialDetail = await loadInitialDetail();
    if (!mounted) {
      return;
    }
    final localDetail = initialDetail.localDetail;
    if (initialDetail.hasLocalDetail && localDetail != null) {
      setState(() {
        applyDetail(localDetail);
        _markDetailLoaded();
      });
      _runAfterApply(afterApply, localDetail);
      if (initialDetail.shouldRefreshInBackground) {
        unawaited(refreshDetail(showLoadingState: false));
      }
      return;
    }
    await refreshDetail(showLoadingState: true);
  }

  /// 执行远程刷新；已有数据时刷新失败只结束加载态，不清空页面。
  @protected
  Future<void> refreshLocalFirstDetail<D>({
    required bool showLoadingState,
    required Future<D> Function() fetchDetail,
    required void Function(D detail) applyDetail,
    FutureOr<void> Function(D detail)? afterApply,
  }) async {
    final generation = ++_detailRefreshGeneration;
    if (showLoadingState && mounted) {
      setState(() {
        detailLoading = true;
        detailLoadFailed = false;
      });
    }
    try {
      final detail = await fetchDetail();
      if (!mounted || generation != _detailRefreshGeneration) {
        return;
      }
      setState(() {
        applyDetail(detail);
        _markDetailLoaded();
      });
      _runAfterApply(afterApply, detail);
    } catch (_) {
      if (!mounted || generation != _detailRefreshGeneration) {
        return;
      }
      setState(() {
        detailLoading = false;
        detailLoadFailed = !hasLoadedDetail;
      });
    }
  }

  void _markDetailLoaded() {
    detailLoading = false;
    detailLoadFailed = false;
    hasLoadedDetail = true;
  }

  void _runAfterApply<D>(
    FutureOr<void> Function(D detail)? afterApply,
    D detail,
  ) {
    final result = afterApply?.call(detail);
    if (result is Future<void>) {
      unawaited(result);
    }
  }
}
