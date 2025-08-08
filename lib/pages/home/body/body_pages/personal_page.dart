import 'package:auto_route/auto_route.dart';
import 'package:bujuan/controllers/user_controller.dart';
import 'package:bujuan/pages/login/login_page_view.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../common/constants/appConstants.dart';
import '../../../../routes/router.dart';
import '../../../../controllers/app_controller.dart';

/// 收藏页
class PersonalPageView extends GetView<UserController> {
  const PersonalPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: AppController.to.loginStatus.value == LoginStatus.login,
      replacement: const LoginPageView(), // 未登录页面
      child: Obx(() => Visibility(
          visible: !controller.loading.value,
          replacement: const LoadingView(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: AppDimensions.appBarHeight),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  children: controller.userItems.map((userItem) => GestureDetector(
                    onTap: () async {
                      if (userItem.routes == 'playFm') {
                        AppController.to.openFmMode();
                      } else {
                        AppController.to.updateAppBarTitle(title: userItem.fullTitle ?? userItem.title, direction: NewAppBarTitleComingDirection.right, willRollBack: true);
                        AutoRouter.of(context).pushNamed(userItem.routes! ?? '');
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
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
              ),
              Expanded(
                child: CustomScrollView (
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverHeaderDelegate.fixedHeight( //固定高度
                        height: 50,
                        child: const Header('喜欢的音乐'),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return PlayListItem(controller.userLikedSongPlayList);
                      },
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverHeaderDelegate.fixedHeight( //固定高度
                        height: 50,
                        child: const Header('创建的歌单'),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: controller.userMadePlayLists.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PlayListItem(controller.userMadePlayLists[index]);
                      },
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverHeaderDelegate.fixedHeight( //固定高度
                        height: 50,
                        child: const Header('收藏的歌单'),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: controller.userFavoritedPlayLists.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PlayListItem(controller.userFavoritedPlayLists[index]);
                      },
                    ),
                  ]
                ).paddingSymmetric(horizontal: AppDimensions.paddingSmall),
              ),
            ],
          ),
        ))
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
            top: 30 + MediaQuery.of(context).padding.top + AppDimensions.appBarHeight,
            left: 30,
            right: 30),
        margin: const EdgeInsets.only(bottom: 16, top: 120),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hi', style: TextStyle(fontSize: 52, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  Obx(() =>
                      Text('${AppController.to.loginStatus.value == LoginStatus.login
                          ? AppController.to.userData.value.profile?.nickname
                          : '请登录'}～',
                          style: TextStyle(fontSize: 52,
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
  String? fullTitle;
  IconData iconData;
  String? routes;
  Color? color;
  UserItem(this.title, this.iconData, {this.routes, this.color, this.fullTitle});
}

typedef SliverHeaderBuilder = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  // child 为 header
  SliverHeaderDelegate({
    required this.maxHeight,
    this.minHeight = 0,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        assert(minHeight <= maxHeight && minHeight >= 0);

  //最大和最小高度相同
  SliverHeaderDelegate.fixedHeight({
    required double height,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        maxHeight = height,
        minHeight = height;

  //需要自定义builder时使用
  SliverHeaderDelegate.builder({
    required this.maxHeight,
    this.minHeight = 0,
    required this.builder,
  });

  final double maxHeight;
  final double minHeight;
  final SliverHeaderBuilder builder;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    Widget child = builder(context, shrinkOffset, overlapsContent);
    //测试代码：如果在调试模式，且子组件设置了key，则打印日志
    assert(() {
      if (child.key != null) {
        print('${child.key}: shrink: $shrinkOffset，overlaps:$overlapsContent');
      }
      return true;
    }());
    // 让 header 尽可能充满限制的空间；宽度为 Viewport 宽度，
    // 高度随着用户滑动在[minHeight,maxHeight]之间变化。
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverHeaderDelegate old) {
    return old.maxExtent != maxExtent || old.minExtent != minExtent;
  }
}