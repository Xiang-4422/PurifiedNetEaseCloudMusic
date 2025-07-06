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
import '../../common/constants/other.dart';
import '../../routes/router.dart';
import '../../routes/router.gr.dart' as gr;
import '../home/app_controller.dart';

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
      absorbing: !AppController.to.isDrawerClosed.value,
      child: Visibility(
          visible: AppController.to.loginStatus.value == LoginStatus.login,
          replacement: const LoginPageView(), // 未登录页面
          child: Obx(() => Visibility(
            visible: !controller.loading.value,
            replacement: const LoadingView(),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                  top: AppDimensions.appBarHeight,
                  bottom: AppDimensions.bottomPanelHeaderHeight
              ),
              children:[
                // 每日 FM 播客 云盘
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  children: controller.userItems.map((userItem) => GestureDetector(
                    onTap: () async {
                      if (userItem.routes == 'playFm') {
                        AppController.to.openFmMode();
                      } else {
                        AppController.to.changeAppBarTitle(title: userItem.title, direction: NewAppBarTitleComingDirection.right, willRollBack: true);
                        AutoRouter.of(context).pushNamed(userItem.routes! ?? '');
                      }
                    },
                    child: Container(
                      // color: Colors.red,
                      alignment: Alignment.center,
                      // padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            userItem.iconData,
                            // size: context.width / 4  / 3,
                          ),
                          Text(
                            userItem.title,
                            style: context.theme.textTheme.titleMedium,
                          )
                        ],
                      ),
                    ),
                  )).toList(),
                ),
                // 喜欢的音乐
                const Header('喜欢的音乐'),
                PlayListItem(controller.userLikedSongPlayList),
                const Header('创建的歌单'),
                Obx(() => ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  addRepaintBoundaries: false,
                  addAutomaticKeepAlives: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.userMadePlayLists.length,
                  itemBuilder: (content, index) => PlayListItem(controller.userMadePlayLists[index]),
                )),
                const Header('收藏的歌单'),
                Obx(() => ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  addRepaintBoundaries: false,
                  addAutomaticKeepAlives: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.userFavoritedPlayLists.length,
                  itemBuilder: (content, index) => PlayListItem(controller.userFavoritedPlayLists[index]),
                )),
              ],
            ),
          ))
      ),
    ));
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
                      Text('${AppController.to.loginStatus.value == LoginStatus.login
                          ? AppController.to.userData.value.profile?.nickname
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