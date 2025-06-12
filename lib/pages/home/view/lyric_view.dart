import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';


class LyricView extends GetView<HomePageController> {
  const LyricView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ScrollablePositionedList.builder(
        itemPositionsListener: controller.lyricScrollListener,
        itemScrollController: controller.lyricScrollController,
        itemCount: controller.lyricsLineModels.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0 || index == controller.lyricsLineModels.length + 1) {
            return Container(
              height: context.height * 3/5,
            );
          }
          index -= 1;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 原歌词
                Obx(() => AnimatedDefaultTextStyle(
                  style: TextStyle(
                      fontSize: controller.currLyricIndex.value == index && controller.lyricsLineModels[index].mainText != null ? 40.sp : 35.sp,
                      color: controller.bodyColor.value.withOpacity(controller.currLyricIndex.value == index ? 1 : 0.4)
                  ),
                  textAlign: TextAlign.center,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    controller.lyricsLineModels[index].mainText ?? '',
                  ),
                )),
                // 翻译歌词
                Obx(() => Offstage(
                  // offstage: controller.lyricsLineModels[index].extText == null,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 500),
                        style: TextStyle(
                          fontSize: controller.currLyricIndex.value == index ? 40.sp : 35.sp,
                          color: controller.bodyColor.value.withOpacity(controller.currLyricIndex.value == index?0.8:.4),
                        ),
                        child: Text(
                          controller.lyricsLineModels[index].extText ?? '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                )),
              ],
            ),
          );
        },
      );
    });
  }
}