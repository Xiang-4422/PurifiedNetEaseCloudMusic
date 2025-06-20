import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// TODO YU4422 歌词换行、歌词丝滑缩放
class LyricView extends GetView<HomePageController> {
  const LyricView({super.key});

  @override
  Widget build(BuildContext context) {
      return Obx(() => ScrollablePositionedList.builder(
          key: ValueKey(controller.curPlayIndex.value),
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
            return Container(
              width: context.width,
              margin: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Obx((){
                bool isActive = controller.currLyricIndex.value == index;
                return AnimatedDefaultTextStyle(
                  style: TextStyle(
                    fontSize: isActive ? 40.sp : 35.sp,
                    color: controller.bodyColor.value.withOpacity(isActive ? 1 : 0.3),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  duration: const Duration(milliseconds: 300),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      // 原歌词
                        (controller.lyricsLineModels[index].mainText ?? '')
                            // 翻译歌词
                            + (controller.lyricsLineModels[index].extText == null
                            ? ''
                            : '\n${controller.lyricsLineModels[index].extText ?? ''}'
                        )
                    ),
                  ),
                );
              }),
            );
          },
        ),
      );
  }
}