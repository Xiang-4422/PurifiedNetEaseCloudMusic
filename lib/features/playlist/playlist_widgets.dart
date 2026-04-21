import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/playlist/playlist_summary_data.dart';
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
  final Widget? trailing;

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
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            if (picUrl != null)
              SimpleExtendedImage(
                picUrl ?? '',
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
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// `SongItem` 统一承接“点击即按当前上下文播放”的行为，避免每个页面再手写一次播放入口。
class SongItem extends StatefulWidget {
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
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  late DownloadState _downloadState;
  bool _handlingDownloadAction = false;

  @override
  void initState() {
    super.initState();
    _downloadState = _resolveDownloadState();
  }

  @override
  void didUpdateWidget(covariant SongItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playlist[oldWidget.index].id !=
            widget.playlist[widget.index].id ||
        oldWidget.playlist[oldWidget.index].extras?['downloadState'] !=
            widget.playlist[widget.index].extras?['downloadState']) {
      _downloadState = _resolveDownloadState();
    }
  }

  DownloadState _resolveDownloadState() {
    final mediaItem = widget.playlist[widget.index];
    return DownloadState.values.firstWhere(
      (state) =>
          state.name ==
          '${mediaItem.extras?['downloadState'] ?? DownloadState.none.name}',
      orElse: () => DownloadState.none,
    );
  }

  Future<void> _handleDownloadAction() async {
    if (_handlingDownloadAction) {
      return;
    }
    final mediaItem = widget.playlist[widget.index];
    final requestedState = _downloadState;
    setState(() {
      _handlingDownloadAction = true;
      if (requestedState == DownloadState.none ||
          requestedState == DownloadState.failed) {
        _downloadState = DownloadState.downloading;
      }
    });

    try {
      Track? updatedTrack;
      switch (requestedState) {
        case DownloadState.none:
          updatedTrack =
              await PlayerController.to.downloadTrackById(mediaItem.id);
          break;
        case DownloadState.queued:
        case DownloadState.downloading:
          updatedTrack =
              await PlayerController.to.cancelTrackDownloadById(mediaItem.id);
          break;
        case DownloadState.downloaded:
          updatedTrack =
              await PlayerController.to.removeDownloadedTrackById(mediaItem.id);
          break;
        case DownloadState.failed:
          updatedTrack =
              await PlayerController.to.retryTrackDownloadById(mediaItem.id);
          break;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _downloadState = updatedTrack?.downloadState ?? _resolveDownloadState();
      });
    } finally {
      if (mounted) {
        setState(() {
          _handlingDownloadAction = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaItem = widget.playlist[widget.index];
    final effectiveDownloadState =
        _handlingDownloadAction ? DownloadState.downloading : _downloadState;
    return UniversalListTile(
      picUrl: widget.showPic ? (mediaItem.extras?['image']) : null,
      titleString: mediaItem.title,
      subTitleString: mediaItem.artist,
      stringColor: widget.stringColor,
      trailing: IconButton(
        tooltip: switch (effectiveDownloadState) {
          DownloadState.none => '下载歌曲',
          DownloadState.queued => '取消下载',
          DownloadState.downloading => '取消下载',
          DownloadState.downloaded => '删除下载',
          DownloadState.failed => '重试下载',
        },
        onPressed: _handleDownloadAction,
        icon: Icon(
          switch (effectiveDownloadState) {
            DownloadState.none => TablerIcons.download,
            DownloadState.queued => TablerIcons.x,
            DownloadState.downloading => TablerIcons.x,
            DownloadState.downloaded => TablerIcons.trash,
            DownloadState.failed => TablerIcons.refresh,
          },
          color: widget.stringColor ?? context.theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
      onTap: () async {
        if (widget.beforeOnTap != null) {
          await widget.beforeOnTap!();
        }
        PlayerController.to.playPlaylist(
          widget.playlist,
          widget.index,
          playListName: widget.playListName,
          playListNameHeader: widget.playListHeader,
        );
      },
    );
  }
}

class PlayListItem extends StatelessWidget {
  final PlaylistSummaryData play;
  final Function()? beforeOnTap;

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
class PlayListWidget extends GetView<AppController> {
  static final PlaylistRepository _repository = PlaylistRepository();

  final double albumCountInWidget;
  final double albumMargin;
  final List<PlaylistSummaryData> playLists;
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
                                    playLists[index].coverUrl ?? '',
                                  ),
                                  Obx(
                                    () => Visibility(
                                      visible: controller.isPlaying.isTrue &&
                                          controller.playbackSessionState.value
                                                  .playlistName ==
                                              playLists[index].title,
                                      replacement: IconButton(
                                        onPressed: () {
                                          if (controller.playbackSessionState
                                                  .value.playlistName !=
                                              playLists[index].title) {
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

  Future<void> _playPlaylist(PlaylistSummaryData playlist) async {
    final details = await _repository.fetchPlaylistSnapshot(playlist.id);
    final songs = await _repository.fetchPlaylistSongs(
      playlistId: playlist.id,
      likedSongIds: controller.likedSongIds.toList(),
      playlistSnapshot: details,
    );
    await controller.playerController.playPlaylist(
      songs,
      0,
      playListName: details.name,
      playListNameHeader: '歌单',
    );
  }
}
