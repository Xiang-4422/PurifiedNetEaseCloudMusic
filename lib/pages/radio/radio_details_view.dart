import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:bujuan/widget/request_widget/request_loadmore_view.dart';
import 'package:flutter/material.dart';

import '../../common/constants/enmu.dart';
import '../../common/netease_api/src/api/dj/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';

class RadioDetailsView extends StatefulWidget {
  const RadioDetailsView({Key? key}) : super(key: key);

  @override
  State<RadioDetailsView> createState() => _RadioDetailsViewState();
}

class _RadioDetailsViewState extends State<RadioDetailsView> {
  DioMetaData djProgramListDioMetaData(String radioId, {int offset = 0, int limit = 30, bool asc = true}) {
    var params = {'radioId': radioId, 'limit': limit, 'offset': offset, 'asc': asc};
    return DioMetaData(joinUri('/weapi/dj/program/byradio'), data: params, options: joinOptions());
  }

  @override
  Widget build(BuildContext context) {
    return MyGetView(child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text((context.routeData.args as DjRadio).name),
        backgroundColor: Colors.transparent,
      ),
      body: RequestLoadMoreWidget<DjProgramListWrap, DjProgram>(
          dioMetaData: djProgramListDioMetaData((context.routeData.args as DjRadio).id),
          childBuilder: (list) {
            var mediaItems = list
                .map((e) => MediaItem(
              id: '${e.mainTrackId}',
              title: e.mainSong.name ?? '',
              artUri: Uri.parse(e.mainSong.album?.picUrl ?? ''),
              artist: e.dj.nickname,
              album: e.mainSong.album?.name,
              duration: Duration(milliseconds: e.duration ?? 0),
              extras: {
                'type': MediaType.playlist.name,
                'image': e.coverUrl ?? '',
                'liked': HomePageController.to.likeIds.contains(int.tryParse(e.id)),
                'mv': 0,
              },
            ))
                .toList();
            return ListView.builder(
              itemBuilder: (context, index) {
                return SongItem(
                  index: index,
                  mediaItem: mediaItems[index],
                  onTap: () {
                    HomePageController.to.playByIndex(index, 'queueTitle', playList: mediaItems);
                  },
                );
              },
              itemCount: list.length,
            );
          },
          listKey: const ['programs']),
    ));
  }
}
