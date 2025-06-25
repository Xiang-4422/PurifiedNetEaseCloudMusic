import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';
import '../../common/netease_api/src/api/bean.dart';
import '../../common/netease_api/src/api/play/bean.dart';
import '../../common/netease_api/src/netease_api.dart';

class PlayListController<E, T> extends GetxController with GetTickerProviderStateMixin{

  late String playListId;

  List<MediaItem> mediaItems = <MediaItem>[];
  List<MediaItem> searchItems = <MediaItem>[];
  SinglePlayListWrap? details;
  RxBool loading = true.obs;
  RxBool search = false.obs;
  RxBool isSearch = false.obs;
  RxBool isSubscribed = false.obs;
  RxBool isMyPlayList = false.obs;
  final TextEditingController textEditingController = TextEditingController();

  late TabController commentTabController;
  late PageController pageController;

  RxInt curPageIndex = 0.obs;


  @override
  void onInit() {
    super.onInit();
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
  void onReady() {
    super.onReady();
    _getSongIds(playListId);
    // _getAlbumColor();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

    });
    textEditingController.addListener(() {
      if (textEditingController.text.isEmpty) {
        if (isSearch.value) isSearch.value = false;
      } else {
        if (!isSearch.value) isSearch.value = true;
        searchItems
          ..clear()
          ..addAll(mediaItems.where((p0) => p0.title.contains(textEditingController.text)).toList());
      }
    });
  }
  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }

  // _getAlbumColor() {
  //   OtherUtils.getImageColor('${(context?.routeData.args as PlayList).coverImgUrl ?? ''}?param=500y500').then((paletteGenerator) {
  //     // 更新panel中的色调
  //     albumColor.value = context!.isDarkMode
  //         ? paletteGenerator.lightMutedColor?.color
  //         ?? paletteGenerator.lightVibrantColor?.color
  //         ?? Colors.white
  //         : paletteGenerator.darkMutedColor?.color
  //         ?? paletteGenerator.darkVibrantColor?.color
  //         ?? Colors.black;
  //     widgetColor.value = ThemeData.estimateBrightnessForColor(albumColor.value) == Brightness.light
  //         ? Colors.black
  //         : Colors.white;
  //   });
  // }

  _getSongIds(id) async {
    details ??= await NeteaseMusicApi().playListDetail(id);
    isSubscribed.value = details?.playlist?.subscribed ?? false;
    isMyPlayList.value = details?.playlist?.creator?.userId == HomePageController.to.userData.value.profile?.userId;
    List<String> ids = details?.playlist?.trackIds?.map((e) => e.id).toList() ?? [];
    if (ids.length <= 1000) {
      await _callRefresh(ids);
    } else {
      await _callRefresh(ids.sublist(0, 1000));
      await _callRefresh(ids.sublist(1000, ids.length), clear: false);
    }
  }

  _callRefresh(List<String> ids, {bool clear = true}) async {
    SongDetailWrap songDetailWrap = await NeteaseMusicApi().songDetail(ids);
    if (clear) mediaItems.clear();
    mediaItems.addAll(HomePageController.to.song2ToMedia(songDetailWrap.songs ?? []));
    if (loading.value) {
      loading.value = false;
    }
  }

  subscribePlayList() async {
    ServerStatusBean serverStatusBean = await NeteaseMusicApi().subscribePlayList(playListId, subscribe: !isSubscribed.value);
    if (serverStatusBean.code == 200) {
      isSubscribed.value = !isSubscribed.value;
    }
  }
}
