import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

/// 顶部搜索面板内容区的水平边距容器。
class TopPanelContentPadding extends StatelessWidget {
  /// 创建搜索面板内容边距容器。
  const TopPanelContentPadding({
    super.key,
    required this.child,
  });

  /// 内容区子组件。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
      ),
      child: child,
    );
  }
}

/// 顶部搜索面板底部的搜索输入栏。
class TopPanelSearchBar extends StatelessWidget {
  /// 创建搜索输入栏。
  const TopPanelSearchBar({
    super.key,
    required this.controller,
    required this.height,
  });

  /// 壳层控制器，持有搜索输入和顶部面板状态。
  final ShellController controller;

  /// 搜索栏高度。
  final double height;

  @override
  Widget build(BuildContext context) {
    final iconSize = height / 2;
    final iconPadding = height / 8;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          SizedBox.square(
            dimension: height,
            child: Center(
              child: Icon(
                TablerIcons.search,
                size: iconSize,
              ),
            ),
          ).marginAll(iconPadding),
          Expanded(
            child: TextField(
              controller: controller.searchTextEditingController,
              focusNode: controller.searchFocusNode,
              cursorColor: Theme.of(context).primaryColor.withValues(alpha: .4),
              style: context.textTheme.titleMedium,
              decoration: InputDecoration(
                hintText: '输入歌曲、歌手、歌单...',
                hintStyle: context.textTheme.titleMedium!.copyWith(
                  color: context.textTheme.titleMedium!.color!.withValues(
                    alpha: 0.2,
                  ),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.searchContent.isNotEmpty,
              replacement: IconButton(
                tooltip: topPanelSearchActionLabel(hasKeyword: false),
                iconSize: iconSize,
                padding: EdgeInsets.all(iconPadding),
                style: IconButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                ),
                icon: const Icon(TablerIcons.arrow_up),
                onPressed: () {
                  controller.closeTopPanel();
                },
              ).marginAll(iconPadding),
              child: IconButton(
                tooltip: topPanelSearchActionLabel(hasKeyword: true),
                iconSize: iconSize,
                padding: EdgeInsets.all(iconPadding),
                style: IconButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                ),
                icon: const Icon(TablerIcons.x),
                onPressed: () {
                  controller.searchTextEditingController.clear();
                  controller.searchFocusNode.requestFocus();
                },
              ).marginAll(iconPadding),
            ),
          ),
        ],
      ),
    );
  }
}

/// 生成顶部搜索栏尾部按钮的辅助语义标签。
@visibleForTesting
String topPanelSearchActionLabel({required bool hasKeyword}) {
  return hasKeyword ? '清空搜索' : '关闭搜索';
}

/// 搜索结果中的歌单条目。
class PlaylistSearchItem extends StatelessWidget {
  /// 创建歌单搜索结果条目。
  const PlaylistSearchItem({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  /// 歌单实体。
  final PlaylistEntity playlist;

  /// 点击条目时触发。
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return UniversalListTile(
      picUrl: playlist.coverUrl,
      titleString: playlist.title,
      subTitleString: playlist.trackCount == null ? null : '${playlist.trackCount}首',
      onTap: onTap,
    );
  }
}

/// 搜索结果中的专辑条目。
class AlbumSearchItem extends StatelessWidget {
  /// 创建专辑搜索结果条目。
  const AlbumSearchItem({
    super.key,
    required this.album,
    required this.onTap,
  });

  /// 专辑实体。
  final AlbumEntity album;

  /// 点击条目时触发。
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

/// 搜索结果中的歌手条目。
class ArtistSearchItem extends StatelessWidget {
  /// 创建歌手搜索结果条目。
  const ArtistSearchItem({
    super.key,
    required this.artist,
    required this.onTap,
  });

  /// 歌手实体。
  final ArtistEntity artist;

  /// 点击条目时触发。
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
