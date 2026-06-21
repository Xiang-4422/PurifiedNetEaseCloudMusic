import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_search_results.dart';
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_search_widgets.dart';
import 'package:bujuan/ui/widgets/common/layout/my_tab_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

/// 顶部搜索面板，展示搜索入口、历史建议和搜索结果。
class TopPanelView extends StatefulWidget {
  /// 创建顶部搜索面板。
  const TopPanelView({Key? key}) : super(key: key);

  /// 搜索面板控制器，随顶部面板生命周期复用。
  static final SearchPanelController _searchPanelController = Get.find<SearchPanelController>();

  @override
  State<TopPanelView> createState() => _TopPanelViewState();
}

class _TopPanelViewState extends State<TopPanelView> {
  late final Worker _searchWorker;
  late final Worker _panelOpenWorker;
  final PlayerController _playerController = Get.find<PlayerController>();

  ShellController get controller => ShellController.to;

  @override
  void initState() {
    super.initState();
    if (controller.topPanelFullyClosed.isFalse) {
      TopPanelView._searchPanelController.loadInitial();
    }
    _panelOpenWorker = ever<bool>(controller.topPanelFullyClosed, (closed) {
      if (closed) {
        return;
      }
      TopPanelView._searchPanelController.loadInitial();
    });
    _searchWorker = debounce<String>(
      controller.searchContent,
      (keyword) {
        TopPanelView._searchPanelController.search(
          keyword,
          likedSongIds: UserLibraryController.to.likedSongIds.toList(),
          currentUserId: UserSessionController.to.userInfo.value.userId,
        );
      },
      time: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _panelOpenWorker.dispose();
    _searchWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: ShellController.to.topPanelAnimationController,
          builder: (BuildContext context, Widget? child) {
            return Stack(
              children: [
                BlurryContainer(
                  blur: 15 * ShellController.to.topPanelAnimationController.value,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.zero,
                  color: context.theme.colorScheme.primary.withValues(alpha: ShellController.to.topPanelAnimationController.value),
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
                              TopPanelCard(
                                child: TopPanelSongSearchResult(
                                  searchController: TopPanelView._searchPanelController,
                                  keyword: controller.searchContent.value,
                                  playerController: _playerController,
                                ),
                              ),
                              TopPanelCard(
                                child: TopPanelPlaylistSearchResult(
                                  searchController: TopPanelView._searchPanelController,
                                  onOpenPlaylist: _openPlaylist,
                                ),
                              ),
                              TopPanelCard(
                                child: TopPanelAlbumSearchResult(
                                  searchController: TopPanelView._searchPanelController,
                                  onOpenAlbum: _openAlbum,
                                ),
                              ),
                              TopPanelCard(
                                child: TopPanelArtistSearchResult(
                                  searchController: TopPanelView._searchPanelController,
                                  onOpenArtist: _openArtist,
                                ),
                              ),
                            ],
                          )),
                      child: TopPanelCard(
                        child: TopPanelHotKeywordList(
                          searchController: TopPanelView._searchPanelController,
                          shellController: controller,
                        ),
                      ).marginOnly(top: AppDimensions.paddingSmall),
                    )),
              ),
              Container(
                color: context.theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Obx(() => Offstage(
                          offstage: controller.searchContent.value.isEmpty,
                          child: MyTabBar(
                            height: AppDimensions.appBarHeight / 3,
                            tabs: [
                              Text(
                                "单曲",
                                style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onPrimary.withValues(alpha: 0.5)),
                              ),
                              Text(
                                "歌单",
                                style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onPrimary.withValues(alpha: 0.5)),
                              ),
                              Text(
                                "专辑",
                                style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onPrimary.withValues(alpha: 0.5)),
                              ),
                              Text(
                                "歌手",
                                style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onPrimary.withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        )),
                    TopPanelSearchBar(
                      controller: controller,
                      height: AppDimensions.appBarHeight * 2 / 3,
                    ),
                  ],
                ),
              ),
              Obx(() => Container(
                    height: ShellController.to.topPanelFullyClosed.isTrue ? AppDimensions.appBarHeight + context.mediaQueryPadding.top : ShellController.to.keyBoardHeight.value,
                  ))
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openPlaylist(BuildContext context, PlaylistEntity playlist) async {
    await ShellController.to.closeBottomPanel();
    await ShellController.to.closeTopPanel();
    if (!context.mounted) {
      return;
    }
    context.router.push(
      gr.PlayListRouteView(
        playlistId: playlist.sourceId,
        playlistName: playlist.title,
        coverUrl: playlist.coverUrl,
        trackCount: playlist.trackCount,
      ),
    );
  }

  Future<void> _openAlbum(BuildContext context, AlbumEntity album) async {
    await ShellController.to.closeBottomPanel();
    await ShellController.to.closeTopPanel();
    if (!context.mounted) {
      return;
    }
    context.router.push(
      const gr.AlbumRouteView().copyWith(
        queryParams: {'albumId': album.sourceId},
      ),
    );
  }

  Future<void> _openArtist(BuildContext context, ArtistEntity artist) async {
    await ShellController.to.closeBottomPanel();
    await ShellController.to.closeTopPanel();
    if (!context.mounted) {
      return;
    }
    context.router.push(
      const gr.ArtistRouteView().copyWith(
        queryParams: {'artistId': artist.sourceId},
      ),
    );
  }
}
