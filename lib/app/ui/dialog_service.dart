import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// 应用弹窗服务，集中提供跨页面使用的对话框能力。
class DialogService {
  const DialogService._();

  /// 展示全屏加载弹窗。
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/lottie/empty_status.json',
          width: 750 / 4,
          height: 750 / 4,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
