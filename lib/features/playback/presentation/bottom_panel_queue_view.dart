import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/widget/keep_alive_wrapper.dart';
import 'package:bujuan/widget/scroll_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部播放面板中的当前播放队列视图。
class BottomPanelQueueView extends GetView<ShellController> {
  /// 创建当前播放队列视图。
  const BottomPanelQueueView({super.key});

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
              physics: const ClampingScrollPhysics(),
              itemExtent: 55,
              padding: const EdgeInsets.symmetric(vertical: albumPadding),
              itemCount: PlayerController.to.queueState.length,
              itemBuilder: (context, index) {
                return _BottomPanelQueueItem(
                  item: PlayerController.to.queueState[index],
                  index: index,
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
  });

  final PlaybackQueueItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PlayerController.to.playQueueIndex(index),
      child: Obx(() {
        final isCurrent = PlayerController.to.currentQueueIndex.value == index;
        return Container(
          color: Colors.transparent,
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isCurrent
                          ? Colors.red
                          : SettingsController.to.panelWidgetColor.value,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                item.artist ?? '未知歌手',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: SettingsController.to.panelWidgetColor.value
                          .withValues(alpha: 0.5),
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        );
      }),
    );
  }
}
