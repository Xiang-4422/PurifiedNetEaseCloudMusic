import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_search_widgets.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/my_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 跟随顶部搜索面板开合动画变化的模糊背景层。
///
/// 搜索面板主视图将它放在最底层，用于在展开搜索时强化面板背景并弱化底层页面干扰。
class TopPanelBackgroundLayer extends StatelessWidget {
  /// 使用 [controller] 读取顶部搜索面板的开合动画。
  const TopPanelBackgroundLayer({
    super.key,
    required this.controller,
  });

  /// 提供顶部搜索面板开合动画的壳层控制器。
  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.topPanelAnimationController,
      builder: (BuildContext context, Widget? child) {
        final panelOpenDegree = controller.topPanelAnimationController.value;
        return BlurryContainer(
          blur: 15 * panelOpenDegree,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.zero,
          color: context.theme.colorScheme.primary.withValues(
            alpha: panelOpenDegree,
          ),
          child: Container(),
        );
      },
    );
  }
}

/// 顶部搜索面板底部的固定控制区。
///
/// 组合搜索分类 tab 和输入框，保持搜索内容区只关注热词、结果和空状态展示。
class TopPanelBottomControls extends StatelessWidget {
  /// 使用 [controller] 控制分类 tab 显隐并绑定搜索输入。
  const TopPanelBottomControls({
    super.key,
    required this.controller,
  });

  /// 提供搜索关键词和分类 tab 可见状态的壳层控制器。
  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.onPrimary.withValues(alpha: 0.1),
      child: Column(
        children: [
          _TopPanelSearchCategoryTabs(controller: controller),
          TopPanelSearchBar(
            controller: controller,
            height: AppDimensions.appBarHeight * 2 / 3,
          ),
        ],
      ),
    );
  }
}

/// 顶部搜索面板底部的键盘高度占位。
///
/// 面板关闭时保留顶部安全区和 app bar 高度；面板展开输入时跟随键盘高度撑开底部空间。
class TopPanelKeyboardSpacer extends StatelessWidget {
  /// 使用 [controller] 读取键盘高度和面板闭合状态。
  const TopPanelKeyboardSpacer({
    super.key,
    required this.controller,
  });

  /// 提供键盘高度和顶部面板闭合状态的壳层控制器。
  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: controller.topPanelFullyClosed.isTrue ? AppDimensions.appBarHeight + context.mediaQueryPadding.top : controller.keyBoardHeight.value,
      ),
    );
  }
}

class _TopPanelSearchCategoryTabs extends StatelessWidget {
  const _TopPanelSearchCategoryTabs({
    required this.controller,
  });

  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Offstage(
        offstage: controller.searchContent.value.isEmpty,
        child: const MyTabBar(
          height: AppDimensions.appBarHeight / 3,
          tabs: [
            _SearchTabLabel('单曲'),
            _SearchTabLabel('歌单'),
            _SearchTabLabel('专辑'),
            _SearchTabLabel('歌手'),
          ],
        ),
      ),
    );
  }
}

class _SearchTabLabel extends StatelessWidget {
  const _SearchTabLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.titleMedium?.copyWith(
        color: context.theme.colorScheme.onPrimary.withValues(alpha: 0.5),
      ),
    );
  }
}
