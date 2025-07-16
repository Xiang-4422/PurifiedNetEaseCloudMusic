import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/widget/request_widget/request_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import 'package:bujuan/routes/router.gr.dart' as gr;
import '../../../common/constants/appConstants.dart';
import '../../../common/netease_api/src/api/play/bean.dart';
import '../../../common/netease_api/src/api/search/bean.dart';
import '../../../common/netease_api/src/dio_ext.dart';
import '../../../common/netease_api/src/netease_handler.dart';
import '../../../widget/custom_filed.dart';
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
                  color: context.theme.colorScheme.onPrimary.withOpacity(0.5 * AppController.to.topPanelAnimationController.value),
                  child: Container(),
                )
              ],
            );
          },
        ),
        Column(
          children: [
            // 搜索栏
            _buildSearchBar(context),
            Expanded(
              child: Obx(() => Visibility(
                  visible: controller.searchContent.value.isEmpty,
                  // 搜索结果
                  replacement: DefaultTabController(
                    length: 4,
                    child: Column(
                      key: ValueKey(controller.searchContent.value),
                      children: [
                        Expanded(
                          child: Obx(() => TabBarView(
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
                                        await AppController.to.topPanelController.close();
                                        await AppController.to.bottomPanelController.close();
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
                                        await AppController.to.topPanelController.close();
                                        await AppController.to.bottomPanelController.close();
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
                                        await AppController.to.topPanelController.close();
                                        await AppController.to.bottomPanelController.close();
                                      },
                                    ),
                                    itemCount: artists.length,
                                  );
                                },
                              )),
                            ],
                          ))
                        ),
                        Container(
                          height: AppDimensions.appBarHeight,
                          margin: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                          decoration: BoxDecoration(
                              color: context.theme.colorScheme.primary.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppDimensions.appBarHeight / 2)
                          ),
                          // color: Colors.red,
                          child: TabBar(
                            padding: EdgeInsets.zero,
                            labelPadding: EdgeInsets.zero,
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorWeight: 0,
                            indicator: BoxDecoration(
                              color: context.theme.colorScheme.onPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.paddingLarge),
                            ),
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
                        ),
                      ],
                    ),
                  ),
                  // 热门搜索
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                    margin: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall, vertical: AppDimensions.paddingSmall),
                    decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppDimensions.appBarHeight / 2)
                    ),
                    child: RequestWidget<SearchKeyWrapX>(
                      dioMetaData: searchHotKeyDioMetaData(),
                      childBuilder: (data) => Column(
                        children: data.result.hots.map((e) => UniversalListTile(
                            titleString: e.first ?? '',
                          onTap: () {
                              controller.searchTextEditingController.text = e.first ?? '';
                            },
                          )).toList(),
                      )
                    ),
                  ),
                )),
            ),
            // Panel关闭时占位
            Obx(() => Offstage(
                offstage: AppController.to.topPanelFullyClosed.isFalse,
                child: Container(
                  height: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                )
            ))
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
        height: AppDimensions.appBarHeight,
        margin: EdgeInsets.only(top: context.mediaQueryPadding.top, left: AppDimensions.paddingSmall, right: AppDimensions.paddingSmall),
        decoration: BoxDecoration(
            color: context.theme.colorScheme.primary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppDimensions.appBarHeight / 2)
        ),
        child: Row(
          children: [
            IconButton(
              iconSize: AppDimensions.appBarHeight / 2,
              padding: EdgeInsets.all(AppDimensions.appBarHeight / 8),
              // style: IconButton.styleFrom(
              //   backgroundColor: context.theme.colorScheme.onPrimary.withOpacity(0.1),
              // ),
              icon: Icon(
                TablerIcons.search,
              ),
              onPressed: () {
                // controller.searchContent.value = controller.searchTextEditingController.text;
              },
            ).marginAll(AppDimensions.appBarHeight / 8),
            Expanded(
              child: TextField(
                controller: controller.searchTextEditingController,
                cursorColor: Theme.of(context).primaryColor.withOpacity(.4),
                style: context.textTheme.titleMedium,
                decoration: InputDecoration(
                    hintText: '输入歌曲、歌手、歌单...',
                    hintStyle: context.textTheme.titleMedium!.copyWith(
                        color: context.textTheme.titleMedium!.color!.withOpacity(0.2),
                    ),
                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                    isDense: true
                ),
              ),
            ),
            IconButton(
              iconSize: AppDimensions.appBarHeight / 2,
              padding: EdgeInsets.all(AppDimensions.appBarHeight / 8),
              style: IconButton.styleFrom(
                backgroundColor: context.theme.colorScheme.onPrimary.withOpacity(0.1),
              ),
              icon: Icon(
                TablerIcons.x,
              ),
              onPressed: () {
                controller.searchTextEditingController.clear();
              },
            ).marginAll(AppDimensions.appBarHeight / 8)
          ],
        )
    );
  }

  Widget _buildTopPanelCard(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
      // margin: EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.appBarHeight / 2),
        color: context.theme.colorScheme.primary.withOpacity(0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    ).marginAll(AppDimensions.paddingSmall);
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
                      ? Offset(0, -1)   // 旧标题出场（beging和end反转）
                      : Offset(0, 1),  // 新标题入场
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
                      ? Offset(1 , 0)   // 旧标题出场（beging和end反转）
                      : Offset(-1 , 0),  // 新标题入场
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
                      ? Offset(-1 , 0)   // 旧标题出场（beging和end反转）
                      : Offset(1, 0),  // 新标题入场
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
        child: FittedBox(
          key: ValueKey<String>(controller.curPageTitle.value),
          fit: BoxFit.scaleDown,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              //  标题（当前页/歌名）
                text: controller.curPageTitle.value,
                style: context.textTheme.titleLarge?.copyWith(
                    color: controller.curPageTitleColor.value
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
      )),
    );
  }
}