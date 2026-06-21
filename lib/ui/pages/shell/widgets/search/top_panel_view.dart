import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_search_widgets.dart';
import 'package:bujuan/ui/widgets/common/feedback/load_state_view.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
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
                                child: _buildSongSearchResult(
                                  controller.searchContent.value,
                                ),
                              ),
                              TopPanelCard(
                                child: _buildPlaylistSearchResult(
                                  controller.searchContent.value,
                                ),
                              ),
                              TopPanelCard(
                                child: _buildAlbumSearchResult(
                                  controller.searchContent.value,
                                ),
                              ),
                              TopPanelCard(
                                child: _buildArtistSearchResult(
                                  controller.searchContent.value,
                                ),
                              ),
                            ],
                          )),
                      child: TopPanelCard(
                        child: _buildHotKeywordList(),
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

  Widget _buildHotKeywordList() {
    return ValueListenableBuilder(
      valueListenable: TopPanelView._searchPanelController.hotKeywordState,
      builder: (context, state, child) {
        return LoadStateView<List<String>>(
          state: state,
          builder: (keywords) => ListView(
            padding: EdgeInsets.zero,
            children: keywords
                .map(
                  (keyword) => UniversalListTile(
                    titleString: keyword,
                    onTap: () {
                      controller.searchFocusNode.unfocus();
                      controller.searchTextEditingController.text = keyword;
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildSongSearchResult(String keyword) {
    return ValueListenableBuilder(
      valueListenable: TopPanelView._searchPanelController.songState,
      builder: (context, state, child) {
        return LoadStateView<List<PlaybackQueueItem>>(
          state: state,
          builder: (list) => ListView.builder(
            itemBuilder: (context, index) => SongItem(
              index: index,
              playlist: list,
              playListName: "搜索结果：$keyword",
              onPlay: _playerController.playPlaylist,
            ),
            itemCount: list.length,
          ),
        );
      },
    );
  }

  Widget _buildPlaylistSearchResult(String keyword) {
    return ValueListenableBuilder(
      valueListenable: TopPanelView._searchPanelController.playlistState,
      builder: (context, state, child) {
        return LoadStateView<List<PlaylistEntity>>(
          state: state,
          builder: (playlists) => ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) => PlaylistSearchItem(
              playlist: playlists[index],
              onTap: () => _openPlaylist(context, playlists[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumSearchResult(String keyword) {
    return ValueListenableBuilder(
      valueListenable: TopPanelView._searchPanelController.albumState,
      builder: (context, state, child) {
        return LoadStateView<List<AlbumEntity>>(
          state: state,
          builder: (albums) => ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) => AlbumSearchItem(
              album: albums[index],
              onTap: () => _openAlbum(context, albums[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtistSearchResult(String keyword) {
    return ValueListenableBuilder(
      valueListenable: TopPanelView._searchPanelController.artistState,
      builder: (context, state, child) {
        return LoadStateView<List<ArtistEntity>>(
          state: state,
          builder: (artists) => ListView.builder(
            itemCount: artists.length,
            itemBuilder: (context, index) => ArtistSearchItem(
              artist: artists[index],
              onTap: () => _openArtist(context, artists[index]),
            ),
          ),
        );
      },
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
