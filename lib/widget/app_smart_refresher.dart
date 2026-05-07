import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 应用统一的无回弹上拉加载组件。
class AppSmartRefresher extends StatelessWidget {
  /// 创建应用统一的上拉加载容器。
  const AppSmartRefresher({
    super.key,
    required this.controller,
    required this.child,
    this.enablePullUp = false,
    this.onLoading,
    this.footer,
  });

  /// 刷新控制器。
  final RefreshController controller;

  /// 滚动内容。
  final Widget child;

  /// 是否开启上拉加载。
  final bool enablePullUp;

  /// 上拉加载回调。
  final VoidCallback? onLoading;

  /// 自定义 footer。
  final LoadIndicator? footer;

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      maxOverScrollExtent: 0,
      maxUnderScrollExtent: 0,
      child: SmartRefresher(
        physics: const ClampingScrollPhysics(),
        enablePullDown: false,
        enablePullUp: enablePullUp,
        controller: controller,
        footer: footer ?? loadingFooter(),
        onLoading: onLoading,
        child: child,
      ),
    );
  }
}

/// 创建统一的上拉加载 footer。
CustomFooter loadingFooter({Widget idleWidget = const SizedBox.shrink()}) {
  return CustomFooter(
    builder: (context, mode) {
      if (mode == LoadStatus.loading) {
        return const SizedBox(height: 60, child: LoadingView());
      }
      return idleWidget;
    },
  );
}
