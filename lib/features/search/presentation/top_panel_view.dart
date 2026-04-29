import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/load_state_view.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

class TopPanelView extends StatefulWidget {
  const TopPanelView({Key? key}) : super(key: key);
  static final SearchPanelController _searchPanelController =
      Get.find<FeatureControllerFactory>().searchPanel();

  @override
  State<TopPanelView> createState() => _TopPanelViewState();
}

class _TopPanelViewState extends State<TopPanelView> {
  late final Worker _searchWorker;
  late final Worker _panelOpenWorker;

  ShellController get controller => ShellController.to;

  @override
  void initState() {
    super.initState();
    if (!SettingsController.to.isOfflineModeEnabled.value &&
        controller.topPanelFullyClosed.isFalse) {
      TopPanelView._searchPanelController.loadInitial();
    }
    _panelOpenWorker = ever<bool>(controller.topPanelFullyClosed, (closed) {
      if (closed || SettingsController.to.isOfflineModeEnabled.value) {
        return;
      }
      TopPanelView._searchPanelController.loadInitial();
    });
    _searchWorker = ever<String>(controller.searchContent, (keyword) {
      TopPanelView._searchPanelController.search(
        keyword,
        likedSongIds: UserLibraryController.to.likedSongIds.toList(),
        currentUserId: UserSessionController.to.userInfo.value.userId,
      );
    });
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
                  blur:
                      15 * ShellController.to.topPanelAnimationController.value,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.zero,
                  color: context.theme.colorScheme.primary.withValues(
                      alpha:
                          ShellController.to.topPanelAnimationController.value),
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
                                _buildSongSearchResult(
                                  controller.searchContent.value,
                                ),
                              ),
                              _buildTopPanelCard(
                                context,
                                _buildPlaylistSearchResult(
                                  controller.searchContent.value,
                                ),
                              ),
                              _buildTopPanelCard(
                                context,
                                _buildAlbumSearchResult(
                                  controller.searchContent.value,
                                ),
                              ),
                              _buildTopPanelCard(
                                context,
                                _buildArtistSearchResult(
                                  controller.searchContent.value,
                                ),
                              ),
                            ],
                          )),
                      child: _buildTopPanelCard(
                          context,
                          Obx(
                            () =>
                                SettingsController.to.isOfflineModeEnabled.value
                                    ? _buildOfflineSearchHint(context)
                                    : _buildHotKeywordList(),
                          )).marginOnly(top: AppDimensions.paddingSmall),
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
                    height: ShellController.to.topPanelFullyClosed.isTrue
                        ? AppDimensions.appBarHeight +
                            context.mediaQueryPadding.top
                        : ShellController.to.keyBoardHeight.value,
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
                      controller.closeTopPanel();
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

  Widget _buildOfflineSearchHint(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UniversalListTile(
          titleString: '离线模式已开启',
          subTitleString: '当前仅搜索本地已经存在的歌曲、歌单、专辑和歌手',
          onTap: () {},
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
              onPlay: PlayerController.to.playPlaylist,
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
            itemBuilder: (context, index) => _PlaylistSearchItem(
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
            itemBuilder: (context, index) => _AlbumSearchItem(
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
            itemBuilder: (context, index) => _ArtistSearchItem(
              artist: artists[index],
              onTap: () => _openArtist(context, artists[index]),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openPlaylist(
      BuildContext context, PlaylistEntity playlist) async {
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

class _PlaylistSearchItem extends StatelessWidget {
  const _PlaylistSearchItem({
    required this.playlist,
    required this.onTap,
  });

  final PlaylistEntity playlist;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return UniversalListTile(
      picUrl: playlist.coverUrl,
      titleString: playlist.title,
      subTitleString:
          playlist.trackCount == null ? null : '${playlist.trackCount}首',
      onTap: onTap,
    );
  }
}

class _AlbumSearchItem extends StatelessWidget {
  const _AlbumSearchItem({
    required this.album,
    required this.onTap,
  });

  final AlbumEntity album;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return UniversalListTile(
      picUrl: album.artworkUrl ?? '',
      titleString: album.title,
      subTitleString: album.trackCount == null ? null : '${album.trackCount} 首',
      onTap: onTap,
    );
  }
}

class _ArtistSearchItem extends StatelessWidget {
  const _ArtistSearchItem({
    required this.artist,
    required this.onTap,
  });

  final ArtistEntity artist;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return UniversalListTile(
      picUrl: artist.artworkUrl ?? '',
      titleString: artist.name,
      subTitleString: artist.description,
      onTap: onTap,
    );
  }
}
