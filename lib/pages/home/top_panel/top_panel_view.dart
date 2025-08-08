
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:bujuan/widget/request_widget/request_view.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/constants/appConstants.dart';
import '../../../common/netease_api/src/api/play/bean.dart';
import '../../../common/netease_api/src/api/search/bean.dart';
import '../../../common/netease_api/src/dio_ext.dart';
import '../../../common/netease_api/src/netease_handler.dart';
import '../../../widget/request_widget/request_loadmore_view.dart';
import '../../play_list/playlist_page_view.dart';

class TopPanelView extends GetView<AppController> {
  const TopPanelView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景层
        AnimatedBuilder(
          animation: AppController.to.topPanelAnimationController,
          builder: (BuildContext context, Widget? child) {
            return Stack(
              children: [
                // 磨砂层
                BlurryContainer(
                  blur: 15 * AppController.to.topPanelAnimationController.value,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.zero,
                  color: context.theme.colorScheme.primary.withOpacity(AppController.to.topPanelAnimationController.value),
                  child: Container(),
                )
              ],
            );
          },
        ),
        DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Container(
                height: context.mediaQueryPadding.top,
              ),
              Expanded(
                child: Obx(() => Container(
                  child: Visibility(
                      visible: controller.searchContent.value.isEmpty,
                      // 搜索结果
                      replacement: Obx(() => TabBarView(
                      children: [
                        _buildTopPanelCard(context, RequestLoadMoreWidget<SearchSongWrapX, Song2>(
                          dioMetaData: searchDioMetaData(controller.searchContent.value, 1),
                          childBuilder: (List<Song2> songs) {
                            var list = AppController.to.song2ToMedia(songs);
                            return ListView.builder(
                              itemBuilder: (context, index) => SongItem(
                                index: index,
                                playlist: list,
                              ),
                              itemCount: list.length,
                            );
                          },
                          listKey: const ['result', 'songs'],
                        ),),
                        _buildTopPanelCard(context, RequestLoadMoreWidget<SearchPlaylistWrapX, PlayList>(
                          dioMetaData: searchDioMetaData(controller.searchContent.value, 1000),
                          listKey: const ['result', 'playlists'],
                          childBuilder: (List<PlayList> playlist) {
                            return ListView.builder(
                              itemCount: playlist.length,
                              itemBuilder: (context, index) => PlayListItem(
                                playlist[index],
                                beforeOnTap: () async {
                                  AppController.to.bottomPanelController.close();
                                  await AppController.to.topPanelController.close();
                                },
                              ),
                            );
                          },
                        )),
                        _buildTopPanelCard(context, RequestLoadMoreWidget<SearchAlbumsWrapX, Album>(
                          dioMetaData: searchDioMetaData(controller.searchContent.value, 10),
                          childBuilder: (List<Album> albums) {
                            return ListView.builder(
                              itemBuilder: (context, index) => AlbumItem(
                                album: albums[index],
                                beforeOnTap: () async {
                                  AppController.to.bottomPanelController.close();
                                  await AppController.to.topPanelController.close();
                                },
                              ),
                              itemCount: albums.length,
                            );
                          },
                          listKey: const ['result', 'albums'],
                        )),
                        _buildTopPanelCard(context, RequestLoadMoreWidget<SearchArtistsWrapX, Artist>(
                          dioMetaData: searchDioMetaData(controller.searchContent.value, 100),
                          listKey: const ['result', 'artists'],
                          childBuilder: (List<Artist> artists) {
                            return ListView.builder(
                              itemBuilder: (context, index) => ArtistsItem(
                                artist: artists[index],
                                beforeOnTap: () async {
                                  AppController.to.bottomPanelController.close();
                                  await AppController.to.topPanelController.close();
                                },
                              ),
                              itemCount: artists.length,
                            );
                          },
                        )),
                      ],
                                            )),
                      // 热门搜索
                      child: _buildTopPanelCard(context, RequestWidget<SearchKeyWrapX>(
                          dioMetaData: searchHotKeyDioMetaData(),
                          childBuilder: (data) => ListView(
                            padding: EdgeInsets.zero,
                            children: data.result.hots.map((e) => UniversalListTile(
                              titleString: e.first ?? '',
                              onTap: () {
                                controller.searchFocusNode.unfocus();
                                controller.searchTextEditingController.text = e.first ?? '';
                              },
                            )).toList(),
                          )
                      )).marginOnly(top: AppDimensions.paddingSmall),
                    ),
                )),
              ),
              Container(
                color: context.theme.colorScheme.onPrimary.withOpacity(0.1),
                child: Column(
                  children: [
                    // TabBar
                    Obx(() => Offstage(
                        offstage: controller.searchContent.value.isEmpty,
                        child: MyTabBar(
                          height: AppDimensions.appBarHeight / 3,
                          tabs: [
                            Text(
                              "单曲",
                              style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onPrimary.withOpacity(0.5)),
                            ),
                            Text(
                              "歌单",
                              style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onPrimary.withOpacity(0.5)),
                            ),
                            Text(
                              "专辑",
                              style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onPrimary.withOpacity(0.5)),
                            ),
                            Text(
                              "歌手",
                              style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onPrimary.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      )),
                    // 搜索栏
                    _buildSearchBar(context, AppDimensions.appBarHeight * 2/3),
                  ],
                ),
              ),
              // Panel关闭时占位
              Obx(() => Container(
                height: AppController.to.topPanelFullyClosed.isTrue
                    ? AppDimensions.appBarHeight + context.mediaQueryPadding.top
                    : AppController.to.keyBoardHeight.value,
              ))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, double searchBarHeight) {
    double iconSize = searchBarHeight / 2;
    double iconPadding = searchBarHeight / 8;
    return SizedBox(
        height: searchBarHeight,
        child: Row(
          children: [
            IconButton(
              iconSize: iconSize,
              padding: EdgeInsets.all(iconPadding),
              // style: IconButton.styleFrom(
              //   backgroundColor: context.theme.colorScheme.onPrimary.withOpacity(0.1),
              // ),
              icon: const Icon(
                TablerIcons.search,
              ),
              onPressed: () {
                // controller.searchContent.value = controller.searchTextEditingController.text;
              },
            ).marginAll(iconPadding),
            Expanded(
              child: TextField(
                controller: controller.searchTextEditingController,
                focusNode: controller.searchFocusNode,
                cursorColor: Theme.of(context).primaryColor.withOpacity(.4),
                style: context.textTheme.titleMedium,
                decoration: InputDecoration(
                    hintText: '输入歌曲、歌手、歌单...',
                    hintStyle: context.textTheme.titleMedium!.copyWith(
                        color: context.textTheme.titleMedium!.color!.withOpacity(0.2),
                    ),
                    border: const UnderlineInputBorder(borderSide: BorderSide.none),
                    isDense: true
                ),
              ),
            ),
            Obx(() => Visibility(
              visible: controller.searchContent.isNotEmpty,
              replacement: IconButton(
                iconSize: iconSize,
                // padding: EdgeInsets.all(AppDimensions.appBarHeight / 16),
                padding: EdgeInsets.all(iconPadding),
                style: IconButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.onPrimary.withOpacity(0.1),
                ),
                icon: const Icon(
                  TablerIcons.arrow_up,
                ),
                onPressed: () {
                  controller.topPanelController.close();
                },
              ).marginAll(iconPadding),
              child: IconButton(
                iconSize: iconSize,
                padding: EdgeInsets.all(iconPadding),
                style: IconButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.onPrimary.withOpacity(0.1),
                ),
                icon: const Icon(
                  TablerIcons.x,
                ),
                onPressed: () {
                  controller.searchTextEditingController.clear();
                  controller.searchFocusNode.requestFocus();
                },
              ).marginAll(iconPadding),
            ))
          ],
        )
    );
  }

  Widget _buildTopPanelCard(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
      child: child,
    );
  }

  DioMetaData searchDioMetaData(String keyword, int type, {int offset = 0, int limit = 30}) {
    // type代表搜索类型，1为单曲，10为专辑，100为歌手，1000为歌单
    return DioMetaData(joinUri('/weapi/cloudsearch/pc'), data: {'s': keyword, 'type': type, 'limit': limit, 'offset': offset}, options: joinOptions());
  }
  DioMetaData searchHotKeyDioMetaData() {
    return DioMetaData(joinUri('/weapi/search/hot'), data: {'type': 1111}, options: joinOptions(userAgent: UserAgent.Mobile));
  }
}

class TopPanelHeaderAppBar extends GetView<AppController> {
  const TopPanelHeaderAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
      padding: EdgeInsets.only(top: context.mediaQueryPadding.top,),
      child: Obx(() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // 旧widget出场和新widget入场动画都在这里构建
          // 判断当前标题是旧标题还是新标题
          bool isOldWidgetAnimation = animation.status == AnimationStatus.completed;
          bool isReversing = animation.status == AnimationStatus.reverse;

          // 入场和出场的动画
          switch(controller.comingDirection) {
            case NewAppBarTitleComingDirection.up:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: isOldWidgetAnimation || isReversing
                      ? const Offset(0, 1)   // 旧标题出场（beging和end反转）
                      : const Offset(0, -1),  // 新标题入场
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: isOldWidgetAnimation || isReversing
                        ? 0   // 旧标题出场（beging和end反转）
                        : 1,  // 新标题入场
                    end: 1,
                  ).animate(animation),
                  child: child,
                ),
              );
            case NewAppBarTitleComingDirection.down:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: isOldWidgetAnimation || isReversing
                      ? const Offset(0, -1)   // 旧标题出场（beging和end反转）
                      : const Offset(0, 1),  // 新标题入场
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: isOldWidgetAnimation || isReversing
                        ? 0   // 旧标题出场（beging和end反转）
                        : 1,  // 新标题入场
                    end: 1,
                  ).animate(animation),
                  child: child,
                ),
              );
            case NewAppBarTitleComingDirection.left:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: isOldWidgetAnimation || isReversing
                      ? const Offset(1 , 0)   // 旧标题出场（beging和end反转）
                      : const Offset(-1 , 0),  // 新标题入场
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: isOldWidgetAnimation || isReversing
                        ? 0   // 旧标题出场（beging和end反转）
                        : 1,  // 新标题入场
                    end: 1,
                  ).animate(animation),
                  child: child,
                ),
              );
            case NewAppBarTitleComingDirection.right:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: isOldWidgetAnimation || isReversing
                      ? const Offset(-1 , 0)   // 旧标题出场（beging和end反转）
                      : const Offset(1, 0),  // 新标题入场
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: isOldWidgetAnimation || isReversing
                        ? 0   // 旧标题出场（beging和end反转）
                        : 1,  // 新标题入场
                    end: 1,
                  ).animate(animation),
                  child: child,
                ),
              );
            case NewAppBarTitleComingDirection.none:
              return FadeTransition(opacity: Tween<double>(begin: 0, end: 1).animate(animation), child: child);
          }
        },
        child: Stack(
          key: ValueKey<String>(controller.curPageTitle.value),
          children: [
            // 显示字体描边
            // FittedBox(
            //   fit: BoxFit.scaleDown,
            //   child: RichText(
            //     textAlign: TextAlign.center,
            //     text: TextSpan(
            //       //  标题（当前页/歌名）
            //         text: controller.curPageTitle.value,
            //         style: context.textTheme.titleLarge?.copyWith(
            //           foreground: Paint()
            //             ..style = PaintingStyle.stroke
            //             ..strokeWidth = 2
            //             ..color = Colors.black,
            //           // color: controller.curPageTitleColor.value,
            //         ),
            //         children: [
            //           TextSpan(
            //             // 副标题（歌手名）
            //             text: controller.curPageSubTitle.value.isEmpty ? "" : '\n${controller.curPageSubTitle.value}',
            //             style: context.textTheme.titleLarge?.copyWith(
            //               fontSize: context.textTheme.titleLarge!.fontSize! / 2,
            //               color: controller.curPageTitleColor.value.withOpacity(0.5),
            //             ),
            //           ),
            //         ]
            //     ),
            //   ),
            // ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  //  标题（当前页/歌名）
                    text: controller.curPageTitle.value,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: controller.curPageTitleColor.value,
                    ),
                    children: [
                      TextSpan(
                        // 副标题（歌手名）
                        text: controller.curPageSubTitle.value.isEmpty ? "" : '\n${controller.curPageSubTitle.value}',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: context.textTheme.titleLarge!.fontSize! / 2,
                          color: controller.curPageTitleColor.value.withOpacity(0.5),
                        ),
                      ),
                    ]
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}