import 'package:audio_service/audio_service.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/common_widget.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/widget/request_widget/request_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';

import '../../common/netease_api/src/api/play/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';
import '../../widget/simple_extended_image.dart';
import '../play_list/playlist_page_view.dart';

class TodayPageView extends GetView<AppController> {
  const TodayPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String albumUrl = controller.todayRecommendSongs[0].extras?['image'] ?? '';

    return Container(
      color: Colors.white,
      child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              toolbarHeight: AppDimensions.appBarHeight - context.mediaQueryPadding.top + AppDimensions.paddingLarge,
              collapsedHeight: AppDimensions.appBarHeight - context.mediaQueryPadding.top + AppDimensions.paddingLarge,
              expandedHeight: context.width - context.mediaQueryPadding.top,
              pinned: true,
              stretch: true,
              automaticallyImplyLeading: false,
              foregroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const <StretchMode>[
                  StretchMode.zoomBackground, // 背景图缩放
                  // StretchMode.blurBackground, // 背景图模糊
                  // StretchMode.fadeTitle,      // 标题渐隐
                ],
                titlePadding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium, left: AppDimensions.paddingMedium, right: AppDimensions.paddingMedium),
                title: BlurryContainer(
                  padding: EdgeInsetsGeometry.zero,
                  borderRadius: BorderRadius.circular(9999),
                  color: Colors.white.withOpacity(0.5),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Text(
                                " 每日推荐",
                                maxLines: 1,
                                style: context.textTheme.titleLarge!.copyWith(
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2
                                    ..color = Colors.black,
                                ),
                              ),
                              Text(
                                " 每日推荐",
                                maxLines: 1,
                                style: context.textTheme.titleLarge!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      BlurryContainer(
                        padding: EdgeInsetsGeometry.zero,
                        borderRadius: BorderRadius.circular(9999),
                        color: Colors.red,
                        child: IconButton(
                            icon: Icon(
                              TablerIcons.player_play_filled,
                              color: Colors.white,
                            ),
                            onPressed: () => AppController.to.playNewPlayList(controller.todayRecommendSongs, 0, playListName: "每日推荐")
                        ),
                      )
                    ],
                  ),
                ),
                // centerTitle: true,
                expandedTitleScale: 1.5,
                background: SimpleExtendedImage(
                  width: context.width,
                  height: context.width,
                  albumUrl,
                ),
              ),
              // bottom:
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: controller.todayRecommendSongs.length + 1,
                    (BuildContext context, int index) {
                  if (index == controller.todayRecommendSongs.length) {
                    return const SizedBox(
                      height: AppDimensions.bottomPanelHeaderHeight,
                    );
                  }
                  return SongItem(playlist: controller.todayRecommendSongs, index: index, playListName: "今日推荐", stringColor: Colors.black, showIndex: true).paddingSymmetric(horizontal: AppDimensions.paddingMedium);
                },
              ),
            ),
          ]
      ),
    );
  }

}
