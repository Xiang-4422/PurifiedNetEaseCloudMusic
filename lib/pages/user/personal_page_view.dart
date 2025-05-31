import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/icon.dart';
import 'package:bujuan/pages/play_list/playlist_view.dart';
import 'package:bujuan/pages/playlist_manager/playlist_mananger_binding.dart';
import 'package:bujuan/pages/user/personal_page_controller.dart';
import 'package:bujuan/widget/commen_widget/my_appbar_widget.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import '../../common/constants/key.dart';
import '../../common/netease_api/src/api/play/bean.dart';
import '../../routes/router.dart';
import '../../routes/router.gr.dart' as gr;
import '../../widget/draggable_home.dart';
import '../home/home_page_controller.dart';
import '../home/view/panel_view.dart';

/// 收藏页
class PersonalPageView extends GetView<PersonalPageController> {
  const PersonalPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // controller.context = context;
    UserBinding().dependencies();
    return Obx(() => Visibility(
        visible: HomePageController.to.loginStatus.value == LoginStatus.login,
        replacement: _buildMeInfo(context), // 未登录页面
        child: Obx(() => Visibility(
              visible: !controller.loading.value,
              replacement: const LoadingView(),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                extendBodyBehindAppBar: true,
                body: ListView(
                  physics: const BouncingScrollPhysics(),
                  children:[
                    // 每日 FM 播客 云盘
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: .75,
                      //设置内边距
                      //设置横向间距
                      crossAxisSpacing: 40,
                      //设置主轴间距
                      mainAxisSpacing: 10,
                      children: controller.userItems
                          .map((userItem) => Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if ((userItem.routes ?? '') == 'playFm') {
                                HomePageController.to.audioServeHandler.setRepeatMode(AudioServiceRepeatMode.all);
                                HomePageController.to.audioServiceRepeatMode.value = AudioServiceRepeatMode.all;
                                HomePageController.to.box.put(repeatModeSp, AudioServiceRepeatMode.all.name);
                                HomePageController.to.getFmSongList();
                                return;
                              }
                              AutoRouter.of(context).pushNamed(userItem.routes ?? '');
                            },
                            icon: Icon(userItem.iconData),
                            iconSize: 52.w,
                          ),
                          Text(
                            userItem.title,
                            style: TextStyle(fontSize: 26.sp),
                          )
                        ],
                      ))
                          .toList(),
                    ),
                    // 喜欢的音乐
                    _buildHeader('喜欢的音乐', context),
                    ListTile(
                      leading: Obx(() => SimpleExtendedImage(
                        '${controller.play.value.coverImgUrl ?? ''}?param=200y200',
                        width: 100.w,
                        height: 100.w,
                        borderRadius: BorderRadius.circular(100.w),
                      )),
                      title: Obx(() => Text(
                        controller.play.value.name ?? '',
                        maxLines: 1,
                        style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
                      )),
                      subtitle: Obx(() => Text(
                        '${controller.play.value.trackCount ?? 0} 首',
                        style: TextStyle(fontSize: 26.sp),
                      )),
                      onTap: () => context.router.push(const gr.PlayListView().copyWith(args: controller.play.value)),
                    ),
                    // 收藏的歌单
                    _buildHeader('我的歌单', context, actionStr: '查看/管理'),
                    Obx(() => ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      shrinkWrap: true,
                      addRepaintBoundaries: false,
                      addAutomaticKeepAlives: false,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (content, index) => PlayListItem(play: controller.playlist[index]),
                      itemCount: controller.playlist.length > 10 ? 10 : controller.playlist.length,
                      itemExtent: 120.w,
                    )),
                  ],
                ),
            )
        ))));
  }

  /// 喜欢的音乐/我的歌单标题栏
  Widget _buildHeader(String title, context, {String? actionStr}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.w),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(6.w)), width: 10.w, height: 10.w),
          Padding(padding: EdgeInsets.symmetric(horizontal: 6.w)),
          Text(
            title,
            style: TextStyle(fontSize: 32.sp, color: Theme.of(context).iconTheme.color, fontWeight: FontWeight.bold),
          ),
          const Expanded(child: SizedBox.shrink()),
          Visibility(
            visible: actionStr != null,
            child: TextButton(
                onPressed: () {
                  AutoRouter.of(context).pushNamed(Routes.playlistManager);
                },
                child: Text(
                  actionStr ?? '',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 28.sp),
                )),
          )
          // Icon(Icons.keyboard_arrow_right_outlined,color: Colors.black87.withOpacity(.6))
        ],
      ),
    );
  }

  /// 未登录
  Widget _buildMeInfo(context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(left: 30.w, top: 30.w, right: 30.w),
        margin: EdgeInsets.only(bottom: 16.w, top: 120.w),
        height: 240.w,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi', style: TextStyle(fontSize: 52.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8.w)),
                  Obx(() =>
                      Text('${HomePageController.to.loginStatus.value == LoginStatus.login
                          ? HomePageController.to.userData.value.profile?.nickname
                          : '请登录'}～',
                          style: TextStyle(fontSize: 52.sp,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ],
        ),
    ),
      onTap: () {
        if (HomePageController.to.loginStatus.value == LoginStatus.login) {
          return;
        }
        AutoRouter.of(context).pushNamed(Routes.login);
      },
        );
  }
}

class UserItem {
  String title;
  IconData iconData;
  String? routes;
  Color? color;

  UserItem(this.title, this.iconData, {this.routes, this.color});
}