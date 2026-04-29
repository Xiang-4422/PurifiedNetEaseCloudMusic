import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/widget/data_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return loadingView ?? const LoadingView();
    }
    if (state.hasError) {
      return errorView ?? const ErrorView();
    }
    if (state.isEmpty || state.data == null) {
      return emptyView ?? const EmptyView();
    }
    return builder(state.data as T);
  }
}
