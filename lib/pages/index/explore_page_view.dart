import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';
import '../../routes/router.gr.dart' as gr;
import '../../widget/simple_extended_image.dart';
import '../play_list/playlist_page_view.dart';
import 'explore_page_controller.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});
  @override
  Widget build(BuildContext context) {
    return AutoRouter();
  }
}

/// 发现页
class ExplorePageView extends GetView<ExplorePageController> {
  const ExplorePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => AbsorbPointer(
      absorbing: !HomePageController.to.isDrawerClosed.value,
      child: Visibility(
          visible: !controller.loading.value,
          replacement: const LoadingView(),
          child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(padding: EdgeInsets.only(top: context.mediaQueryPadding.top + AppDimensions.appBarHeight),),
                // const SliverPadding(padding: EdgeInsets.only(top: 10),),
                // 歌单推荐
                SliverToBoxAdapter(
                  child: _buildHeader('歌单推荐', context),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0),
                      itemBuilder: (context, index) => _buildItem(controller.playlists[index], context),
                      itemCount: controller.playlists.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false
                  ),
                ),
                // 新歌推荐
                SliverToBoxAdapter(
                  child: _buildHeader('新歌推荐', context)
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverFixedExtentList(
                      delegate: SliverChildBuilderDelegate(
                              (context, index) => SongItemShowImage(
                            index: index,
                            mediaItem: controller.newSingles[index],
                            onTap: () {
                              HomePageController.to.playNewPlayListByIndex(index, 'queueTitle', playList: controller.newSingles);
                            },
                          ),
                          childCount: controller.newSingles.length,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: false),
                      itemExtent: 140.w),
                ),
                // 躲开底部播放控制栏
                SliverPadding(padding: EdgeInsets.only(top: AppDimensions.bottomPanelHeaderHeight),),
              ],
            ),
      ),
    ));
  }

  Widget _buildHeader(String title, BuildContext context, {VoidCallback? onTap}) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 30.w),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(6.w)),
              width: 10.w,
              height: 10.w,
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 15.w)),
            Text(
              title,
              style: TextStyle(fontSize: 34.sp, color: Theme.of(context).iconTheme.color),
            ),
          ],
        ),
      ),
      onTap: () => onTap?.call(),
    );
  }

  Widget _buildItem(PlayList albumModel, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SimpleExtendedImage(
              '${albumModel.picUrl ?? ''}?param=230y230',
              borderRadius: BorderRadius.all(Radius.circular(25.w)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.w),
                  child: Text(
                    albumModel.name ?? '',
                    style: TextStyle(fontSize: 28.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          HomePageController.to.changeAppBarTitle(title: albumModel.name ?? "", direction: NewAppBarTitleComingDirection.right);
          OtherUtils.getImageColor('${albumModel.coverImgUrl ?? ''}?param=500y500').then((paletteGenerator) {
            Color albumColor = context.isDarkMode
                ? paletteGenerator.lightMutedColor?.color
                ?? paletteGenerator.lightVibrantColor?.color
                ?? Colors.white
                : paletteGenerator.darkMutedColor?.color
                ?? paletteGenerator.darkVibrantColor?.color
                ?? Colors.black;
            Color widgetColor = ThemeData.estimateBrightnessForColor(albumColor) == Brightness.light
                ? Colors.black
                : Colors.white;
            context.router.push(gr.PlayListRouteView(
              playList: albumModel,
              albumColor: albumColor,
              widgetColor: widgetColor,
            ));
          });
        },
      ),
    );
  }

// Widget _buildTopCard() {
//   return ListView.builder(
//     padding: EdgeInsets.symmetric(horizontal: 15.w),
//     shrinkWrap: true,
//     physics: const NeverScrollableScrollPhysics(),
//     itemBuilder: (context, index) => _buildSongItem(controller.songs[index], index),
//     itemCount: controller.songs.length > 10 ? 10 : controller.songs.length,
//   );
// }

// Widget _buildSongItem(SongModel data, int index) {
//   return InkWell(
//     child: Container(
//       margin: EdgeInsets.symmetric(vertical: 10.w),
//       padding: EdgeInsets.symmetric(vertical: 5.w),
//       child: Row(
//         children: [
//           SimpleExtendedImage(
//             '${HomeController.to.directoryPath}${data.albumId}',
//             cacheWidth: 200,
//             width: 90.w,
//             height: 90.w,
//             borderRadius: BorderRadius.circular(10.w),
//           ),
//           Expanded(
//               child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   data.title,
//                   style: TextStyle(fontSize: 28.sp),
//                 ),
//                 Text(
//                   '${data.artist ?? 'No Artist'} - ${ImageUtils.getTimeStamp(data.duration ?? 0)}',
//                   style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.normal),
//                 ),
//               ],
//             ),
//           )),
//         ],
//       ),
//     ),
//     onTap: () => controller.play(index),
//   );
// }
}
