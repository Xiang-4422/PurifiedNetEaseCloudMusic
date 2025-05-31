import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:bujuan/widget/request_widget/request_loadmore_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/netease_api/src/api/play/bean.dart';
import '../play_list/playlist_view.dart';
import 'cloud_controller.dart';

class CloudDriveView extends GetWidget<CloudController> {
  const CloudDriveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyGetView(child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: RichText(
            text: TextSpan(style: TextStyle(fontSize: 42.sp, color: Colors.grey, fontWeight: FontWeight.bold), text: 'Here  ', children: [
              TextSpan(text: '云盘～', style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(.9))),
            ])),
      ),
      body: RequestLoadMoreWidget<CloudSongListWrap, CloudSongItem>(
          listKey: const ['data'],
          dioMetaData: controller.cloudSongDioMetaData(),
          childBuilder: (List<CloudSongItem> data) {
            controller.mediaItems
              ..clear()
              ..addAll(data
                  .map((e) => MediaItem(
                  id: e.simpleSong.id,
                  duration: Duration(milliseconds: e.simpleSong.dt ?? 0),
                  artUri: Uri.parse('${e.simpleSong.al?.picUrl ?? ''}?param=500y500'),
                  extras: {
                    'url': '',
                    'image': e.simpleSong.al?.picUrl ?? '',
                    'type': '',
                    'liked': HomePageController.to.likeIds.contains(int.tryParse(e.simpleSong.id)),
                    'artist': (e.simpleSong.ar ?? []).map((e) => jsonEncode(e.toJson())).toList().join(' / ')
                  },
                  title: e.simpleSong.name ?? "",
                  album: jsonEncode(e.simpleSong.al?.toJson()),
                  artist: (e.simpleSong.ar ?? []).map((e) => e.name).toList().join(' / ')))
                  .toList());
            return ListView.builder(
              shrinkWrap: true,
              itemExtent: 130.w,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemBuilder: (context, index) => SongItem(
                index: index,
                mediaItem: controller.mediaItems[index],
                onTap: () {
                  HomePageController.to.playByIndex(index, 'queueTitle', mediaItem: controller.mediaItems);
                },
              ),
              itemCount: controller.mediaItems.length,
            );
          }),
    ));
  }
}
