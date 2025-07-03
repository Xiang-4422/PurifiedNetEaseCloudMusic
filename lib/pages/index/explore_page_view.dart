import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/home/app_controller.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/cupertino.dart';
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
      absorbing: !AppController.to.isDrawerClosed.value,
      child: Visibility(
          visible: !controller.loading.value,
          replacement: const LoadingView(),
          child: Column(
            children:[

              Expanded(
                child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(padding: EdgeInsets.only(top: context.mediaQueryPadding.top + AppDimensions.appBarHeight + 30),),
                      SliverToBoxAdapter(
                          child: Header('推荐歌单')
                      ),
                      SliverList(delegate: SliverChildBuilderDelegate(
                        childCount: controller.playlists.length,
                        (BuildContext context, int index) => PlayListItem(controller.playlists[index])
                      )),
                      // SliverToBoxAdapter(
                      //     child: Container(
                      //       height: 400,
                      //       child: GridView.builder(
                      //         physics: BouncingScrollPhysics(),
                      //         scrollDirection: Axis.horizontal,
                      //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //             crossAxisCount: 2
                      //         ),
                      //         itemCount: controller.playlists.length,
                      //         itemBuilder: (BuildContext context, int index) {
                      //           return _buildItem(controller.playlists[index], context);
                      //         },
                      //       ),
                      //     ),
                      // ),
                      // 新歌推荐
                      SliverToBoxAdapter(
                        child: Header('新歌推荐')
                      ),
                      SliverList(delegate: SliverChildBuilderDelegate(
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        childCount: controller.newSingles.length,
                        (context, index) => SongItem(
                          index: index,
                          mediaItem: controller.newSingles[index],
                          onTap: () {
                            AppController.to.playNewPlayList(controller.newSingles, index);
                          },
                        ),
                      )),
                      // 躲开底部播放控制栏
                      SliverPadding(padding: EdgeInsets.only(top: AppDimensions.bottomPanelHeaderHeight),),
                    ],
                  ),
              ),
            ],
          ),
      ),
    ));
  }


  Widget _buildItem(PlayList albumModel, BuildContext context) {
    return Container(
      width: 120,
      child: InkWell(
        onTap: () {
          AppController.to.changeAppBarTitle(title: albumModel.name ?? "", direction: NewAppBarTitleComingDirection.right);
          context.router.push(gr.PlayListRouteView(
            playList: albumModel,
          ));
        },
        child: Column(
          children: [
            SimpleExtendedImage(
              '${albumModel.picUrl ?? ''}?param=230y230',
              height: 100,
              width: 100,
              borderRadius: BorderRadius.all(Radius.circular(25.w)),
            ),
            Container(
              height: 20,
              child: Text(
                albumModel.name ?? '',
                style: context.textTheme.titleMedium,
                // maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
