import 'dart:async';

import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:flutter/material.dart';

/// 根据 LoadState 展示加载、错误、空态或内容组件。
class LoadStateView<T> extends StatelessWidget {
  /// 创建 LoadState 视图。
  const LoadStateView({
    super.key,
    required this.state,
    required this.builder,
    this.loadingView,
    this.emptyView,
    this.errorView,
    this.onRetry,
  });

  /// 当前加载状态。
  final LoadState<T> state;

  /// 有数据时的内容构建器。
  final Widget Function(T data) builder;

  /// 自定义加载态组件。
  final Widget? loadingView;

  /// 自定义空态组件。
  final Widget? emptyView;

  /// 自定义错误态组件。
  final Widget? errorView;

  /// 默认错误态的重试回调。
  final FutureOr<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    if (data != null) {
      return builder(data);
    }
    if (state.isLoading) {
      return loadingView ?? const LoadingView();
    }
    if (state.hasError) {
      return errorView ?? ErrorView(onRetry: onRetry == null ? null : _retry);
    }
    if (state.isEmpty) {
      return emptyView ?? const EmptyView();
    }
    return emptyView ?? const EmptyView();
  }

  void _retry() {
    final onRetry = this.onRetry;
    if (onRetry == null) {
      return;
    }
    unawaited(Future<void>.sync(onRetry));
  }
}
