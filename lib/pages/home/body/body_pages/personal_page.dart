import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/pages/login/login_page_view.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

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
    return Obx(() {
      if (controller.dateLoaded.isFalse) return const LoadingView();
      return RefreshIndicator(
        onRefresh: () async {
          controller.updateData();
          // TODO YU4422: 待添加刷新逻辑
        },
        child: CustomScrollView (
          slivers: [
            SliverPadding(padding: EdgeInsets.only(top: context.mediaQueryPadding.top)),

            // 快速播放卡片
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double userItemWidth = (constraints.maxWidth - AppDimensions.paddingSmall * userItemCountInScreen.ceil()) / userItemCountInScreen;
                  return Obx(() => Container(
                      margin: EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                      height: userItemWidth * 1.3,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: SnappingScrollPhysics(itemExtent: userItemWidth + AppDimensions.paddingSmall),
                        children: [
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
                              Visibility(
                                visible: controller.isPlaying.isTrue && (controller.curPlayListName.value == "每日推荐"),
                                replacement: IconButton(
                                    onPressed:() {
                                      if(controller.curPlayListName.value != "每日推荐") {
                                        controller.playNewPlayList(controller.todayRecommendSongs, 0, playListName: "每日推荐");
                                      } else {
                                        controller.playOrPause();
                                      }
                                    },
                                    icon: Icon(TablerIcons.player_play_filled, color: Colors.white,)
                                ),
                                child: Lottie.asset('assets/lottie/music_playing.json', width: 50),
                              )
                            ],
                          ).marginSymmetric(horizontal: AppDimensions.paddingSmall),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl: controller.isFmMode.isTrue
                                    ? (controller.curPlayingSong.value.extras?['image'] ?? '')
                                    : (controller.fmSongs[0].extras?['image'] ?? ''),
                                icon: TablerIcons.infinity,
                                title: "漫游模式",
                                onTap: () => controller.openFmMode(),
                              ),
                              Offstage(
                                  offstage: controller.isFmMode.isFalse || controller.isPlaying.isFalse,
                                  child: Lottie.asset('assets/lottie/music_playing.json', width: 50)
                              ),
                            ],
                          ).marginOnly(right: AppDimensions.paddingSmall),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl: controller.isHeartBeatMode.isTrue
                                    ? (controller.curPlayingSong.value.extras?['image'] ?? '')
                                    : controller.randomLikedSongAlbumUrl.value,
                                icon: TablerIcons.heartbeat,
                                title: "心动模式",
                                onTap: () => controller.openHeartBeatMode(controller.randomLikedSongId.value, true),
                              ),
                              Offstage(
                                  offstage: controller.isHeartBeatMode.isFalse || controller.isPlaying.isFalse,
                                  child: Lottie.asset('assets/lottie/music_playing.json', width: 50)
                              ),
                            ],
                          ).marginOnly(right: AppDimensions.paddingSmall),
                        ],
                      )
                    ),
                  );
                },
              ),
            ),

            // 推荐歌单
            SliverToBoxAdapter(
              child: Row(
                children: [
                  const Header('推荐歌单', padding: AppDimensions.paddingSmall),
                  IconButton(onPressed: controller.updateRecoPlayLists, icon: Icon(TablerIcons.refresh)),
                  Expanded(child: Container())
                ],
              ).marginOnly(top: AppDimensions.paddingSmall),
            ),
            SliverToBoxAdapter(
              child: Obx(() => PlayListWidget(
                playLists: controller.recoPlayLists.value, albumMargin: AppDimensions.paddingSmall, showSongCount: false, noScroll: true)),
            ),

            // 我创建的歌单
            SliverToBoxAdapter(
              child: const Header('我创建的歌单', padding: AppDimensions.paddingSmall).marginOnly(top: AppDimensions.paddingSmall),
            ),
            SliverToBoxAdapter(
                child: PlayListWidget(playLists: controller.userMadePlayLists, albumCountInWidget: 3.2, albumMargin: AppDimensions.paddingSmall)
            ),

            // 我收藏的歌单
            SliverToBoxAdapter(
              child: const Header('我收藏的歌单', padding: AppDimensions.paddingSmall).marginOnly(top: AppDimensions.paddingSmall),
            ),
            SliverList.builder(
              itemCount: controller.userFavoritedPlayLists.length,
              itemBuilder: (BuildContext context, int index) {
                return PlayListItem(controller.userFavoritedPlayLists[index]).paddingSymmetric(horizontal: AppDimensions.paddingSmall);
              },
            ),

            SliverPadding(padding: EdgeInsets.only(bottom: AppDimensions.bottomPanelHeaderHeight + context.mediaQueryPadding.bottom)),
          ]
        ),
      );
    });
  }
}

/// 自动吸附滚动
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
    int page = (position.pixels / itemExtent).round();

    // 限制最大滚动范围
    return math.min(page * itemExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
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

/// 去除拉伸变形效果
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


