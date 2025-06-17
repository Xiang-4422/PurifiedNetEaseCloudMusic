import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';


class LyricView extends GetView<HomePageController> {
  const LyricView({super.key});

  @override
  Widget build(BuildContext context) {
      return ScrollablePositionedList.builder(
        key: ValueKey(controller.lyricsLineModels.length),
        itemPositionsListener: controller.lyricScrollListener,
        itemScrollController: controller.lyricScrollController,
        itemCount: controller.lyricsLineModels.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0 || index == controller.lyricsLineModels.length + 1) {
            return Container(
              height: context.height * (index == 0 ? 0.4 : 0.6),
            );
          }
          index -= 1;
          return Obx(() => Container(
            key: ValueKey(controller.currLyricIndex.value == index),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 原歌词
                Obx(() => AnimatedDefaultTextStyle(
                  style: TextStyle(
                    fontSize: controller.currLyricIndex.value == index && controller.lyricsLineModels[index].mainText != null ? 40.sp : 35.sp,
                    color: controller.bodyColor.value.withOpacity(controller.currLyricIndex.value == index ? 1 : 0.3),
                    fontWeight: controller.currLyricIndex.value == index ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    // 原歌词
                      (controller.lyricsLineModels[index].mainText ?? '')
                          // 翻译歌词
                          + (controller.lyricsLineModels[index].extText == null
                          ? ''
                          : '\n${controller.lyricsLineModels[index].extText ?? ''}'
                      )
                  ),
                )),
              ],
            ),
          ),
          );
        },
      );
  }
}