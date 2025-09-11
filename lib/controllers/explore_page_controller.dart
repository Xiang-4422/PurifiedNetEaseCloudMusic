import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../common/constants/enmu.dart';

class ExplorePageController extends GetxController {
  Map<String, List<Map<String, String>>> topPlayListCategory = {
    "官方榜" : [
      {'name': '云音乐新歌榜', 'id': '3779629'},
      {'name': '云音乐热歌榜', 'id': '3778678'},
      {'name': '云音乐原创榜', 'id': '2884035'},
      {'name': '云音乐飙升榜', 'id': '19723756'},
      {'name': '云音乐电音榜', 'id': '10520166'},
    ],
    "全球榜": [
      {'name': 'UK排行榜周榜', 'id': '180106'},
      {'name': '美国Billboard周榜', 'id': '60198'},
      {'name': 'KTV嗨榜', 'id': '21845217'},
      {'name': 'iTunes榜', 'id': '11641012'},
      {'name': 'Hit FM Top榜', 'id': '120001'},
      {'name': '日本Oricon周榜', 'id': '60131'},
      {'name': '韩国Melon排行榜周榜', 'id': '3733003'},
      {'name': '韩国Mnet排行榜周榜', 'id': '60255'},
      {'name': '韩国Melon原声周榜', 'id': '46772709'},
      {'name': '中国TOP排行榜(港台榜)', 'id': '112504'},
      {'name': '中国TOP排行榜(内地榜)', 'id': '64016'},
      {'name': '香港电台中文歌曲龙虎榜', 'id': '10169002'},
      {'name': '华语金曲榜', 'id': '4395559'},
      {'name': '中国嘻哈榜', 'id': '1899724'},
      {'name': '法国 NRJ EuroHot 30周榜', 'id': '27135204'},
      {'name': '台湾Hito排行榜', 'id': '112463'},
      {'name': 'Beatport全球电子舞曲榜', 'id': '3812895'},
    ],
    "语种榜": [
      {'name': '云音乐欧美热歌榜', 'id': '2809513713'},
      {'name': '云音乐欧美新歌榜', 'id': '2809577409'},
    ],
    "精选榜": [
      {'name': '云音乐ACG音乐榜', 'id': '71385702'},
      {'name': '云音乐说唱榜', 'id': '991319590'},
      {'name': '云音乐古典音乐榜', 'id': '71384707'},
      {'name': '云音乐电音榜', 'id': '1978921795'},
      {'name': '抖音排行榜', 'id': '2250011882'},
      {'name': '新声榜', 'id': '2617766278'},
      {'name': '云音乐韩语榜', 'id': '745956260'},
      {'name': '英国Q杂志中文版周榜', 'id': '2023401535'},
      {'name': '电竞音乐榜', 'id': '2006508653'},
      {'name': '说唱TOP榜', 'id': '2847251561'},
      {'name': '云音乐ACG动画榜', 'id': '3001835560'},
      {'name': '云音乐ACG游戏榜', 'id': '3001795926'},
      {'name': '云音乐ACG VOCALOID榜', 'id': '3001890046'}
    ]
  };

  RxBool showChooseCategory = false.obs;
  RxBool showChoosePlayList = false.obs;

  /// 排行榜分类名
  List<String> topPlayListCategoryNames = [];
  /// 当前排行榜分类名
  RxString curTopPlayListCategoryName = "".obs;
  /// 当前排行榜分类歌单
  RxList<Map<String, String>> curCategoryTopPlayLists = <Map<String, String>>[].obs;

  /// 当前排行榜名称
  RxString curTopPlayListName = "".obs;
  /// 当前排行榜ID
  RxString curTopPlayListId = "".obs;
  /// 当前排行榜歌曲
  RxList<MediaItem> curTopPlayListSongs = <MediaItem>[].obs;

  /// 精选歌单
  RxList<PlayList> hqPlaylists = <PlayList>[].obs;

  RxBool loading = true.obs;

  RefreshController refreshController = RefreshController();

  @override
  void onReady() async {
    super.onReady();
    initData();
    await updateData();
    loading.value = false;
  }

  initData() {
    topPlayListCategoryNames.addAll(topPlayListCategory.keys);
    curTopPlayListCategoryName.value = topPlayListCategoryNames[0];
    curCategoryTopPlayLists.addAll(topPlayListCategory[curTopPlayListCategoryName.value]!);
    curTopPlayListName.value = curCategoryTopPlayLists[0]["name"]!;
    curTopPlayListId.value = curCategoryTopPlayLists[0]["id"]!;
  }

  updateData() async {
    await _getHighQualityPlayLists();
    await updateRankingPlayListSongs();
    refreshController.refreshCompleted();
    refreshController.resetNoData();
  }

  _getHighQualityPlayLists() async {
    List<PlayList> data;
    MultiPlayListWrap multiPlayListWrap = await NeteaseMusicApi().categorySongList();
    data = multiPlayListWrap.playlists ?? [];
    hqPlaylists
      ..clear()
      ..addAll(data);
    // ..addAll(data.length > 6 ? data.sublist(0, 6) : data);
  }

  changeCurRankingPlayList(String rankingPlayListid) {
    curTopPlayListId.value = rankingPlayListid;
    updateRankingPlayListSongs();
  }

  updateRankingPlayListSongs({int offset = 0, limit = 10}) async {
    if (offset == 0) curTopPlayListSongs.clear();
    List<MediaItem> songs = await AppController.to.getPlayListSongs(curTopPlayListId.value, offset: offset, limit: limit);
    curTopPlayListSongs.addAll(songs);
    if (songs.length < 10 ) {
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }
  }

  playCurRankingPlayListSongs() async {
    await updateRankingPlayListSongs(offset: curTopPlayListSongs.length, limit: -1);
    AppController.to.playNewPlayList(curTopPlayListSongs, 0, playListName: curTopPlayListName.value);
  }

  changeCurTopPlayListCategory(String name) {
    curTopPlayListCategoryName.value = name;
    showChooseCategory.value = false;
    showChoosePlayList.value = false;

    curCategoryTopPlayLists.clear();
    curCategoryTopPlayLists.addAll(topPlayListCategory[curTopPlayListCategoryName.value]!);
    changeCurTopPlayList(curCategoryTopPlayLists[0]);
  }

  changeCurTopPlayList(Map<String, String> topPlayList) {
    curTopPlayListName.value = topPlayList["name"]!;
    curTopPlayListId.value = topPlayList["id"]!;
    showChooseCategory.value = false;
    showChoosePlayList.value = false;

    updateRankingPlayListSongs();
  }

}
