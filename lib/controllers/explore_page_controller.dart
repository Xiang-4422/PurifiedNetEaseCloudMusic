import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/constants/enmu.dart';

class ExplorePageController extends GetxController {
  RxList<PlayList> hqPlaylists = <PlayList>[].obs;

  RxList<MediaItem> newSongs = <MediaItem>[].obs;

  int lastTime = 0;

  RxBool loading = true.obs;

  @override
  void onReady() async {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await updateData();
      loading.value = false;
    });
  }

  updateData() async {
    await _getNewSongs();
    await _getHighQualityPlayLists();
  }

  _getHighQualityPlayLists() async {
    List<PlayList> data;
    MultiPlayListWrap multiPlayListWrap = await NeteaseMusicApi().highqualityPlayList();
    data = multiPlayListWrap.playlists ?? [];
    hqPlaylists
      ..clear()
      ..addAll(data);
    // ..addAll(data.length > 6 ? data.sublist(0, 6) : data);
  }

  _getNewSongs() async{
    PersonalizedSongListWrap personalizedSongListWrap = await NeteaseMusicApi().personalizedSongList();
    var data = personalizedSongListWrap.result??[];
    newSongs
      ..clear()
      ..addAll(data.map((e) => MediaItem(
          id: e.id,
          duration: Duration(milliseconds: e.song.duration ?? 0),
          artUri: Uri.parse('${e.song.album?.picUrl ?? ''}?param=500y500'),
          extras: {
            'type': MediaType.playlist.name,
            'image': e.song.album?.picUrl ?? '',
            'liked': AppController.to.likedSongIds.contains(int.tryParse(e.id)),
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
