import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../common/constants/appConstants.dart';
import '../../controllers/app_controller.dart';
import 'controller.dart';

class AlbumPageView extends GetView<AlbumController> {
  const AlbumPageView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Column(

      children: [
        Padding(padding: EdgeInsets.only(top: AppDimensions.appBarHeight + context.mediaQueryPadding.top)),
        Expanded(
          child: Obx(() => Visibility(visible:! controller.loading.value,replacement: const LoadingView(),child: ListView.builder(
            itemCount: controller.mediaItems.length,
            itemBuilder: (context, index) => SongItem(
              index: index,
              playlist: controller.mediaItems,
            ),
          ),)),
        ),
        Padding(padding: EdgeInsets.only(top: AppDimensions.bottomPanelHeaderHeight)),
      ],
    );
  }
}
