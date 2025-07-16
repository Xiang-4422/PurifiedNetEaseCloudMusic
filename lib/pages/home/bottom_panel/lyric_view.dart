import 'dart:ui';

import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/home/bottom_panel/bottom_panel_view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../common/constants/appConstants.dart';

// TODO YU4422 歌词换行、歌词丝滑缩放
class LyricView extends GetView<AppController> {
  final EdgeInsetsGeometry lyricPadding;

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
        child: Obx(() => ScrollablePositionedList.builder(
            itemScrollController: controller.lyricScrollController,
            itemCount: controller.lyricsLineModels.length + 2,
            itemBuilder: (BuildContext context, int index) {
              Widget child;
              bool isLyric = false;
              // 首尾占位，让当前歌词行能够在固定位置显示
              if (index == 0 || index == controller.lyricsLineModels.length + 1) {
                child = Container(height: context.height * (index == 0 ? 0.4 : 0.6));
              } else {
                isLyric = true;
                index -= 1;
                String mainText = (controller.lyricsLineModels[index].mainText ?? '').trim();
                if (mainText.isEmpty) {mainText = '···';}
                String extText = (controller.lyricsLineModels[index].extText ?? '').trim();
                if (extText.isNotEmpty) extText = '\n$extText';
                child = Obx((){
                  bool isActive = controller.currLyricIndex.value == index;
                  return AnimatedDefaultTextStyle(
                    style: context.theme.textTheme.titleLarge!.copyWith(
                      fontFamily: 'monospace', // 指定使用系统等宽字体
                      color: controller.panelWidgetColor.value.withOpacity(isActive ? 1 : 0.2),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                    curve: Curves.decelerate,
                    textAlign: TextAlign.start,
                    duration: const Duration(milliseconds: 500),
                    child: Text(mainText + extText),
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
                onPressed: () => controller.isAlbumVisible.value = true,
                onLongPress: () {
                  if (isLyric) {
                    controller.audioHandler.seek(Duration(milliseconds: controller.lyricsLineModels[index].startTime!));
                  }
                },
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}