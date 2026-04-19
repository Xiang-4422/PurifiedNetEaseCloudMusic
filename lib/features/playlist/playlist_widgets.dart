import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/data/netease/api/src/api/play/bean.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/keep_alive_wrapper.dart';
import 'package:bujuan/widget/scroll_helpers.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

/// 这批组件都围绕歌单、歌曲列表和播放入口组织，放回 playlist feature 比继续挂在页面文件或 common 更清晰。
class Header extends StatelessWidget {
  final String title;
  final double padding;

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
  final String titleString;
  final String? subTitleString;
  final String? picUrl;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onLongPress;
  final Color? stringColor;

  const UniversalListTile({
    super.key,
    required this.titleString,
    this.subTitleString,
    this.picUrl,
    this.stringColor,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            if (picUrl != null)
              SimpleExtendedImage(
                '${picUrl ?? ''}?param=150y150',
                width: 44,
                height: 44,
                cacheWidth: 120,
                borderRadius: BorderRadius.circular(8),
              ),
            if (picUrl != null)
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
          ],
        ),
      ),
    );
  }
}

/// `SongItem` 统一承接“点击即按当前上下文播放”的行为，避免每个页面再手写一次播放入口。
class SongItem extends StatelessWidget {
  final int index;
  final List<MediaItem> playlist;
  final String playListName;
  final String playListHeader;
  final Function()? beforeOnTap;
  final Color? stringColor;
  final bool showPic;
  final bool showIndex;

  const SongItem({
    Key? key,
    this.beforeOnTap,
    this.stringColor,
    this.showPic = true,
    this.showIndex = false,
    this.playListHeader = "",
    required this.playlist,
    required this.index,
    required this.playListName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UniversalListTile(
      picUrl: showPic ? (playlist[index].extras?['image']) : null,
      titleString: playlist[index].title,
      subTitleString: playlist[index].artist,
      stringColor: stringColor,
      onTap: () async {
        if (beforeOnTap != null) {
          await beforeOnTap!();
        }
        PlayerController.to.playPlaylist(
          playlist,
          index,
          playListName: playListName,
          playListNameHeader: playListHeader,
        );
      },
    );
  }
}

class PlayListItem extends StatelessWidget {
  final PlayList play;
  final Function()? beforeOnTap;

  const PlayListItem(this.play, {Key? key, this.beforeOnTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = context.router;
    return UniversalListTile(
      picUrl: play.coverImgUrl ?? play.picUrl,
      titleString: play.name ?? "无歌单名",
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
            playlistName: play.name ?? '无名歌单',
            coverUrl: play.coverImgUrl ?? play.picUrl,
            trackCount: play.trackCount,
          ),
        );
      },
    );
  }
}

/// 歌单卡片既负责展示，也负责触发“播放整个歌单”，因此归在 playlist feature 比挂在 common 更合适。
class PlayListWidget extends GetView<AppController> {
  static final PlaylistRepository _repository = PlaylistRepository();

  final double albumCountInWidget;
  final double albumMargin;
  final List<PlayList> playLists;
  final bool showSongCount;
  final bool snappAllAlbum;
  final bool noScroll;

  const PlayListWidget({
    Key? key,
    required this.playLists,
    this.albumCountInWidget = 2.5,
    this.albumMargin = 0,
    this.showSongCount = true,
    this.snappAllAlbum = false,
    this.noScroll = false,
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
                                playlistName: playLists[index].name ?? '无名歌单',
                                coverUrl: playLists[index].coverImgUrl ??
                                    playLists[index].picUrl,
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
                                    '${playLists[index].coverImgUrl ?? playLists[index].picUrl}?param=200y200',
                                  ),
                                  Obx(
                                    () => Visibility(
                                      visible: controller.isPlaying.isTrue &&
                                          controller.playbackSessionState.value
                                                  .playlistName ==
                                              playLists[index].name,
                                      replacement: IconButton(
                                        onPressed: () {
                                          if (controller.playbackSessionState
                                                  .value.playlistName !=
                                              playLists[index].name) {
                                            _playPlaylist(playLists[index]);
                                          } else {
                                            controller.playOrPause();
                                          }
                                        },
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
                                      "${playLists[index].name}",
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

  Future<void> _playPlaylist(PlayList playlist) async {
    final details = await _repository.fetchPlaylistWrap(playlist.id);
    final songs = await _repository.fetchPlaylistSongs(
      playlistId: playlist.id,
      likedSongIds: controller.likedSongIds.toList(),
      playlistWrap: details,
    );
    await controller.playerController.playPlaylist(
      songs,
      0,
      playListName: details.playlist?.name ?? '无名歌单',
      playListNameHeader: '歌单',
    );
  }
}
