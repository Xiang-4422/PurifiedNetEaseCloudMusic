import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/widget/request_widget/request_loadmore_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/netease_api/src/api/play/bean.dart';
import '../play_list/playlist_page_view.dart';
import 'cloud_controller.dart';

class CloudDriveView extends GetWidget<CloudController> {
  const CloudDriveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top + AppDimensions.appBarHeight,
        ),
        Expanded(
          child: RequestLoadMoreWidget<CloudSongListWrap, CloudSongItem>(
              listKey: const ['data'],
              dioMetaData: controller.cloudSongDioMetaData(),
              childBuilder: (List<CloudSongItem> data) {
                controller.updateMediaItems(data);
                return ListView.builder(
                  itemCount: controller.mediaItems.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    return SongItem(
                      index: index,
                      playlist: controller.mediaItems,
                      playListName: "云盘音乐",
                    );
                  },
                );
              }),
        ),
        Container(
          height: AppDimensions.bottomPanelHeaderHeight,
        ),
      ],
    );
  }
}
