import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/widgets/common/layout/keep_alive_wrapper.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _unknownQueueArtistText = '未知歌手';
const _currentQueueItemColor = Colors.red;
const double _bottomPanelQueueCacheExtent = 480;

/// 底部播放面板中的当前播放队列视图。
class BottomPanelQueueView extends GetView<ShellController> {
  /// 创建当前播放队列视图。
  const BottomPanelQueueView({
    super.key,
    required this.playerController,
    required this.settingsController,
  });

  /// 播放控制器。
  final PlayerController playerController;

  /// 设置控制器。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return KeepAliveWrapper(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: albumPadding),
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: Obx(
            () => ListView.builder(
              controller: controller.playListScrollController,
              cacheExtent: _bottomPanelQueueCacheExtent,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: albumPadding),
              itemCount: playerController.queueState.length,
              itemBuilder: (context, index) {
                return _BottomPanelQueueItem(
                  item: playerController.queueState[index],
                  index: index,
                  playerController: playerController,
                  settingsController: settingsController,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomPanelQueueItem extends StatelessWidget {
  const _BottomPanelQueueItem({
    required this.item,
    required this.index,
    required this.playerController,
    required this.settingsController,
  });

  final PlaybackQueueItem item;
  final int index;
  final PlayerController playerController;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final metrics = AdaptiveLayoutMetrics.of(context);
      final isCurrent = playerController.currentQueueIndex.value == index;
      final panelColor = settingsController.panelWidgetColor.value;
      final artistText = playbackQueueArtistDisplayText(item);
      return Semantics(
        button: true,
        excludeSemantics: true,
        selected: isCurrent,
        label: '${item.title}, $artistText',
        child: GestureDetector(
          onTap: () => playerController.playQueueIndex(index),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: metrics.listTileMinHeight),
            child: Container(
              color: Colors.transparent,
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: playbackQueueTitleColor(
                            isCurrent: isCurrent,
                            panelColor: panelColor,
                          ),
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    artistText,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: panelColor.withValues(alpha: 0.5),
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// 生成播放队列条目的歌手展示文本。
@visibleForTesting
String playbackQueueArtistDisplayText(PlaybackQueueItem item) {
  final artist = item.artist?.trim();
  if (artist == null || artist.isEmpty) {
    return _unknownQueueArtistText;
  }
  return artist;
}

/// 生成播放队列条目的标题颜色。
@visibleForTesting
Color playbackQueueTitleColor({
  required bool isCurrent,
  required Color panelColor,
}) {
  if (isCurrent) {
    return _currentQueueItemColor;
  }
  return panelColor;
}
