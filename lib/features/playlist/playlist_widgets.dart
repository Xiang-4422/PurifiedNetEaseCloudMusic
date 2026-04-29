import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/keep_alive_wrapper.dart';
import 'package:bujuan/widget/scroll_helpers.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

/// 这批组件都围绕歌单、歌曲列表和播放入口组织，放回 playlist feature 比继续挂在页面文件或 common 更清晰。
class Header extends StatelessWidget {
  /// title。
  final String title;

  /// padding。
  final double padding;

  /// 创建 Header。
  const Header(this.title, {Key? key, this.padding = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.headerHeight,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(padding),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

/// 统一歌曲、歌单、专辑、歌手搜索结果的行结构，避免页面为了一个 list item 再各自复制样式。
class UniversalListTile extends StatelessWidget {
  /// titleString。
  final String titleString;

  /// subTitleString。
  final String? subTitleString;

  /// picUrl。
  final String? picUrl;

  /// onTap。
  final GestureTapCallback? onTap;

  /// onLongPress。
  final GestureTapCallback? onLongPress;

  /// stringColor。
  final Color? stringColor;

  /// trailing。
  final Widget? trailing;

  /// 创建 UniversalListTile。
  const UniversalListTile({
    super.key,
    required this.titleString,
    this.subTitleString,
    this.picUrl,
    this.stringColor,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final localPicPath = ArtworkPathResolver.resolveDisplayPath(picUrl);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            if (localPicPath.isNotEmpty)
              SimpleExtendedImage(
                localPicPath,
                width: 44,
                height: 44,
                cacheWidth: 120,
                borderRadius: BorderRadius.circular(8),
              ),
            if (localPicPath.isNotEmpty)
              const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleString,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: stringColor ??
                              context.theme.colorScheme.onPrimary,
                        ),
                  ),
                  if (subTitleString != null)
                    Text(
                      subTitleString!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: (stringColor ??
                                    context.theme.colorScheme.onPrimary)
                                .withValues(alpha: 0.5),
                          ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// `SongItem` 统一承接“点击即按当前上下文播放”的行为，避免每个页面再手写一次播放入口。
class SongItem extends StatefulWidget {
  /// index。
  final int index;

  /// playlist。
  final List<PlaybackQueueItem> playlist;

  /// playListName。
  final String playListName;

  /// playListHeader。
  final String playListHeader;

  /// 创建 Function。
  final Function()? beforeOnTap;

  /// 播放回调。
  final Future<void> Function(
    List<PlaybackQueueItem> playlist,
    int index, {
    String playListName,
    String playListNameHeader,
  })? onPlay;

  /// stringColor。
  final Color? stringColor;

  /// showPic。
  final bool showPic;

  /// showIndex。
  final bool showIndex;

  /// 创建 SongItem。
  const SongItem({
    Key? key,
    this.beforeOnTap,
    this.onPlay,
    this.stringColor,
    this.showPic = true,
    this.showIndex = false,
    this.playListHeader = "",
    required this.playlist,
    required this.index,
    required this.playListName,
  }) : super(key: key);

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  @override
  Widget build(BuildContext context) {
    final item = widget.playlist[widget.index];
    return UniversalListTile(
      picUrl: widget.showPic ? item.artworkUrl : null,
      titleString: item.title,
      subTitleString: item.artist,
      stringColor: widget.stringColor,
      onTap: () async {
        if (widget.beforeOnTap != null) {
          await widget.beforeOnTap!();
        }
        await widget.onPlay?.call(
          widget.playlist,
          widget.index,
          playListName: widget.playListName,
          playListNameHeader: widget.playListHeader,
        );
      },
    );
  }
}

/// PlayListItem。
class PlayListItem extends StatelessWidget {
  /// play。
  final PlaylistSummaryData play;

  /// 创建 Function。
  final Function()? beforeOnTap;

  /// 创建 PlayListItem。
  const PlayListItem(this.play, {Key? key, this.beforeOnTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = context.router;
    return UniversalListTile(
      picUrl: play.coverUrl,
      titleString: play.title,
      subTitleString: play.trackCount == null || play.trackCount == 0
          ? null
          : "${play.trackCount}首",
      onTap: () async {
        if (beforeOnTap != null) {
          await beforeOnTap!();
        }
        router.push(
          gr.PlayListRouteView(
            playlistId: play.id,
            playlistName: play.title,
            coverUrl: play.coverUrl,
            trackCount: play.trackCount,
          ),
        );
      },
    );
  }
}

/// 歌单卡片既负责展示，也负责触发“播放整个歌单”，因此归在 playlist feature 比挂在 common 更合适。
class PlayListWidget extends StatelessWidget {
  /// albumCountInWidget。
  final double albumCountInWidget;

  /// albumMargin。
  final double albumMargin;

  /// playLists。
  final List<PlaylistSummaryData> playLists;

  /// showSongCount。
  final bool showSongCount;

  /// snappAllAlbum。
  final bool snappAllAlbum;

  /// noScroll。
  final bool noScroll;

  /// isPlaying。
  final bool isPlaying;

  /// playingPlaylistName。
  final String? playingPlaylistName;

  /// Function。
  final Future<void> Function(PlaylistSummaryData playlist)? onPlayPlaylist;

  /// 创建 PlayListWidget。
  const PlayListWidget({
    Key? key,
    required this.playLists,
    this.albumCountInWidget = 2.5,
    this.albumMargin = 0,
    this.showSongCount = true,
    this.snappAllAlbum = false,
    this.noScroll = false,
    this.isPlaying = false,
    this.playingPlaylistName,
    this.onPlayPlaylist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final maxWidth = constraints.maxWidth;
        final albumWidth = noScroll
            ? (maxWidth - albumMargin * (playLists.length + 1)) /
                playLists.length
            : (maxWidth - albumMargin * albumCountInWidget.ceil()) /
                albumCountInWidget;

        return SizedBox(
          height: albumWidth * 1.3,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            physics: SnappingScrollPhysics(
              itemExtent: (albumWidth + albumMargin) *
                  (snappAllAlbum ? albumCountInWidget.floor() : 1),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(left: albumMargin),
                sliver: SliverList.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: playLists.length,
                  itemBuilder: (context, index) {
                    return KeepAliveWrapper(
                      child: Container(
                        width: albumWidth,
                        margin: EdgeInsets.only(right: albumMargin),
                        child: GestureDetector(
                          onTap: () {
                            context.router.push(
                              gr.PlayListRouteView(
                                playlistId: playLists[index].id,
                                playlistName: playLists[index].title,
                                coverUrl: playLists[index].coverUrl,
                                trackCount: playLists[index].trackCount,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  SimpleExtendedImage.avatar(
                                    width: albumWidth,
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.circular(albumMargin),
                                    ArtworkPathResolver.resolveDisplayPath(
                                      playLists[index].coverUrl,
                                    ),
                                  ),
                                  Visibility(
                                    visible: isPlaying &&
                                        playingPlaylistName ==
                                            playLists[index].title,
                                    replacement: IconButton(
                                      onPressed: onPlayPlaylist == null
                                          ? null
                                          : () => onPlayPlaylist!(
                                                playLists[index],
                                              ),
                                      icon: const Icon(
                                        TablerIcons.player_play_filled,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Lottie.asset(
                                      'assets/lottie/music_playing.json',
                                      width: 50,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: albumWidth * 0.04),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      playLists[index].title,
                                      maxLines: showSongCount ? 1 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: albumWidth * 0.13 - 1,
                                        height: 1,
                                      ),
                                    ),
                                    showSongCount
                                        ? Text(
                                            playLists[index].trackCount ==
                                                        null ||
                                                    playLists[index]
                                                            .trackCount ==
                                                        0
                                                ? ""
                                                : "${playLists[index].trackCount}首",
                                            maxLines: 1,
                                            style: context.textTheme.bodySmall,
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
