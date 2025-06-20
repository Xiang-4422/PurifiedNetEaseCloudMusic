import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/login/login_page_view.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/pages/user/personal_page_controller.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/constants/appConstants.dart';
import '../../common/constants/key.dart';
import '../../routes/router.dart';
import '../../routes/router.gr.dart' as gr;
import '../home/home_page_controller.dart';

class PageOne extends StatelessWidget {
  const PageOne({super.key});
  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}

/// 收藏页
class PersonalPageView extends GetView<PersonalPageController> {
  const PersonalPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => AbsorbPointer(
      absorbing: !HomePageController.to.isDrawerClosed.value,
      child: Visibility(
          visible: HomePageController.to.loginStatus.value == LoginStatus.login,
          replacement: const LoginPageView(), // 未登录页面
          child: Obx(() => Visibility(
                visible: !controller.loading.value,
                replacement: const LoadingView(),
                child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children:[
                      Container(
                        height: AppDimensions.appBarHeight,
                      ),
                      // 每日 FM 播客 云盘
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        childAspectRatio: 1,
                        children: controller.userItems.map((userItem) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                  if ((userItem.routes ?? '') == 'playFm') {
                                    if(HomePageController.to.isFmMode.value) {
                                      // TODO YU4422 打开播放页面，避免重复加载
                                      if (HomePageController.to.isPlaying.isFalse) {
                                        HomePageController.to.playOrPause();
                                      }
                                    } else {
                                      HomePageController.to.audioServeHandler.setRepeatMode(AudioServiceRepeatMode.all);
                                      HomePageController.to.getFmSongList();
                                    }
                                    HomePageController.to.panelController.open();
                                    HomePageController.to.panelPageController.jumpToPage(1);
                                    return;
                                  }
                                  HomePageController.to.changeAppBarTitle(title: userItem.title, direction: NewAppBarTitleComingDirection.right, willRollBack: true);
                                  AutoRouter.of(context).pushNamed(userItem.routes! ?? '');
                                },
                              icon: Icon(userItem.iconData),
                              iconSize: context.width / 4 / 3,
                            ),
                            Text(
                              userItem.title,
                              style: TextStyle(fontSize: 26.sp),
                            )
                          ],
                        )).toList(),
                      ),
                      // 喜欢的音乐
                      _buildHeader('喜欢的音乐', context),
                      ListTile(
                        leading: Obx(() => SimpleExtendedImage(
                          '${controller.userLikedSongCollection.value.coverImgUrl ?? ''}?param=200y200',
                          width: 100.w,
                          height: 100.w,
                          borderRadius: BorderRadius.circular(10.w),
                        )),
                        title: Text(
                          "我喜欢的音乐",
                          maxLines: 1,
                          style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Obx(() => Text(
                          '${controller.userLikedSongCollection.value.trackCount ?? 0} 首',
                          style: TextStyle(fontSize: 26.sp),
                        )),
                        onTap: () {
                          HomePageController.to.changeAppBarTitle(title: "我喜欢的音乐", direction: NewAppBarTitleComingDirection.right, willRollBack: true);
                          context.router.push(const gr.PlayListRouteView().copyWith(args: controller.userLikedSongCollection.value));
                        },
                      ),
                      // 创建的歌单
                      _buildHeader('创建的歌单', context),
                      Obx(() => ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        shrinkWrap: true,
                        addRepaintBoundaries: false,
                        addAutomaticKeepAlives: false,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (content, index) => PlayListItem(play: controller.userMadeSongCollectionList[index]),
                        // itemCount: controller.playlist.length > 10 ? 10 : controller.playlist.length,
                        itemCount: controller.userMadeSongCollectionList.length,
                        itemExtent: 120.w,
                      )),
                      // 收藏的歌单
                      _buildHeader('收藏的歌单', context),
                      Obx(() => ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        shrinkWrap: true,
                        addRepaintBoundaries: false,
                        addAutomaticKeepAlives: false,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (content, index) => PlayListItem(play: controller.userFavoritedSongCollectionList[index]),
                        // itemCount: controller.playlist.length > 10 ? 10 : controller.playlist.length,
                        itemCount: controller.userFavoritedSongCollectionList.length,

                        itemExtent: 120.w,
                      )),
                      Container(
                        height: AppDimensions.bottomPanelHeaderHeight,
                      ),
                    ],
                  ),
          ))
      ),
    ));
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
  Widget _buildLoginPage(context) {
    return GestureDetector(
      onTap: () => AutoRouter.of(context).pushNamed(Routes.login),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
            top: 30.w + MediaQuery.of(context).padding.top + AppDimensions.appBarHeight,
            left: 30.w,
            right: 30.w),
        margin: EdgeInsets.only(bottom: 16.w, top: 120.w),
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