import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';

class AlbumController extends GetxController {
  late BuildContext context;
  late String albumId;
  RxList<MediaItem> songs = <MediaItem>[].obs;
  RxBool loading = true.obs;
  Rx<Color> albumColor = Get.theme.colorScheme.primary.obs;
  Rx<Color> onAlbumColor = Get.theme.colorScheme.onPrimary.obs;

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      albumId = context.routeData.queryParams.get('albumId');
      AlbumDetailWrap albumDetailWrap = await NeteaseMusicApi().albumDetail(albumId);
      songs
        ..clear()
        ..addAll(AppController.to.song2ToMedia(albumDetailWrap.songs ?? []));
      loading.value = false;

      albumColor.value = await OtherUtils.getImageColor(albumDetailWrap.album?.picUrl);
      onAlbumColor.value = albumColor.value.invertedColor;

    });
  }
}
