import 'package:audio_service/audio_service.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/appConstants.dart';

class PlayListView extends GetView<HomePageController> {
  const PlayListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
        controller: controller.playListScrollController,
        padding: EdgeInsets.symmetric(horizontal: context.width * (1 - AppDimensions.albumMaxWidth) / 2),
        itemExtent: 110.w,
        itemBuilder: (context, index) => _buildPlayListItem(controller.curPlayList[index], index, context),
        itemCount: controller.curPlayList.length,
      ),
    );
  }

  Widget _buildPlayListItem(MediaItem mediaItem, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.audioServeHandler.playIndex(index),
      // 透明 Container 用于触发点击
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(
                    mediaItem.title,
                      maxLines: 1,
                      style: TextStyle(fontSize: 30.sp, color: controller.bodyColor.value),
                    )),
                  Obx(() => Text(
                    mediaItem.artist ?? '',
                    maxLines: 1,
                    style: TextStyle(fontSize: 24.sp, color: controller.bodyColor.value),
                  ))
                ],
              )
            ),
            Obx(() => IconButton(
                onPressed: () => controller.curMediaItem.value.id == mediaItem.id ? null : controller.audioServeHandler.removeQueueItemAt(index),
                icon: Icon(
                  controller.curMediaItem.value.id == mediaItem.id
                      ? TablerIcons.circle_letter_p
                      : TablerIcons.trash_x,
                  color: controller.bodyColor.value,
                  // size: 42.w,
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
