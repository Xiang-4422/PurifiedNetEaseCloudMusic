import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/lyrics/lyrics_reader_model.dart';
import 'package:bujuan/features/playback/lyric_scroll_position.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:flutter/material.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';

import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// TODO YU4422 逐字歌词进度和播放态缩放。
/// 底部播放面板中的歌词列表视图。
class LyricView extends GetView<ShellController> {
  /// 歌词行按钮的内边距。
  final EdgeInsetsGeometry lyricPadding;

  /// 创建歌词列表视图。
  const LyricView(this.lyricPadding, {super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      // 监听滚动状态
      onNotification: (notification) {
        // 判断滚动是否是用户手势触发
        if (notification is ScrollStartNotification) {
          if (notification.dragDetails != null && !controller.isLyricScrollingByItself) {
            controller.isLyricScrollingByUser = true;
          }
          // 滚动结束时重置用户滚动状态 (这里只是一个辅助，主要靠计时器)
        } else if (notification is ScrollEndNotification) {
          controller.isLyricScrollingByUser = false;
          controller.isLyricScrollingByItself = false;
        }
        // 返回 false 让通知继续冒泡，以便 itemPositionsNotifier 也能收到
        return false;
      },
      child: ScrollConfiguration(
        behavior: const NoGlowScrollBehavior(),
        child: Obx(
          () {
            final lyricState = PlayerController.to.lyricState.value;
            return LayoutBuilder(
              builder: (context, constraints) {
                final viewportHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : MediaQuery.sizeOf(context).height;
                return ScrollablePositionedList.builder(
                  itemScrollController: controller.lyricScrollController,
                  itemCount: lyricState.lines.length + 2,
                  itemBuilder: (BuildContext context, int index) {
                    Widget child;
                    // 首尾占位按歌词区域真实高度计算，保证滚动锚点稳定。
                    if (index == 0 || index == lyricState.lines.length + 1) {
                      child = SizedBox(
                        height: viewportHeight * (index == 0 ? LyricScrollPosition.activeLineAlignment : 1 - LyricScrollPosition.activeLineAlignment),
                      );
                    } else {
                      index -= LyricScrollPosition.lyricItemIndexOffset;
                      final line = lyricState.lines[index];
                      child = Obx(() {
                        final isActive = PlayerController.to.lyricState.value.currentIndex == index;
                        return LyricLineText(
                          line: line,
                          isActive: isActive,
                          color: SettingsController.to.panelWidgetColor.value,
                          baseStyle: context.theme.textTheme.titleLarge,
                        );
                      });
                    }
                    // 构建歌词行
                    return TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: lyricPadding,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: null,
                      // 歌词逐行跳播和外层手势存在冲突，否则会同时触发面板滑动和歌词定位。
                      child: child,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// 单行歌词文本，负责占位、翻译拼接和稳定换行。
@visibleForTesting
class LyricLineText extends StatelessWidget {
  /// 创建单行歌词文本。
  const LyricLineText({
    required this.line,
    required this.isActive,
    required this.color,
    this.baseStyle,
    super.key,
  });

  /// 当前歌词行。
  final LyricsLineModel line;

  /// 是否为当前播放行。
  final bool isActive;

  /// 歌词基准颜色。
  final Color color;

  /// 页面传入的基础文字样式。
  final TextStyle? baseStyle;

  @override
  Widget build(BuildContext context) {
    final style = (baseStyle ?? Theme.of(context).textTheme.titleLarge ?? const TextStyle()).copyWith(
      fontFamily: 'monospace',
      color: color.withValues(alpha: isActive ? 1 : 0.2),
      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      height: 1.25,
    );
    return AnimatedDefaultTextStyle(
      style: style,
      curve: Curves.decelerate,
      textAlign: TextAlign.start,
      duration: const Duration(milliseconds: 500),
      child: Text(
        lyricLineDisplayText(line),
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.start,
        textWidthBasis: TextWidthBasis.parent,
      ),
    );
  }
}

/// 生成单行歌词展示文本。
@visibleForTesting
String lyricLineDisplayText(LyricsLineModel line) {
  final mainText = (line.mainText ?? '').trim();
  final extText = (line.extText ?? '').trim();
  final primaryText = mainText.isEmpty ? '···' : mainText;
  if (extText.isEmpty) {
    return primaryText;
  }
  return '$primaryText\n$extText';
}
