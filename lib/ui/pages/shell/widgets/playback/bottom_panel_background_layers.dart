import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部播放面板背景层，跟随展开程度调整圆角和背景色透明度。
class BottomPanelBackgroundLayer extends StatelessWidget {
  /// 创建底部播放面板背景层。
  const BottomPanelBackgroundLayer({
    required this.controller,
    required this.settingsController,
    super.key,
  });

  /// 壳层控制器，提供底部面板展开动画。
  final ShellController controller;

  /// 设置控制器，提供播放面板取色。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.bottomPanelAnimationController,
      builder: (BuildContext context, Widget? child) {
        final panelOpenDegree = controller.bottomPanelAnimationController.value;
        return Obx(
          () => BlurryContainer(
            blur: 20,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.all(
              Radius.circular(
                AppDimensions.phoneCornerRadius * (1 - panelOpenDegree),
              ),
            ),
            color: settingsController.albumColor.value.withValues(
              alpha: 0.5 + 0.5 * panelOpenDegree,
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}

/// 底部播放面板 PageView 的上下边缘渐隐遮罩。
class BottomPanelContentFadeMask extends StatelessWidget {
  /// 创建内容渐隐遮罩。
  const BottomPanelContentFadeMask({
    required this.shellController,
    required this.settingsController,
    super.key,
  });

  /// 壳层控制器，提供底部面板开合状态。
  final ShellController shellController;

  /// 设置控制器，提供播放面板取色。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Offstage(
        offstage: shellController.bottomPanelFullyOpened.isFalse,
        child: Column(
          children: [
            _FadeBand(
              colors: [
                settingsController.albumColor.value,
                settingsController.albumColor.value.withValues(alpha: 0),
              ],
            ),
            Expanded(child: Container()),
            _FadeBand(
              colors: [
                settingsController.albumColor.value.withValues(alpha: 0),
                settingsController.albumColor.value,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeBand extends StatelessWidget {
  const _FadeBand({
    required this.colors,
  });

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return Container(
      height: albumPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
    );
  }
}
