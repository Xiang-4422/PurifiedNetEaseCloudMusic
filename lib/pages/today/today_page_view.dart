import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:bujuan/widget/request_widget/request_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/netease_api/src/api/play/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';
import '../play_list/playlist_page_view.dart';

class TodayPageView extends StatefulWidget {
  const TodayPageView({Key? key}) : super(key: key);

  @override
  State<TodayPageView> createState() => _TodayPageViewState();
}

class _TodayPageViewState extends State<TodayPageView> {
  DioMetaData recommendSongListDioMetaData() {
    return DioMetaData(joinUri('/api/v3/discovery/recommend/songs'), data: {}, options: joinOptions(cookies: {'os': 'ios'}));
  }
  final List<MediaItem> _mediaItem = [];

  @override
  Widget build(BuildContext context) {
    return MyGetView(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              height: AppDimensions.appBarHeight,
            ),
            Expanded(
              child: RequestWidget<RecommendSongListWrapX>(
                  dioMetaData: recommendSongListDioMetaData(),
                  childBuilder: (playlist) {
                    _mediaItem
                      ..clear()
                      ..addAll(HomePageController.to.song2ToMedia((playlist.data.dailySongs ?? [])));
                    return ListView.builder(
                      itemExtent: 130.w,
                      itemBuilder: (context, index) => SongItem(
                        index: index,
                        mediaItem: _mediaItem[index],
                        onTap: () {
                          HomePageController.to.playNewPlayListByIndex(index, 'queueTitle', playList: _mediaItem);
                        },
                      ),
                      itemCount: _mediaItem.length,
                    );
                  }),
            ),
            Container(
              height: AppDimensions.bottomPanelHeaderHeight,
            ),
          ],
        ),
      ),
    );
  }
}
