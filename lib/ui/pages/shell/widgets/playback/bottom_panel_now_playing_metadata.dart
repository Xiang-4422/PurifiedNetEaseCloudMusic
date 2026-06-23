import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 正在播放页的大封面态元信息区，展示专辑、歌手和播放进度。
class BottomPanelNowPlayingMetadata extends GetView<ShellController> {
  /// 创建正在播放页元信息区。
  const BottomPanelNowPlayingMetadata({
    required this.playerController,
    required this.settingsController,
    super.key,
  });

  /// 播放控制器，向子组件提供播放状态。
  final PlayerController playerController;

  /// 设置控制器，向子组件提供播放面板取色。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    final remainWidth = (context.width - albumPadding * 2).clamp(0.0, double.infinity);
    final textWidth = _measureTextWidth(
          '歌手：',
          TextStyle(color: settingsController.panelWidgetColor.value),
        ) +
        albumPadding +
        4;
    return Obx(
      () => Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: controller.isBigAlbum.isTrue,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: albumPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AlbumInfoChip(
                playerController: playerController,
                settingsController: settingsController,
                remainWidth: remainWidth,
                textWidth: textWidth,
              ).marginOnly(top: albumPadding),
              _ArtistInfoChip(
                playerController: playerController,
                settingsController: settingsController,
                remainWidth: remainWidth,
                textWidth: textWidth,
              ).marginOnly(top: albumPadding),
              BottomPanelProgressBar(
                playerController: playerController,
                settingsController: settingsController,
              ).marginOnly(
                top: albumPadding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumInfoChip extends GetView<ShellController> {
  const _AlbumInfoChip({
    required this.playerController,
    required this.settingsController,
    required this.remainWidth,
    required this.textWidth,
  });

  final PlayerController playerController;
  final SettingsController settingsController;
  final double remainWidth;
  final double textWidth;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return SizedBox(
      height: albumPadding,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: settingsController.panelWidgetColor.value.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(albumPadding),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.only(left: albumPadding / 2),
                    child: Text(
                      '专辑：',
                      style: TextStyle(
                        color: settingsController.panelWidgetColor.value,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final currentSong = playerController.currentSongState.value;
                    final albumId = currentSong.albumId;
                    if (albumId?.isNotEmpty != true) {
                      return;
                    }
                    final router = context.router;
                    await controller.bottomPanelController.close();
                    router.push(
                      const gr.AlbumRouteView().copyWith(
                        queryParams: {'albumId': albumId},
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: settingsController.panelWidgetColor.value.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(albumPadding),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: remainWidth - textWidth,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: albumPadding / 2,
                        ),
                        child: Obx(
                          () => Text(
                            playerController.currentSongState.value.albumTitle ?? '未知专辑',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: settingsController.panelWidgetColor.value,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}

class _ArtistInfoChip extends GetView<ShellController> {
  const _ArtistInfoChip({
    required this.playerController,
    required this.settingsController,
    required this.remainWidth,
    required this.textWidth,
  });

  final PlayerController playerController;
  final SettingsController settingsController;
  final double remainWidth;
  final double textWidth;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return SizedBox(
      height: albumPadding,
      child: Row(
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: settingsController.panelWidgetColor.value.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(albumPadding),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.only(left: albumPadding / 2),
                    child: Text(
                      '歌手：',
                      style: TextStyle(
                        color: settingsController.panelWidgetColor.value,
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: remainWidth - textWidth,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() {
                      final currentSong = playerController.currentSongState.value;
                      final artists = _artistEntries(currentSong);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: artists.isEmpty
                            ? [
                                Text(
                                  '未知歌手',
                                  style: TextStyle(
                                    color: settingsController.panelWidgetColor.value,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ]
                            : [
                                for (final artist in artists)
                                  _ArtistRouteChip(
                                    artist: artist,
                                    settingsController: settingsController,
                                  ),
                              ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}

class _ArtistRouteChip extends GetView<ShellController> {
  const _ArtistRouteChip({
    required this.artist,
    required this.settingsController,
  });

  final _ArtistChipData artist;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: albumPadding / 2),
      decoration: BoxDecoration(
        color: settingsController.panelWidgetColor.value.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(albumPadding),
      ),
      child: GestureDetector(
        onTap: () async {
          if (artist.id.isEmpty) {
            return;
          }
          final router = context.router;
          await controller.closeBottomPanel();
          router.push(
            const gr.ArtistRouteView().copyWith(
              queryParams: {'artistId': artist.id},
            ),
          );
        },
        child: Text(
          artist.name,
          style: TextStyle(color: settingsController.panelWidgetColor.value),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

List<_ArtistChipData> _artistEntries(PlaybackQueueItem item) {
  final artistNames = item.artistNames.isNotEmpty ? item.artistNames : (item.artist ?? '').split(' / ').where((artist) => artist.isNotEmpty).toList();
  final artistIds = item.artistIds;
  return List.generate(
    artistNames.length,
    (index) => _ArtistChipData(
      name: artistNames[index],
      id: index < artistIds.length ? artistIds[index] : '',
    ),
  );
}

double _measureTextWidth(
  String text,
  TextStyle style, {
  double maxWidth = double.infinity,
  int? maxLines,
}) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: maxLines,
  )..layout(minWidth: 0, maxWidth: maxWidth);

  return textPainter.size.width;
}

class _ArtistChipData {
  const _ArtistChipData({
    required this.name,
    required this.id,
  });

  final String name;
  final String id;
}
