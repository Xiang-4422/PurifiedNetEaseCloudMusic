import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_search_widgets.dart';
import 'package:bujuan/ui/widgets/common/feedback/load_state_view.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:flutter/material.dart';

const double _topPanelSearchCacheExtent = 320;

/// 顶部搜索面板热词列表。
class TopPanelHotKeywordList extends StatelessWidget {
  /// 创建热词列表。
  const TopPanelHotKeywordList({
    super.key,
    required this.searchController,
    required this.shellController,
  });

  /// 搜索面板控制器。
  final SearchPanelController searchController;

  /// 壳层控制器，负责把热词写回搜索框。
  final ShellController shellController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchController.hotKeywordState,
      builder: (context, state, child) {
        return LoadStateView<List<String>>(
          state: state,
          onRetry: () => searchController.loadInitial(force: true),
          builder: (keywords) => ListView.builder(
            cacheExtent: _topPanelSearchCacheExtent,
            prototypeItem: const UniversalListTile(
              titleString: '搜索热词',
            ),
            itemCount: keywords.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final keyword = keywords[index];
              return UniversalListTile(
                titleString: keyword,
                onTap: () {
                  shellController.searchFocusNode.unfocus();
                  shellController.searchTextEditingController.text = keyword;
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// 顶部搜索面板单曲结果列表。
class TopPanelSongSearchResult extends StatelessWidget {
  /// 创建单曲搜索结果列表。
  const TopPanelSongSearchResult({
    super.key,
    required this.searchController,
    required this.keyword,
    required this.playerController,
  });

  /// 搜索面板控制器。
  final SearchPanelController searchController;

  /// 当前搜索词。
  final String keyword;

  /// 播放控制器，负责播放搜索结果队列。
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchController.songState,
      builder: (context, state, child) {
        return LoadStateView<List<PlaybackQueueItem>>(
          state: state,
          onRetry: searchController.retryCurrentSearch,
          builder: (list) => ListView.builder(
            cacheExtent: _topPanelSearchCacheExtent,
            prototypeItem: const SongItem(
              item: PlaybackQueueItem.empty(),
              index: 0,
              playListName: '搜索结果',
            ),
            itemBuilder: (context, index) => SongItem(
              index: index,
              playlist: list,
              playListName: '搜索结果：$keyword',
              onPlay: playerController.playPlaylist,
            ),
            itemCount: list.length,
          ),
        );
      },
    );
  }
}

/// 顶部搜索面板歌单结果列表。
class TopPanelPlaylistSearchResult extends StatelessWidget {
  /// 创建歌单搜索结果列表。
  const TopPanelPlaylistSearchResult({
    super.key,
    required this.searchController,
    required this.onOpenPlaylist,
  });

  /// 搜索面板控制器。
  final SearchPanelController searchController;

  /// 打开歌单详情。
  final Future<void> Function(BuildContext context, PlaylistEntity playlist) onOpenPlaylist;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchController.playlistState,
      builder: (context, state, child) {
        return LoadStateView<List<PlaylistEntity>>(
          state: state,
          onRetry: searchController.retryCurrentSearch,
          builder: (playlists) => ListView.builder(
            cacheExtent: _topPanelSearchCacheExtent,
            prototypeItem: const UniversalListTile(
              picUrl: '',
              titleString: '搜索歌单',
              subTitleString: '0首',
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) => PlaylistSearchItem(
              playlist: playlists[index],
              onTap: () => onOpenPlaylist(context, playlists[index]),
            ),
          ),
        );
      },
    );
  }
}

/// 顶部搜索面板专辑结果列表。
class TopPanelAlbumSearchResult extends StatelessWidget {
  /// 创建专辑搜索结果列表。
  const TopPanelAlbumSearchResult({
    super.key,
    required this.searchController,
    required this.onOpenAlbum,
  });

  /// 搜索面板控制器。
  final SearchPanelController searchController;

  /// 打开专辑详情。
  final Future<void> Function(BuildContext context, AlbumEntity album) onOpenAlbum;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchController.albumState,
      builder: (context, state, child) {
        return LoadStateView<List<AlbumEntity>>(
          state: state,
          onRetry: searchController.retryCurrentSearch,
          builder: (albums) => ListView.builder(
            cacheExtent: _topPanelSearchCacheExtent,
            prototypeItem: const UniversalListTile(
              picUrl: '',
              titleString: '搜索专辑',
              subTitleString: '0 首',
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) => AlbumSearchItem(
              album: albums[index],
              onTap: () => onOpenAlbum(context, albums[index]),
            ),
          ),
        );
      },
    );
  }
}

/// 顶部搜索面板歌手结果列表。
class TopPanelArtistSearchResult extends StatelessWidget {
  /// 创建歌手搜索结果列表。
  const TopPanelArtistSearchResult({
    super.key,
    required this.searchController,
    required this.onOpenArtist,
  });

  /// 搜索面板控制器。
  final SearchPanelController searchController;

  /// 打开歌手详情。
  final Future<void> Function(BuildContext context, ArtistEntity artist) onOpenArtist;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchController.artistState,
      builder: (context, state, child) {
        return LoadStateView<List<ArtistEntity>>(
          state: state,
          onRetry: searchController.retryCurrentSearch,
          builder: (artists) => ListView.builder(
            cacheExtent: _topPanelSearchCacheExtent,
            prototypeItem: const UniversalListTile(
              picUrl: '',
              titleString: '搜索歌手',
              subTitleString: '歌手简介',
            ),
            itemCount: artists.length,
            itemBuilder: (context, index) => ArtistSearchItem(
              artist: artists[index],
              onTap: () => onOpenArtist(context, artists[index]),
            ),
          ),
        );
      },
    );
  }
}
