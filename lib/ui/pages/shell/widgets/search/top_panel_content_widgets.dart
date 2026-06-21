import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_search_results.dart';
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_search_widgets.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 顶部搜索面板的主体内容区。
///
/// 搜索词为空时展示热词列表；有搜索词时切换到单曲、歌单、专辑和歌手四个结果页。
class TopPanelContentArea extends StatelessWidget {
  /// 使用搜索、壳层和播放控制器组合顶部搜索面板内容区。
  const TopPanelContentArea({
    super.key,
    required this.shellController,
    required this.searchController,
    required this.playerController,
    required this.onOpenPlaylist,
    required this.onOpenAlbum,
    required this.onOpenArtist,
  });

  /// 壳层控制器，提供搜索输入和热词回填能力。
  final ShellController shellController;

  /// 搜索面板控制器，提供热词和各类搜索结果状态。
  final SearchPanelController searchController;

  /// 播放控制器，用于播放单曲搜索结果队列。
  final PlayerController playerController;

  /// 打开歌单详情。
  final Future<void> Function(BuildContext context, PlaylistEntity playlist) onOpenPlaylist;

  /// 打开专辑详情。
  final Future<void> Function(BuildContext context, AlbumEntity album) onOpenAlbum;

  /// 打开歌手详情。
  final Future<void> Function(BuildContext context, ArtistEntity artist) onOpenArtist;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(
        () => Visibility(
          visible: shellController.searchContent.value.isEmpty,
          replacement: Obx(
            () => _TopPanelResultTabs(
              keyword: shellController.searchContent.value,
              searchController: searchController,
              playerController: playerController,
              onOpenPlaylist: onOpenPlaylist,
              onOpenAlbum: onOpenAlbum,
              onOpenArtist: onOpenArtist,
            ),
          ),
          child: TopPanelCard(
            child: TopPanelHotKeywordList(
              searchController: searchController,
              shellController: shellController,
            ),
          ).marginOnly(top: AppDimensions.paddingSmall),
        ),
      ),
    );
  }
}

class _TopPanelResultTabs extends StatelessWidget {
  const _TopPanelResultTabs({
    required this.keyword,
    required this.searchController,
    required this.playerController,
    required this.onOpenPlaylist,
    required this.onOpenAlbum,
    required this.onOpenArtist,
  });

  final String keyword;
  final SearchPanelController searchController;
  final PlayerController playerController;
  final Future<void> Function(BuildContext context, PlaylistEntity playlist) onOpenPlaylist;
  final Future<void> Function(BuildContext context, AlbumEntity album) onOpenAlbum;
  final Future<void> Function(BuildContext context, ArtistEntity artist) onOpenArtist;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        TopPanelCard(
          child: TopPanelSongSearchResult(
            searchController: searchController,
            keyword: keyword,
            playerController: playerController,
          ),
        ),
        TopPanelCard(
          child: TopPanelPlaylistSearchResult(
            searchController: searchController,
            onOpenPlaylist: onOpenPlaylist,
          ),
        ),
        TopPanelCard(
          child: TopPanelAlbumSearchResult(
            searchController: searchController,
            onOpenAlbum: onOpenAlbum,
          ),
        ),
        TopPanelCard(
          child: TopPanelArtistSearchResult(
            searchController: searchController,
            onOpenArtist: onOpenArtist,
          ),
        ),
      ],
    );
  }
}
