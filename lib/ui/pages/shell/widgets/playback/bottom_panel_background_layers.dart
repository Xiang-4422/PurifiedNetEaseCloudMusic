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
    super.key,
    required this.controller,
  });

  /// 壳层控制器，提供底部面板展开动画。
  final ShellController controller;

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
            color: SettingsController.to.albumColor.value.withValues(
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
class BottomPanelContentFadeMask extends GetView<ShellController> {
  /// 创建内容渐隐遮罩。
  const BottomPanelContentFadeMask({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Offstage(
        offstage: controller.bottomPanelFullyOpened.isFalse,
        child: Column(
          children: [
            _FadeBand(
              colors: [
                SettingsController.to.albumColor.value,
                SettingsController.to.albumColor.value.withValues(alpha: 0),
              ],
            ),
            Expanded(child: Container()),
            _FadeBand(
              colors: [
                SettingsController.to.albumColor.value.withValues(alpha: 0),
                SettingsController.to.albumColor.value,
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
