import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/play_list/playlist_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../home/home_page_controller.dart';
import 'controller.dart';

class AlbumDetails extends GetView<AlbumController> {
  const AlbumDetails({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text((context.routeData.queryParams.get('album') as Album).name ?? ''),
      ),
      body: Obx(() => Visibility(visible:! controller.loading.value,replacement: const LoadingView(),child: ListView.builder(
        itemBuilder: (context, index) => SongItem(index: index, mediaItem: controller.mediaItems[index],onTap: (){
          HomePageController.to.playByIndex(index, 'queueTitle',playList: controller.mediaItems);
        },),
        itemCount: controller.mediaItems.length,
        itemExtent: 130.w,
      ),)),
    );
  }
}
