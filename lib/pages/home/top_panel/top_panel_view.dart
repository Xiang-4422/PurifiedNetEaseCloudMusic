import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/features/shell/controller/app_controller.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/request_widget/request_view.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/constants/appConstants.dart';
import '../../../common/netease_api/src/api/search/bean.dart';
import '../../../routes/router.gr.dart' as gr;

class TopPanelView extends GetView<AppController> {
  const TopPanelView({Key? key}) : super(key: key);
  static final SearchRepository _repository = SearchRepository();
  static final PlaylistRepository _playlistRepository = PlaylistRepository();

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
                            () => controller.isOfflineModeEnabled.value
                                ? _buildOfflineSearchHint(context)
                                : RequestWidget<SearchKeyWrapX>(
                                    dioMetaData:
                                        _repository.buildHotKeywordRequest(),
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
                                    ),
                                  ),
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

  Widget _buildSongSearchResult(String keyword) {
    return FutureBuilder<List<MediaItem>>(
      future: _repository.searchTrackMediaItems(
        keyword,
        likedSongIds: controller.likedSongIds.toList(),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return const ErrorView();
        }
        final list = snapshot.data ?? const <MediaItem>[];
        if (list.isEmpty) {
          return const EmptyView();
        }
        return ListView.builder(
          itemBuilder: (context, index) => SongItem(
            index: index,
            playlist: list,
            playListName: "搜索结果：$keyword",
          ),
          itemCount: list.length,
        );
      },
    );
  }

  Widget _buildPlaylistSearchResult(String keyword) {
    return FutureBuilder<List<PlaylistEntity>>(
      future: _repository.searchPlaylists(keyword),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return const ErrorView();
        }
        final playlists = snapshot.data ?? const <PlaylistEntity>[];
        if (playlists.isEmpty) {
          return const EmptyView();
        }
        return ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) => _PlaylistSearchItem(
            playlist: playlists[index],
            onTap: () => _openPlaylist(context, playlists[index]),
          ),
        );
      },
    );
  }

  Widget _buildAlbumSearchResult(String keyword) {
    return FutureBuilder<List<AlbumEntity>>(
      future: _repository.searchAlbums(keyword),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return const ErrorView();
        }
        final albums = snapshot.data ?? const <AlbumEntity>[];
        if (albums.isEmpty) {
          return const EmptyView();
        }
        return ListView.builder(
          itemCount: albums.length,
          itemBuilder: (context, index) => _AlbumSearchItem(
            album: albums[index],
            onTap: () => _openAlbum(context, albums[index]),
          ),
        );
      },
    );
  }

  Widget _buildArtistSearchResult(String keyword) {
    return FutureBuilder<List<ArtistEntity>>(
      future: _repository.searchArtists(keyword),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return const ErrorView();
        }
        final artists = snapshot.data ?? const <ArtistEntity>[];
        if (artists.isEmpty) {
          return const EmptyView();
        }
        return ListView.builder(
          itemCount: artists.length,
          itemBuilder: (context, index) => _ArtistSearchItem(
            artist: artists[index],
            onTap: () => _openArtist(context, artists[index]),
          ),
        );
      },
    );
  }

  Future<void> _openPlaylist(
      BuildContext context, PlaylistEntity playlist) async {
    AppController.to.bottomPanelController.close();
    await AppController.to.topPanelController.close();
    final detail =
        await _playlistRepository.fetchPlaylistWrap(playlist.sourceId);
    final playList = detail.playlist;
    if (playList == null || !context.mounted) {
      return;
    }
    context.router.push(gr.PlayListRouteView(playList: playList));
  }

  Future<void> _openAlbum(BuildContext context, AlbumEntity album) async {
    AppController.to.bottomPanelController.close();
    await AppController.to.topPanelController.close();
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
    AppController.to.bottomPanelController.close();
    await AppController.to.topPanelController.close();
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
