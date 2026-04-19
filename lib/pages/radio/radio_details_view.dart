import 'package:auto_route/auto_route.dart';
import 'package:bujuan/features/shell/controller/app_controller.dart';
import 'package:bujuan/features/radio/repository/radio_repository.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/request_widget/request_loadmore_view.dart';
import 'package:flutter/material.dart';

import '../../common/netease_api/src/api/dj/bean.dart';

class RadioDetailsView extends StatefulWidget {
  const RadioDetailsView({Key? key}) : super(key: key);

  @override
  State<RadioDetailsView> createState() => _RadioDetailsViewState();
}

class _RadioDetailsViewState extends State<RadioDetailsView> {
  final RadioRepository _repository = RadioRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text((context.routeData.args as DjRadio).name),
        backgroundColor: Colors.transparent,
      ),
      body: RequestLoadMoreWidget<DjProgramListWrap, DjProgram>(
          dioMetaData: _repository
              .buildProgramListRequest((context.routeData.args as DjRadio).id),
          childBuilder: (list) {
            final mediaItems = _repository.mapProgramsToMediaItems(
              list,
              likedSongIds: AppController.to.likedSongIds.toList(),
            );
            return ListView.builder(
              itemBuilder: (context, index) {
                return SongItem(
                  index: index,
                  playlist: mediaItems,
                  playListName: (context.routeData.args as DjRadio).name,
                );
              },
              itemCount: list.length,
            );
          },
          listKey: const ['programs']),
    );
  }
}
