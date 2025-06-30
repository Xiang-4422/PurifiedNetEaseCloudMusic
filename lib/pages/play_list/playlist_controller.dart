import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/app_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';
import '../../common/netease_api/src/api/bean.dart';
import '../../common/netease_api/src/api/play/bean.dart';
import '../../common/netease_api/src/netease_api.dart';

class PlayListController<E, T> extends GetxController with GetTickerProviderStateMixin{

  late PlayList playList;

  List<MediaItem> mediaItems = <MediaItem>[];
  RxInt loadedMediaItemCount = 0.obs;
  List<MediaItem> searchItems = <MediaItem>[];
  SinglePlayListWrap? details;
  bool isMyPlayList = false;

  RxBool loading = true.obs;
  RxBool search = false.obs;
  RxBool isSearch = false.obs;
  RxBool isSubscribed = false.obs;

  late TextEditingController textEditingController;
  late TabController commentTabController;
  late PageController pageController;
  RxInt curPageIndex = 0.obs;

  Rx<Color> albumColor = Colors.transparent.obs;
  Rx<Color> widgetColor = Colors.transparent.obs;


  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController()..addListener(() {
      if (textEditingController.text.isEmpty) {
        if (isSearch.value) isSearch.value = false;
      } else {
        if (!isSearch.value) isSearch.value = true;
        searchItems
          ..clear()
          ..addAll(mediaItems.where((p0) => p0.title.contains(textEditingController.text)).toList());
      }
    });
    commentTabController = TabController(length: 2, vsync: this)..addListener(() {
      if (commentTabController.indexIsChanging) {
        pageController.animateToPage(commentTabController.index + 1, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });
    pageController = PageController()..addListener(() {
      double realTimePage = pageController.page!;
      int curPage = (realTimePage + 0.5).toInt();
      if (curPageIndex.value != curPage) curPageIndex.value = curPage;

      // 避免循环监听
      if (!commentTabController.indexIsChanging) {
        // 控制tab显示
        if (realTimePage >= 1) {
          commentTabController.index = curPage - 1;
          commentTabController.offset = realTimePage - curPage;
        }
      };
    });
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await _getAlbumColor();
    await _getMediaItems(playList.id);
  }
  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }

  _getAlbumColor() async {
    await OtherUtils.getImageColor('${playList.coverImgUrl ?? ''}?param=500y500').then((paletteGenerator) {
      albumColor.value = paletteGenerator.darkMutedColor?.color
          ?? paletteGenerator.darkVibrantColor?.color
          ?? paletteGenerator.dominantColor?.color
          ?? Colors.black;
      widgetColor.value = ThemeData.estimateBrightnessForColor(albumColor.value) == Brightness.light
          ? Colors.black
          : Colors.white;
    });
  }

  _getMediaItems(id) async {
    // 获取歌单详情
    details ??= await NeteaseMusicApi().playListDetail(id);
    isMyPlayList = details?.playlist?.creator?.userId == AppController.to.userData.value.profile?.userId;
    isSubscribed.value = details?.playlist?.subscribed ?? false;
    List<String> ids = details?.playlist?.trackIds?.map((e) => e.id).toList() ?? [];
    // 获取歌曲，先获取1000首，结束loading，后台继续加载剩余歌曲
    mediaItems.clear();
    SongDetailWrap songDetailWrap = await NeteaseMusicApi().songDetail(ids.sublist(0, min(1000, ids.length)));
    mediaItems.addAll(AppController.to.song2ToMedia(songDetailWrap.songs ?? []));
    loadedMediaItemCount.value = mediaItems.length;
    loading.value = false;
    if (ids.length > 1000) {
      while (loadedMediaItemCount.value != ids.length) {
        SongDetailWrap songDetailWrap = await NeteaseMusicApi().songDetail(ids.sublist(loadedMediaItemCount.value, min(loadedMediaItemCount.value + 1000, ids.length)));
        mediaItems.addAll(AppController.to.song2ToMedia(songDetailWrap.songs ?? []));
        loadedMediaItemCount.value = mediaItems.length;
      }
    }
  }

  subscribePlayList() async {
    ServerStatusBean serverStatusBean = await NeteaseMusicApi().subscribePlayList(playList.id, subscribe: !isSubscribed.value);
    if (serverStatusBean.code == 200) {
      isSubscribed.value = !isSubscribed.value;
    }
  }
}
