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
class BottomPanelNowPlayingMetadata extends StatelessWidget {
  /// 创建正在播放页元信息区。
  const BottomPanelNowPlayingMetadata({
    required this.shellController,
    required this.playerController,
    required this.settingsController,
    super.key,
  });

  /// 壳层控制器，提供大封面态和底部面板关闭动作。
  final ShellController shellController;

  /// 播放控制器，向子组件提供播放状态。
  final PlayerController playerController;

  /// 设置控制器，向子组件提供播放面板取色。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    final remainWidth = (context.width - albumPadding * 2).clamp(0.0, double.infinity);
    final labelWidth = bottomPanelMetadataLabelWidth(
      '歌手：',
      TextStyle(color: settingsController.panelWidgetColor.value),
    );
    final valueMaxWidth = bottomPanelMetadataValueMaxWidth(
      remainWidth: remainWidth,
      labelWidth: labelWidth,
    );
    return Obx(
      () => Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: shellController.isBigAlbum.isTrue,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: albumPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AlbumInfoChip(
                shellController: shellController,
                playerController: playerController,
                settingsController: settingsController,
                labelWidth: labelWidth,
                valueMaxWidth: valueMaxWidth,
              ).marginOnly(top: albumPadding),
              _ArtistInfoChip(
                shellController: shellController,
                playerController: playerController,
                settingsController: settingsController,
                labelWidth: labelWidth,
                valueMaxWidth: valueMaxWidth,
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

class _AlbumInfoChip extends StatelessWidget {
  const _AlbumInfoChip({
    required this.shellController,
    required this.playerController,
    required this.settingsController,
    required this.labelWidth,
    required this.valueMaxWidth,
  });

  final ShellController shellController;
  final PlayerController playerController;
  final SettingsController settingsController;
  final double labelWidth;
  final double valueMaxWidth;

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
                SizedBox(
                  width: labelWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(left: albumPadding / 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '专辑：',
                        style: TextStyle(
                          color: settingsController.panelWidgetColor.value,
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  final currentSong = playerController.currentSongState.value;
                  final albumId = currentSong.albumId;
                  final albumTitle = currentSong.albumTitle;
                  final canOpenAlbum = albumId?.isNotEmpty == true;
                  final controlLabel = bottomPanelAlbumChipControlLabel(
                    albumTitle: albumTitle,
                    canOpenAlbum: canOpenAlbum,
                  );
                  return Semantics(
                    button: canOpenAlbum,
                    enabled: canOpenAlbum,
                    excludeSemantics: true,
                    label: controlLabel,
                    child: Tooltip(
                      message: controlLabel,
                      child: GestureDetector(
                        onTap: canOpenAlbum
                            ? () async {
                                final router = context.router;
                                await shellController.bottomPanelController.close();
                                router.push(
                                  const gr.AlbumRouteView().copyWith(
                                    queryParams: {'albumId': albumId},
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: settingsController.panelWidgetColor.value.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(albumPadding),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: valueMaxWidth,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: albumPadding / 2,
                              ),
                              child: Text(
                                _metadataChipValue(albumTitle, fallback: '未知专辑'),
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
                  );
                }),
              ],
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}

class _ArtistInfoChip extends StatelessWidget {
  const _ArtistInfoChip({
    required this.shellController,
    required this.playerController,
    required this.settingsController,
    required this.labelWidth,
    required this.valueMaxWidth,
  });

  final ShellController shellController;
  final PlayerController playerController;
  final SettingsController settingsController;
  final double labelWidth;
  final double valueMaxWidth;

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
                SizedBox(
                  width: labelWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(left: albumPadding / 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '歌手：',
                        style: TextStyle(
                          color: settingsController.panelWidgetColor.value,
                        ),
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: valueMaxWidth,
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
                                    shellController: shellController,
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

class _ArtistRouteChip extends StatelessWidget {
  const _ArtistRouteChip({
    required this.shellController,
    required this.artist,
    required this.settingsController,
  });

  final ShellController shellController;
  final _ArtistChipData artist;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    final canOpenArtist = artist.id.isNotEmpty;
    final artistName = _metadataChipValue(artist.name, fallback: '未知歌手');
    final controlLabel = bottomPanelArtistChipControlLabel(
      artistName: artistName,
      canOpenArtist: canOpenArtist,
    );
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: albumPadding / 2),
      decoration: BoxDecoration(
        color: settingsController.panelWidgetColor.value.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(albumPadding),
      ),
      child: Semantics(
        button: canOpenArtist,
        enabled: canOpenArtist,
        excludeSemantics: true,
        label: controlLabel,
        child: Tooltip(
          message: controlLabel,
          child: GestureDetector(
            onTap: canOpenArtist
                ? () async {
                    final router = context.router;
                    await shellController.closeBottomPanel();
                    router.push(
                      const gr.ArtistRouteView().copyWith(
                        queryParams: {'artistId': artist.id},
                      ),
                    );
                  }
                : null,
            child: Text(
              artistName,
              style: TextStyle(color: settingsController.panelWidgetColor.value),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
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

/// 生成播放页专辑入口的辅助语义标签。
@visibleForTesting
String bottomPanelAlbumChipControlLabel({
  required String? albumTitle,
  required bool canOpenAlbum,
}) {
  final title = _metadataChipValue(albumTitle, fallback: '未知专辑');
  return canOpenAlbum ? '打开专辑：$title' : '专辑：$title';
}

/// 生成播放页歌手入口的辅助语义标签。
@visibleForTesting
String bottomPanelArtistChipControlLabel({
  required String artistName,
  required bool canOpenArtist,
}) {
  final name = _metadataChipValue(artistName, fallback: '未知歌手');
  return canOpenArtist ? '打开歌手：$name' : '歌手：$name';
}

String _metadataChipValue(String? value, {required String fallback}) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
}

/// 生成正在播放元信息标签的稳定宽度。
@visibleForTesting
double bottomPanelMetadataLabelWidth(
  String label,
  TextStyle style, {
  double horizontalReserve = AppDimensions.paddingLarge + 4,
}) {
  return _measureTextWidth(label, style) + horizontalReserve;
}

/// 生成正在播放元信息值区域的稳定最大宽度。
@visibleForTesting
double bottomPanelMetadataValueMaxWidth({
  required double remainWidth,
  required double labelWidth,
}) {
  return (remainWidth - labelWidth).clamp(0.0, double.infinity).toDouble();
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
