import 'package:auto_route/auto_route.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/widget/request_widget/request_view.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../common/constants/appConstants.dart';
import '../../common/netease_api/src/api/user/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';

class UserSettingView extends StatefulWidget {
  const UserSettingView({Key? key}) : super(key: key);

  @override
  State<UserSettingView> createState() => _UserSettingViewState();
}

class _UserSettingViewState extends State<UserSettingView> {
  DioMetaData userDetailDioMetaData(String userId) {
    return DioMetaData(joinUri('/weapi/v1/user/detail/$userId'), data: {}, options: joinOptions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RequestWidget<NeteaseUserDetail>(
        dioMetaData: userDetailDioMetaData(AppController.to.userData.value.profile?.userId ?? ''),
        childBuilder: (userData) => Container(
          padding: EdgeInsets.only(top: AppDimensions.appBarHeight + context.mediaQueryPadding.top, bottom: AppDimensions.bottomPanelHeaderHeight),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: context.width,
                margin: const EdgeInsets.only(top: 200),
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 25, top: 80),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(25)),
                child: Column(
                  children: [
                    Text(
                      userData.profile.nickname ?? '',
                      style: const TextStyle(fontSize: 56),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        userData.profile.signature ?? '',
                        style: const TextStyle(fontSize: 32, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('${userData.profile.follows} 关注'),
                          Text('${userData.profile.followeds} 粉丝'),
                          Text('${userData.profile.playlistCount} 歌单'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Obx(() => GestureDetector(
                      child: Container(
                        height: 88,
                        alignment: Alignment.center,
                        width: context.width,
                        margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 35),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(20)),
                        child: const Text(
                          '注销登录',
                          style: TextStyle(fontSize: 28, color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        AppController.to.clearUser();
                        AutoRouter.of(context).pop();
                      },
                    ))
                  ],
                ),
              ),
              SimpleExtendedImage.avatar(
                AppController.to.userData.value.profile?.avatarUrl ?? '',
                width: 260,
              ),
            ],
          ),
        ),),
    );
  }
}
