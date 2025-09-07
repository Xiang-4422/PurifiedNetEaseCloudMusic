import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/pages/login/login_page_view.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'dart:math' as math;

import 'package:get/get.dart';

import '../../../../common/common_widget.dart';
import '../../../../common/constants/appConstants.dart';
import '../../../../routes/router.dart';
import '../../../../controllers/app_controller.dart';
import '../../../../routes/router.gr.dart' as gr;
import '../../../../widget/keep_alive_wrapper.dart';
import '../../../../widget/simple_extended_image.dart';

/// 收藏页
class PersonalPageView extends GetView<AppController> {
  const PersonalPageView({Key? key}) : super(key: key);

  final double albumCountInScreen = 3.2;
  final double userItemCountInScreen = 2.5;

  @override
  Widget build(BuildContext context) {

    // 根据屏幕宽度计算专辑宽度
    double albumWidth = (context.width - AppDimensions.paddingSmall * albumCountInScreen.ceil()) / albumCountInScreen;
    double userItemWidth = (context.width - AppDimensions.paddingSmall * userItemCountInScreen.ceil()) / userItemCountInScreen;

    return RefreshIndicator(
      onRefresh: () async {
        controller.updateData();
        // TODO YU4422: 待添加刷新逻辑
      },
      child: Obx(() => controller.dateLoaded.isFalse ? const LoadingView() : CustomScrollView (
          slivers: [
            SliverPadding(padding: EdgeInsets.only(top: context.mediaQueryPadding.top)),

            // 每日推荐、FM
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
                height: userItemWidth * 1.3,
                child: CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: SnappingScrollPhysics(itemExtent: userItemWidth + AppDimensions.paddingSmall),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsetsGeometry.only(left: AppDimensions.paddingSmall),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl: controller.todayRecommendSongs[0].extras?['image'],
                                icon: TablerIcons.calendar,
                                title: "每日推荐",
                                onTap: () => context.router.push(const gr.TodayRouteView()),
                              ),
                              IconButton(onPressed:() => controller.playNewPlayList(controller.todayRecommendSongs, 0, playListName: "今日推荐"), icon: Icon(TablerIcons.player_play_filled, color: Colors.white,))
                            ],
                          ).marginOnly(right: AppDimensions.paddingSmall),
                          QuickStartCard(
                            width: userItemWidth,
                            height: userItemWidth * 1.3,
                            albumUrl: controller.isFmMode.isTrue
                                ? (controller.curPlayingSong.value.extras?['image'] ?? '')
                                : (controller.fmSongs[0].extras?['image'] ?? ''),
                            icon: TablerIcons.infinity,
                            title: "漫游模式",
                            onTap: () => controller.openFmMode(),
                          ).marginOnly(right: AppDimensions.paddingSmall),
                          QuickStartCard(
                            width: userItemWidth,
                            height: userItemWidth * 1.3,
                            albumUrl: controller.isHeartBeatMode.isTrue
                                ? (controller.curPlayingSong.value.extras?['image'] ?? '')
                                : controller.randomLikedSongAlbumUrl.value,
                            icon: TablerIcons.heartbeat,
                            title: "心动模式",
                            onTap: () => controller.openHeartBeatMode(controller.randomLikedSongId.value, true),
                          ).marginOnly(right: AppDimensions.paddingSmall),
                        ]),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // 创建的歌单
            SliverToBoxAdapter(
              child: const Header('我的歌单').paddingSymmetric(horizontal: AppDimensions.paddingSmall),
            ),
            SliverToBoxAdapter(
                child: Container(
                  height: albumWidth * 1.6,
                  child: CustomScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: SnappingScrollPhysics(itemExtent: albumWidth + AppDimensions.paddingSmall),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsetsGeometry.only(left: AppDimensions.paddingSmall),
                        sliver: SliverList.builder(
                          addAutomaticKeepAlives: true,
                          itemCount: controller.userMadePlayLists.length,
                          itemBuilder: (context, index) {
                            return KeepAliveWrapper(
                              child: Container(
                                width: albumWidth,
                                margin: EdgeInsets.only(
                                  right: AppDimensions.paddingSmall,
                                  top: AppDimensions.paddingSmall,
                                  bottom: AppDimensions.paddingSmall,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    context.router.push(gr.PlayListRouteView(playList: controller.userMadePlayLists[index]));
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SimpleExtendedImage.avatar(
                                          width: albumWidth,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
                                          '${controller.userMadePlayLists[index].coverImgUrl}?param=200y200'
                                      ),
                                      Expanded(child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
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
                                      ))
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                )
            ),

            // 收藏的歌单
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
      ),
    );
  }
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

class QuickStartCard extends StatelessWidget {
  const QuickStartCard({Key? key, required this.width, required this.height, this.onTap, required this.albumUrl, this.icon, required this.title}) : super(key: key);

  final double width;
  final double height;
  final Function()? onTap;
  final String albumUrl;
  final IconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    bool isEnabled = onTap != null;
    
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5, // Make disabled cards semi-transparent
        child: Container(
          width: width,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
          ),
          child: AsyncImageColor(
            imageUrl: albumUrl,
            child: Column(
              children: [
                Expanded(child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon == null
                          ? const SizedBox.shrink()
                          : Icon(
                            icon,
                            color: Colors.white,
                          ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
                SimpleExtendedImage(
                  height: width,
                  width: width,
                  albumUrl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

