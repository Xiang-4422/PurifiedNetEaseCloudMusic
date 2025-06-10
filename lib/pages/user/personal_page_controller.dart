import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/user/personal_page_view.dart';
import 'package:bujuan/routes/router.dart';
import 'package:bujuan/widget/enable_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../common/netease_api/src/api/login/bean.dart';
import '../../common/netease_api/src/api/play/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_api.dart';

enum LoginStatus { login, noLogin }

class PersonalPageController extends GetxController {
  /// 喜欢歌单
  Rx<Play> userLikedSongCollection = Play().obs;
  /// 创建歌单列表
  List<Play> userMadeSongCollectionList = <Play>[].obs;
  /// 收藏歌单列表
  List<Play> userFavoritedSongCollectionList = <Play>[].obs;

  RxBool loading = true.obs;
  late BuildContext context;
  final List<UserItem> userItems = [
    UserItem('每日', TablerIcons.calendar, routes: Routes.today,color: const Color.fromRGBO(66,133,244, .7)),
    UserItem('FM', TablerIcons.vinyl, routes: 'playFm',color: const Color.fromRGBO(52,168,83, .7)),
    UserItem('播客', TablerIcons.brand_apple_podcast, routes: Routes.myRadio,color: const Color.fromRGBO(251,188,5, .7)),
    UserItem('云盘', TablerIcons.cloud_fog, routes: Routes.cloud,color: const Color.fromRGBO(234,67,53, .7))
  ];

  //进度
  @override
  void onInit() {
    super.onInit();
  }
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

  static PersonalPageController get to => Get.find();

  //获取用户信息
  getUserState() async {
    try {
      NeteaseAccountInfoWrap neteaseAccountInfoWrap = await NeteaseMusicApi().loginAccountInfo();
      if (neteaseAccountInfoWrap.code == 200 && neteaseAccountInfoWrap.profile != null) {

        HomePageController.to.userData.value = neteaseAccountInfoWrap;
        HomePageController.to.loginStatus.value = LoginStatus.login;
        HomePageController.to.box.put(loginData, jsonEncode(neteaseAccountInfoWrap.toJson()));

        _getUserPlayList();
        _getUserLikeSongIds();
      } else {
        WidgetUtil.showToast('登录失效,请重新登录');
        HomePageController.to.loginStatus.value = LoginStatus.noLogin;
      }
    } catch (e) {
      HomePageController.to.loginStatus.value = LoginStatus.noLogin;
      WidgetUtil.showToast('获取用户资料失败，请检查网络');
    }
  }

  clearUser() {
    NeteaseMusicApi().logout().then((value) {
      if (value.code != 200) {
        WidgetUtil.showToast(value.message ?? '');
        return;
      }
      HomePageController.to.box.put(loginData, '');
      HomePageController.to.loginStatus.value = LoginStatus.noLogin;
    });
  }

  _getUserPlayList() {
    NeteaseMusicApi().userPlayList(HomePageController.to.userData.value.profile?.userId ?? '-1')
        .then((MultiPlayListWrap2 multiPlayListWrap2) async {
      List<Play> list = (multiPlayListWrap2.playlist ?? []);
      if (list.isNotEmpty) {
        userLikedSongCollection.value = list.first;
        list.removeAt(0);
        userFavoritedSongCollectionList.clear();
        userMadeSongCollectionList.clear();
        for(var collection in list) {
          if (collection.creator?.userId == HomePageController.to.userData.value.profile?.userId) {
            userMadeSongCollectionList.add(collection);
            userFavoritedSongCollectionList.remove(collection);
          } else {
            userFavoritedSongCollectionList.add(collection);
          }
        }
      }
      loading.value = false;
    });
  }

  _getUserLikeSongIds() async {
    LikeSongListWrap likeSongListWrap = await NeteaseMusicApi().likeSongList(HomePageController.to.userData.value.profile?.userId ?? '-1');
    if (likeSongListWrap.code == 200) {
      HomePageController.to.likeIds
        ..clear()
        ..addAll(likeSongListWrap.ids);
    }
  }


}
