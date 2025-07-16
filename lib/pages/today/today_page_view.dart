import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/widget/request_widget/request_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';

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
    return Scaffold(
      backgroundColor: context.theme.colorScheme.primary,
      body: Column(
        children: [
          // Container(height: 500,),
          Expanded(
            child: RequestWidget<RecommendSongListWrapX>(
              dioMetaData: recommendSongListDioMetaData(),
              childBuilder: (playlist) {
                _mediaItem
                  ..clear()
                  ..addAll(AppController.to.song2ToMedia((playlist.data.dailySongs ?? [])));
                return Column(
                  children: [
                    //TODO YU4422 添加一个日期组件
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: AppDimensions.appBarHeight + context.mediaQueryPadding.top, bottom: AppDimensions.bottomPanelHeaderHeight),
                        itemCount: _mediaItem.length,
                        itemBuilder: (context, index) => SongItem(
                          index: index,
                          playlist: _mediaItem,
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
