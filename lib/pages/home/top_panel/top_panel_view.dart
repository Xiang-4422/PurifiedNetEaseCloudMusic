import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/features/search/repository/search_repository.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:bujuan/widget/request_widget/request_view.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/constants/appConstants.dart';
import '../../../common/netease_api/src/api/play/bean.dart';
import '../../../common/netease_api/src/api/search/bean.dart';
import '../../../widget/request_widget/request_loadmore_view.dart';
import '../../play_list/playlist_page_view.dart';

class TopPanelView extends GetView<AppController> {
  const TopPanelView({Key? key}) : super(key: key);
  static final SearchRepository _repository = SearchRepository();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: AppController.to.topPanelAnimationController,
          builder: (BuildContext context, Widget? child) {
            return Stack(
              children: [
                BlurryContainer(
                  blur: 15 * AppController.to.topPanelAnimationController.value,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.zero,
                  color: context.theme.colorScheme.primary.withValues(
                      alpha:
                          AppController.to.topPanelAnimationController.value),
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
                child: Obx(() => Visibility(
                      visible: controller.searchContent.value.isEmpty,
                      replacement: Obx(() => TabBarView(
                            children: [
                              _buildTopPanelCard(
                                context,
                                RequestLoadMoreWidget<SearchSongWrapX, Song2>(
                                  dioMetaData: _repository.buildSearchRequest(
                                      controller.searchContent.value, 1),
                                  childBuilder: (List<Song2> songs) {
                                    final list = MediaItemMapper.fromSong2List(
                                      songs,
                                      likedSongIds:
                                          controller.likedSongIds.toList(),
                                    );
                                    return ListView.builder(
                                      itemBuilder: (context, index) => SongItem(
                                        index: index,
                                        playlist: list,
                                        playListName:
                                            "搜索结果：${controller.searchContent.value}",
                                      ),
                                      itemCount: list.length,
                                    );
                                  },
                                  listKey: const ['result', 'songs'],
                                ),
                              ),
                              _buildTopPanelCard(
                                  context,
                                  RequestLoadMoreWidget<SearchPlaylistWrapX,
                                      PlayList>(
                                    dioMetaData: _repository.buildSearchRequest(
                                        controller.searchContent.value, 1000),
                                    listKey: const ['result', 'playlists'],
                                    childBuilder: (List<PlayList> playlist) {
                                      return ListView.builder(
                                        itemCount: playlist.length,
                                        itemBuilder: (context, index) =>
                                            PlayListItem(
                                          playlist[index],
                                          beforeOnTap: () async {
                                            AppController
                                                .to.bottomPanelController
                                                .close();
                                            await AppController
                                                .to.topPanelController
                                                .close();
                                          },
                                        ),
                                      );
                                    },
                                  )),
                              _buildTopPanelCard(
                                  context,
                                  RequestLoadMoreWidget<SearchAlbumsWrapX,
                                      Album>(
                                    dioMetaData: _repository.buildSearchRequest(
                                        controller.searchContent.value, 10),
                                    childBuilder: (List<Album> albums) {
                                      return ListView.builder(
                                        itemBuilder: (context, index) =>
                                            AlbumItem(
                                          album: albums[index],
                                          beforeOnTap: () async {
                                            AppController
                                                .to.bottomPanelController
                                                .close();
                                            await AppController
                                                .to.topPanelController
                                                .close();
                                          },
                                        ),
                                        itemCount: albums.length,
                                      );
                                    },
                                    listKey: const ['result', 'albums'],
                                  )),
                              _buildTopPanelCard(
                                  context,
                                  RequestLoadMoreWidget<SearchArtistsWrapX,
                                      Artist>(
                                    dioMetaData: _repository.buildSearchRequest(
                                        controller.searchContent.value, 100),
                                    listKey: const ['result', 'artists'],
                                    childBuilder: (List<Artist> artists) {
                                      return ListView.builder(
                                        itemBuilder: (context, index) =>
                                            ArtistsItem(
                                          artist: artists[index],
                                          beforeOnTap: () async {
                                            AppController
                                                .to.bottomPanelController
                                                .close();
                                            await AppController
                                                .to.topPanelController
                                                .close();
                                          },
                                        ),
                                        itemCount: artists.length,
                                      );
                                    },
                                  )),
                            ],
                          )),
                      child: _buildTopPanelCard(
                          context,
                          RequestWidget<SearchKeyWrapX>(
                              dioMetaData: _repository.buildHotKeywordRequest(),
                              childBuilder: (data) => ListView(
                                    padding: EdgeInsets.zero,
                                    children: data.result.hots
                                        .map((e) => UniversalListTile(
                                              titleString: e.first ?? '',
                                              onTap: () {
                                                controller.searchFocusNode
                                                    .unfocus();
                                                controller
                                                    .searchTextEditingController
                                                    .text = e.first ?? '';
                                              },
                                            ))
                                        .toList(),
                                  ))).marginOnly(
                          top: AppDimensions.paddingSmall),
                    )),
              ),
              Container(
                color:
                    context.theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Obx(() => Offstage(
                          offstage: controller.searchContent.value.isEmpty,
                          child: MyTabBar(
                            height: AppDimensions.appBarHeight / 3,
                            tabs: [
                              Text(
                                "单曲",
                                style: context.textTheme.titleMedium?.copyWith(
                                    color: context.theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.5)),
                              ),
                              Text(
                                "歌单",
                                style: context.textTheme.titleMedium?.copyWith(
                                    color: context.theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.5)),
                              ),
                              Text(
                                "专辑",
                                style: context.textTheme.titleMedium?.copyWith(
                                    color: context.theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.5)),
                              ),
                              Text(
                                "歌手",
                                style: context.textTheme.titleMedium?.copyWith(
                                    color: context.theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        )),
                    _buildSearchBar(
                        context, AppDimensions.appBarHeight * 2 / 3),
                  ],
                ),
              ),
              Obx(() => Container(
                    height: AppController.to.topPanelFullyClosed.isTrue
                        ? AppDimensions.appBarHeight +
                            context.mediaQueryPadding.top
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
              icon: const Icon(
                TablerIcons.search,
              ),
              onPressed: () {},
            ).marginAll(iconPadding),
            Expanded(
              child: TextField(
                controller: controller.searchTextEditingController,
                focusNode: controller.searchFocusNode,
                cursorColor:
                    Theme.of(context).primaryColor.withValues(alpha: .4),
                style: context.textTheme.titleMedium,
                decoration: InputDecoration(
                    hintText: '输入歌曲、歌手、歌单...',
                    hintStyle: context.textTheme.titleMedium!.copyWith(
                      color: context.textTheme.titleMedium!.color!
                          .withValues(alpha: 0.2),
                    ),
                    border:
                        const UnderlineInputBorder(borderSide: BorderSide.none),
                    isDense: true),
              ),
            ),
            Obx(() => Visibility(
                  visible: controller.searchContent.isNotEmpty,
                  replacement: IconButton(
                    iconSize: iconSize,
                    padding: EdgeInsets.all(iconPadding),
                    style: IconButton.styleFrom(
                      backgroundColor: context.theme.colorScheme.onPrimary
                          .withValues(alpha: 0.1),
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
                      backgroundColor: context.theme.colorScheme.onPrimary
                          .withValues(alpha: 0.1),
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
        ));
  }

  Widget _buildTopPanelCard(BuildContext context, Widget child) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
      child: child,
    );
  }
}
