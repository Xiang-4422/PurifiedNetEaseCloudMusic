import 'package:auto_route/auto_route.dart';
import 'package:bujuan/controllers/user_controller.dart';
import 'package:bujuan/pages/login/login_page_view.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:get/get.dart';

import '../../../../common/constants/appConstants.dart';
import '../../../../routes/router.dart';
import '../../../../controllers/app_controller.dart';
import '../../../../widget/keep_alive_wrapper.dart';
import '../../../../widget/simple_extended_image.dart';

/// 收藏页
class PersonalPageView extends GetView<UserController> {
  const PersonalPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double albumWidth = (context.width - AppDimensions.paddingSmall * 3) / 2.5;

    return Obx(() => Visibility(
      visible: !controller.loading.value,
      replacement: const LoadingView(),
      child: CustomScrollView (
        slivers: [
          SliverPadding(padding: EdgeInsets.only(top: AppDimensions.appBarHeight + context.mediaQueryPadding.top)),
          SliverList.builder(
            itemCount: controller.userItems.length,
            itemBuilder: (context, index) {
              UserItem userItem = controller.userItems[index];
              return UniversalListTile(titleString: userItem.title);
            },
          ),
          SliverToBoxAdapter(
              child: const Header('创建的歌单').paddingSymmetric(horizontal: AppDimensions.paddingSmall),
          ),
          SliverToBoxAdapter(
              child: Container(
                height: albumWidth * 1.5,
                child: CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: SnappingScrollPhysics(itemExtent: albumWidth + AppDimensions.paddingSmall),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsetsGeometry.symmetric(horizontal: AppDimensions.paddingSmall),
                      sliver: SliverGrid.builder(

                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: AppDimensions.paddingSmall,
                          childAspectRatio: 1.5,       // 宽高比
                        ),
                        addAutomaticKeepAlives: true,
                        itemCount: controller.userMadePlayLists.length,
                        itemBuilder: (context, index) {
                          return KeepAliveWrapper(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SimpleExtendedImage.avatar(
                                    width: albumWidth,
                                    shape: BoxShape.rectangle,
                                    '${controller.userMadePlayLists[index].coverImgUrl}?param=200y200'
                                ),
                                Text(
                                  "${controller.userMadePlayLists[index].name}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodyMedium,
                                ),
                                Text(
                                  "${controller.userMadePlayLists[index].trackCount == null || controller.userMadePlayLists[index].trackCount == 0 ? null : "${controller.userMadePlayLists[index].trackCount}首"}",
                                  maxLines: 1,
                                  style: context.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
          ),
          SliverToBoxAdapter(
              child: const Header('收藏的歌单').paddingSymmetric(horizontal: AppDimensions.paddingSmall),
          ),
          SliverList.builder(
            itemCount: controller.userFavoritedPlayLists.length,
            itemBuilder: (BuildContext context, int index) {
              return PlayListItem(controller.userFavoritedPlayLists[index]).paddingSymmetric(horizontal: AppDimensions.paddingSmall);
            },
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: AppDimensions.bottomPanelHeaderHeight)),
        ]
      ),
    ));
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

class SnappingScrollPhysics extends ScrollPhysics {
  final double itemExtent; // 每个格子的宽度(含间距)

  const SnappingScrollPhysics({
    required this.itemExtent,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  SnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappingScrollPhysics(
      itemExtent: itemExtent,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = position.pixels / itemExtent;


    page = page.ceilToDouble();

    // if (velocity > 0) {
    //   // 向左滑动，吸附到第一个完全显示的元素，向上取整
    //   page = page.ceilToDouble();
    // } else {
    //   // 向右滑动，吸附到第一个元素，向下取整
    //   page = page.floorToDouble();
    // }

    // 限制最大滚动范围
    return math.min(page * itemExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {

    final Tolerance tolerance = this.tolerance;
    // 快速滑动或超出边界，使用默认惯性滑动
    if (position.outOfRange || velocity.abs() > tolerance.velocity) {
      return super.createBallisticSimulation(position, velocity);
    }
    final double target = _getTargetPixels(position, tolerance, velocity);
    // 慢速滑动，弹簧动画吸附
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}

class NoStretchBouncingScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    // 不显示拉伸效果（去掉水波纹或拉伸）
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // 使用 iOS 弹簧回弹
    return const BouncingScrollPhysics();
  }
}
