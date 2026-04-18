import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/features/cloud/repository/cloud_repository.dart';
import 'package:bujuan/widget/request_widget/request_loadmore_view.dart';
import 'package:flutter/material.dart';

import '../../common/netease_api/src/api/play/bean.dart';
import '../play_list/playlist_page_view.dart';

class CloudDriveView extends StatelessWidget {
  const CloudDriveView({Key? key}) : super(key: key);
  static final CloudRepository _repository = CloudRepository();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height:
              MediaQuery.of(context).padding.top + AppDimensions.appBarHeight,
        ),
        Expanded(
          child: RequestLoadMoreWidget<CloudSongListWrap, CloudSongItem>(
              listKey: const ['data'],
              dioMetaData: _repository.buildCloudSongRequest(),
              childBuilder: (List<CloudSongItem> data) {
                final mediaItems = _repository.mapCloudSongs(
                  data,
                  likedSongIds: AppController.to.likedSongIds.toList(),
                );
                return ListView.builder(
                  itemCount: mediaItems.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    return SongItem(
                      index: index,
                      playlist: mediaItems,
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
