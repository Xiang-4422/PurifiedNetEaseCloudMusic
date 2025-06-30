import 'dart:ui';

import 'package:bujuan/pages/home/app_controller.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../common/constants/appConstants.dart';

// TODO YU4422 歌词换行、歌词丝滑缩放
class LyricView extends GetView<AppController> {
  const LyricView({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 判断滚动是否是用户手势触发
        if (notification is ScrollStartNotification) {
          // ScrollStartNotification 包含了 metrics 和 dragDetails
          // 如果 dragDetails 不为空，说明是用户拖动开始
          if (notification.dragDetails != null && !controller.isLyricScrollingByItself) {
            controller.isLyricScrollingByUser = true;
          }
        } else if (notification is ScrollEndNotification) {
          // 滚动结束时重置用户滚动状态 (这里只是一个辅助，主要靠计时器)
          controller.isLyricScrollingByUser = false;
          controller.isLyricScrollingByItself = false;
        }
        // 返回 true 表示通知已处理，阻止它冒泡到父级
        return false; // 返回 false 让通知继续冒泡，以便 itemPositionsNotifier 也能收到

      },
      child: Obx(() => ScrollablePositionedList.builder(
            key: ValueKey(controller.curMediaItem.value.title),
            itemScrollController: controller.lyricScrollController,
            itemCount: controller.lyricsLineModels.length + 2,
            itemBuilder: (BuildContext context, int index) {
              // 首尾占位，让当前歌词行能够在固定位置显示
              if (index == 0 || index == controller.lyricsLineModels.length + 1) {
                return Container(height: context.height * (index == 0 ? 0.4 : 0.6));
              }
              index -= 1;
              // 构建歌词行
              return TextButton(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (index == controller.currLyricIndex.value) {
                    controller.isAlbumVisible.value = !controller.isAlbumVisible.value;
                  } else {
                    controller.audioHandler.seek(Duration(milliseconds: controller.lyricsLineModels[index].startTime!));
                  }
                },
                child: Obx((){
                  bool isActive = controller.currLyricIndex.value == index;
                  String mainText = (controller.lyricsLineModels[index].mainText ?? '').trim();
                  if (mainText.isEmpty) {mainText = '···';}
                  String extText = (controller.lyricsLineModels[index].extText ?? '').trim();
                  if (extText.isNotEmpty) extText = '\n$extText';
                  return AnimatedDefaultTextStyle(
                    style: TextStyle(
                      fontFamily: 'monospace', // 指定使用系统等宽字体
                      color: controller.panelWidgetColor.value.withOpacity(isActive ? 1 : 0.2),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 50.sp,
                    ),
                    curve: Curves.decelerate,
                    textAlign: TextAlign.start,
                    duration: const Duration(milliseconds: 500),
                    child: Text(mainText + extText),
                  );
                }),
              );
            },
          )),
    );
  }
}