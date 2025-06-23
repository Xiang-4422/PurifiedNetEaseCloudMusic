import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/enmu.dart';
import '../user/personal_page_controller.dart';

class ExplorePageController extends GetxController {
  RxList<PlayList> playlists = <PlayList>[].obs;
  RxList<MediaItem> newSingles = <MediaItem>[].obs;
  RxBool loading = true.obs;

  @override
  void onReady() async {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await _getRecoPlayLists();
      await _getNewSongs();
      loading.value = false;
    });
  }

  _getRecoPlayLists() async {
    List<PlayList> data;
    if (HomePageController.to.loginStatus.value == LoginStatus.login) {
      RecommendPlayListWrap recommendPlayListWrap = await NeteaseMusicApi().recoPlaylists();
      data = recommendPlayListWrap.recommend ?? [];
    } else {
      PersonalizedPlayListWrap personalizedPlayListWrap = await NeteaseMusicApi().personalizedPlaylist();
      data = personalizedPlayListWrap.result ?? [];
    }
    playlists
      ..clear()
      ..addAll(data.length > 6 ? data.sublist(0, 6) : data);
  }
  _getNewSongs() async{
    PersonalizedSongListWrap personalizedSongListWrap = await NeteaseMusicApi().personalizedSongList();
    var data = personalizedSongListWrap.result??[];
    newSingles
      ..clear()
      ..addAll(data.map((e) => MediaItem(
          id: e.id,
          duration: Duration(milliseconds: e.song.duration ?? 0),
          artUri: Uri.parse('${e.song.album?.picUrl ?? ''}?param=500y500'),
          extras: {
            'type': MediaType.playlist.name,
            'image': e.song.album?.picUrl ?? '',
            'liked': HomePageController.to.likeIds.contains(int.tryParse(e.id)),
            'artist': (e.song.artists ?? []).map((e) => jsonEncode(e.toJson())).toList().join(' / '),
            'album': jsonEncode(e.song.album?.toJson()),
            'mv': e.song.mvid,
            'fee': e.song.fee
          },
          title: e.song.name ?? "",
          album: e.song.album?.name,
          artist: (e.song.artists ?? []).map((e) => e.name).toList().join(' / '))).toList());
  }
}
