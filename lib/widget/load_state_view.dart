import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';

/// LoadStateView。
class LoadStateView<T> extends StatelessWidget {
  /// 创建 LoadStateView。
  const LoadStateView({
    super.key,
    required this.state,
    required this.builder,
    this.loadingView,
    this.emptyView,
    this.errorView,
  });

  /// state。
  final LoadState<T> state;

  /// Function。
  final Widget Function(T data) builder;

  /// loadingView。
  final Widget? loadingView;

  /// emptyView。
  final Widget? emptyView;

  /// errorView。
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
