import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/widget/request_widget/request_loadmore_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
                controller.mediaItems
                  ..clear()
                  ..addAll(
                      data.map((e) => MediaItem(
                      id: e.simpleSong.id,
                      duration: Duration(milliseconds: e.simpleSong.dt ?? 0),
                      artUri: Uri.parse('${e.simpleSong.al?.picUrl ?? ''}?param=500y500'),
                      extras: {
                        'url': '',
                        'image': e.simpleSong.al?.picUrl ?? '',
                        'type': '',
                        'liked': AppController.to.likedSongIds.contains(int.tryParse(e.simpleSong.id)),
                        'artist': (e.simpleSong.ar ?? []).map((e) => jsonEncode(e.toJson())).toList().join(' / ')
                      },
                      title: e.simpleSong.name ?? "",
                      album: jsonEncode(e.simpleSong.al?.toJson()),
                      artist: (e.simpleSong.ar ?? []).map((e) => e.name).toList().join(' / '))).toList()
                  );
                return ListView.builder(
                  itemCount: controller.mediaItems.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index){
                    return SongItem(
                      index: index,
                      playlist: controller.mediaItems,
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
