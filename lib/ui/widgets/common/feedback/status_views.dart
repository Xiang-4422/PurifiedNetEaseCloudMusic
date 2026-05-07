import 'package:bujuan/generated/assets.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

/// 通用加载态视图。
class LoadingView extends StatelessWidget {
  /// 加载提示文本。
  final String? tips;

  /// 创建加载态视图。
  const LoadingView({Key? key, this.tips}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Lottie.asset(Assets.lottieLoading, height: MediaQuery.sizeOf(context).width / 3.5, fit: BoxFit.fitHeight, filterQuality: FilterQuality.low),
    );
  }
}

/// 通用空态视图。
class EmptyView extends StatelessWidget {
  /// 创建空态视图。
  const EmptyView({
    Key? key,
    this.message = '暂无数据',
    this.onRetry,
  }) : super(key: key);

  /// 空态提示文案。
  final String message;

  /// 重试回调。
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StatusMessageView(
      message: message,
      actionText: '重试',
      onAction: onRetry,
    );
  }
}

/// 通用错误态视图。
class ErrorView extends StatelessWidget {
  /// 创建错误态视图。
  const ErrorView({
    Key? key,
    this.message = '加载失败',
    this.onRetry,
  }) : super(key: key);

  /// 错误提示文案。
  final String message;

  /// 重试回调。
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StatusMessageView(
      message: message,
      actionText: '重试',
      onAction: onRetry,
    );
  }
}

class _StatusMessageView extends StatelessWidget {
  const _StatusMessageView({
    required this.message,
    required this.actionText,
    this.onAction,
  });

  final String message;
  final String actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onAction,
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}
