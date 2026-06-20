import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/lyrics/lyrics_reader_model.dart';
import 'package:bujuan/features/playback/lyric_scroll_position.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:flutter/material.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';

import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
                        final currentPosition = isActive ? PlayerController.to.currentPositionState.value : Duration.zero;
                        return LyricLineText(
                          line: line,
                          isActive: isActive,
                          currentPosition: currentPosition,
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
    this.currentPosition = Duration.zero,
    this.baseStyle,
    super.key,
  });

  /// 当前歌词行。
  final LyricsLineModel line;

  /// 是否为当前播放行。
  final bool isActive;

  /// 歌词基准颜色。
  final Color color;

  /// 当前播放进度，仅当前行使用。
  final Duration currentPosition;

  /// 页面传入的基础文字样式。
  final TextStyle? baseStyle;

  @override
  Widget build(BuildContext context) {
    final inheritedStyle = baseStyle ?? Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    final fontSize = inheritedStyle.fontSize;
    final style = inheritedStyle.copyWith(
      fontFamily: 'monospace',
      color: color.withValues(alpha: isActive ? 1 : 0.2),
      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      fontSize: fontSize == null ? null : fontSize * (isActive ? 1.06 : 1),
      height: 1.25,
    );
    final progressText = isActive ? lyricLineProgressText(line, currentPosition) : const LyricLineProgressText.empty();
    return AnimatedDefaultTextStyle(
      style: style,
      curve: Curves.decelerate,
      textAlign: TextAlign.start,
      duration: const Duration(milliseconds: 500),
      child: progressText.hasProgress ? _buildProgressText(style, progressText) : _buildPlainText(line),
    );
  }

  Widget _buildPlainText(LyricsLineModel line) {
    return Text(
      lyricLineDisplayText(line),
      softWrap: true,
      maxLines: null,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
      textWidthBasis: TextWidthBasis.parent,
    );
  }

  Widget _buildProgressText(
    TextStyle style,
    LyricLineProgressText progressText,
  ) {
    final children = <InlineSpan>[
      TextSpan(
        text: progressText.playedText,
        style: style.copyWith(
          color: color.withValues(alpha: 1),
          fontWeight: FontWeight.bold,
        ),
      ),
      TextSpan(
        text: progressText.upcomingText,
        style: style.copyWith(
          color: color.withValues(alpha: 0.42),
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
    final extText = (line.extText ?? '').trim();
    if (extText.isNotEmpty) {
      children.add(
        TextSpan(
          text: '\n$extText',
          style: style.copyWith(
            color: color.withValues(alpha: 0.68),
            fontSize: style.fontSize == null ? null : style.fontSize! * 0.86,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }
    return Text.rich(
      TextSpan(children: children),
      softWrap: true,
      maxLines: null,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
      textWidthBasis: TextWidthBasis.parent,
    );
  }
}

/// 单行逐字歌词展示文本切分结果。
@visibleForTesting
class LyricLineProgressText {
  /// 创建逐字歌词展示文本切分结果。
  const LyricLineProgressText({
    required this.playedText,
    required this.upcomingText,
  });

  /// 空结果。
  const LyricLineProgressText.empty()
      : playedText = '',
        upcomingText = '';

  /// 已经播放到的片段文本。
  final String playedText;

  /// 尚未播放到的片段文本。
  final String upcomingText;

  /// 是否包含可用于逐字展示的文本。
  bool get hasProgress => playedText.isNotEmpty || upcomingText.isNotEmpty;
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

/// 根据当前播放进度切分逐字歌词中已播放和未播放的片段。
@visibleForTesting
LyricLineProgressText lyricLineProgressText(
  LyricsLineModel line,
  Duration currentPosition,
) {
  final mainText = (line.mainText ?? '').trim();
  final spans = line.spanList;
  if (mainText.isEmpty || spans == null || spans.isEmpty) {
    return const LyricLineProgressText.empty();
  }
  final targetMs = currentPosition.inMilliseconds;
  final played = StringBuffer();
  final upcoming = StringBuffer();
  for (final span in spans) {
    final text = _spanText(mainText, span);
    if (text.isEmpty) {
      continue;
    }
    if (targetMs >= span.start) {
      played.write(text);
    } else {
      upcoming.write(text);
    }
  }
  return LyricLineProgressText(
    playedText: played.toString(),
    upcomingText: upcoming.toString(),
  );
}

String _spanText(String mainText, LyricSpanInfo span) {
  if (span.raw.isNotEmpty) {
    return span.raw;
  }
  if (span.index < 0 || span.length <= 0 || span.index >= mainText.length) {
    return '';
  }
  final end = span.endIndex > mainText.length ? mainText.length : span.endIndex;
  if (end <= span.index) {
    return '';
  }
  return mainText.substring(span.index, end);
}
