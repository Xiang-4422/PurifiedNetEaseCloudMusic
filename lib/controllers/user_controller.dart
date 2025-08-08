import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/home/body/body_pages/personal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../common/netease_api/src/api/login/bean.dart';
import '../common/netease_api/src/api/play/bean.dart';
import '../common/netease_api/src/dio_ext.dart';
import '../common/netease_api/src/netease_api.dart';
import '../routes/router.dart';
import '../widget/enable_view.dart';

enum LoginStatus { login, noLogin }

class UserController extends GetxController {
  static UserController get to => Get.find();
  /// 喜欢歌单
  PlayList userLikedSongPlayList = PlayList();
  /// 创建歌单列表
  List<PlayList> userMadePlayLists = <PlayList>[].obs;
  /// 收藏歌单列表
  List<PlayList> userFavoritedPlayLists = <PlayList>[].obs;

  RxBool loading = true.obs;
  late BuildContext context;
  final List<UserItem> userItems = [
    UserItem('每日', TablerIcons.calendar, fullTitle: '每日推荐', routes: Routes.today,color: const Color.fromRGBO(66,133,244, .7)),
    UserItem('FM', TablerIcons.radio, routes: 'playFm',color: const Color.fromRGBO(52,168,83, .7)),
    UserItem('播客', TablerIcons.brand_apple_podcast, routes: Routes.myRadio,color: const Color.fromRGBO(251,188,5, .7)),
    UserItem('云盘', TablerIcons.cloud_fog, routes: Routes.cloud,color: const Color.fromRGBO(234,67,53, .7))
  ];

  //进度
  @override
  void onReady() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getUserState();
      _update();
    });
  }
  @override
  void onClose() {
    // userScrollController.dispose();
    super.onClose();
  }

  _update() {
    Https.dioProxy.get('https://gitee.com/yasengsuoai/bujuan_version/raw/master/version.json').then((value) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      Map<String, dynamic> versionData = value.data..putIfAbsent('oldVersion', () => version);
      //0开启1关闭
      if ((versionData['enable'] ?? 0) == 1) {
        if (context.mounted) {
          showDialog(context: context, barrierDismissible: false, useRootNavigator: true, barrierColor: Colors.black87, builder: (context) => const EnableView());
        }
        return;
      }
      if (int.parse((versionData['version'] ?? '0').replaceAll('.', '')) > int.parse(version.replaceAll('.', ''))) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          // GetIt.instance<RootRouter>().push(const UpdateView().copyWith(queryParams: versionData));
        });
      }
    });
  }
  //获取用户信息
  getUserState() async {
    try {
      NeteaseAccountInfoWrap neteaseAccountInfoWrap = await NeteaseMusicApi().loginAccountInfo();
      if (neteaseAccountInfoWrap.code == 200 && neteaseAccountInfoWrap.profile != null) {

        AppController.to.userData.value = neteaseAccountInfoWrap;
        AppController.to.loginStatus.value = LoginStatus.login;
        AppController.to.box.put(loginData, jsonEncode(neteaseAccountInfoWrap.toJson()));

        _getUserPlayList();
        _getUserLikeSongIds();
      } else {
        WidgetUtil.showToast('登录失效,请重新登录');
        AppController.to.loginStatus.value = LoginStatus.noLogin;
      }
    } catch (e) {
      AppController.to.loginStatus.value = LoginStatus.noLogin;
      WidgetUtil.showToast('获取用户资料失败，请检查网络');
    }
  }

  clearUser() {
    NeteaseMusicApi().logout().then((value) {
      if (value.code != 200) {
        WidgetUtil.showToast(value.message ?? '');
        return;
      }
      AppController.to.box.put(loginData, '');
      AppController.to.loginStatus.value = LoginStatus.noLogin;
    });
  }

  /// 获取用户歌单
  _getUserPlayList() {
    NeteaseMusicApi().userPlayList(AppController.to.userData.value.profile?.userId ?? '-1').then((MultiPlayListWrap2 multiPlayListWrap2) async {
          List<PlayList> playLists = (multiPlayListWrap2.playlists ?? []);
          if (playLists.isNotEmpty) {
            userLikedSongPlayList = playLists.first..name = '我喜欢的音乐';
            playLists.removeAt(0);
            userFavoritedPlayLists.clear();
            userMadePlayLists.clear();
            for(var playList in playLists) {
              if (playList.creator?.userId == AppController.to.userData.value.profile?.userId) {
                userMadePlayLists.add(playList);
              } else {
                userFavoritedPlayLists.add(playList);
              }
            }
          }
          loading.value = false;
    });
  }

  _getUserLikeSongIds() async {
    LikeSongListWrap likeSongListWrap = await NeteaseMusicApi().likeSongList(AppController.to.userData.value.profile?.userId ?? '-1');
    if (likeSongListWrap.code == 200) {
      AppController.to.likeIds
        ..clear()
        ..addAll(likeSongListWrap.ids);
    }
  }


}
