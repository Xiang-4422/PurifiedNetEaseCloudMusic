import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';

class AlbumController extends GetxController {
  late BuildContext context;
  late String albumId;
  RxList<MediaItem> mediaItems = <MediaItem>[].obs;
  RxBool loading = true.obs;
  Rx<Color> backgroundColor = Get.theme.colorScheme.primary.obs;
  Rx<Color> widgetColor = Get.theme.colorScheme.onPrimary.obs;

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      albumId = context.routeData.queryParams.get('albumId');
      AlbumDetailWrap albumDetailWrap = await NeteaseMusicApi().albumDetail(albumId);
      mediaItems
        ..clear()
        ..addAll(AppController.to.song2ToMedia(albumDetailWrap.songs ?? []));
      loading.value = false;

      await OtherUtils.getImageColor('${albumDetailWrap.album?.picUrl}?param=500y500').then((paletteGenerator) {
        // 更新panel中的色调
        backgroundColor.value = paletteGenerator.lightMutedColor?.color
            ?? paletteGenerator.lightVibrantColor?.color
            ?? paletteGenerator.dominantColor?.color
            ?? Get.theme.primaryColor;
        widgetColor.value = ThemeData.estimateBrightnessForColor(backgroundColor.value) == Brightness.light
            ? Colors.black
            : Colors.white;
      });

    });
  }
}
