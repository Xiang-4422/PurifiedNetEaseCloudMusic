import 'package:auto_route/auto_route.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_chrome_widgets.dart';
import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_content_widgets.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

/// 顶部搜索面板，展示搜索入口、历史建议和搜索结果。
class TopPanelView extends StatefulWidget {
  /// 创建顶部搜索面板。
  const TopPanelView({
    required this.shellController,
    required this.searchController,
    required this.playerController,
    Key? key,
  }) : super(key: key);

  /// 壳层控制器，提供顶部面板状态和关闭动作。
  final ShellController shellController;

  /// 搜索面板控制器，提供搜索状态和请求生命周期。
  final SearchPanelController searchController;

  /// 播放控制器，用于搜索结果里的播放意图。
  final PlayerController playerController;

  @override
  State<TopPanelView> createState() => _TopPanelViewState();
}

class _TopPanelViewState extends State<TopPanelView> {
  late final Worker _searchWorker;
  late final Worker _panelOpenWorker;

  @override
  void initState() {
    super.initState();
    if (widget.shellController.topPanelFullyClosed.isFalse) {
      widget.searchController.loadInitial();
    }
    _panelOpenWorker = ever<bool>(widget.shellController.topPanelFullyClosed, (closed) {
      if (closed) {
        return;
      }
      widget.searchController.loadInitial();
    });
    _searchWorker = debounce<String>(
      widget.shellController.searchContent,
      _searchCurrentKeyword,
      time: const Duration(milliseconds: 350),
    );
    if (widget.shellController.searchContent.value.trim().isNotEmpty) {
      _searchCurrentKeyword(widget.shellController.searchContent.value);
    }
  }

  @override
  void dispose() {
    widget.searchController.cancelPendingRequests();
    _panelOpenWorker.dispose();
    _searchWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TopPanelBackgroundLayer(controller: widget.shellController),
        DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Container(
                height: context.mediaQueryPadding.top,
              ),
              TopPanelContentArea(
                shellController: widget.shellController,
                searchController: widget.searchController,
                playerController: widget.playerController,
                onOpenPlaylist: _openPlaylist,
                onOpenAlbum: _openAlbum,
                onOpenArtist: _openArtist,
              ),
              TopPanelBottomControls(controller: widget.shellController),
              TopPanelKeyboardSpacer(controller: widget.shellController),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openPlaylist(BuildContext context, PlaylistEntity playlist) async {
    await widget.shellController.closeBottomPanel();
    await widget.shellController.closeTopPanel();
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
    await widget.shellController.closeBottomPanel();
    await widget.shellController.closeTopPanel();
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
    await widget.shellController.closeBottomPanel();
    await widget.shellController.closeTopPanel();
    if (!context.mounted) {
      return;
    }
    context.router.push(
      const gr.ArtistRouteView().copyWith(
        queryParams: {'artistId': artist.sourceId},
      ),
    );
  }

  void _searchCurrentKeyword(String keyword) {
    widget.searchController.search(keyword);
  }
}
