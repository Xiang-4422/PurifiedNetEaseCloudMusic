import 'package:bujuan/app/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/comment/comment_widget.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/ui/widgets/common/layout/keep_alive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部播放面板内嵌的歌曲评论页。
class BottomPanelCommentPage extends StatelessWidget {
  /// 创建底部面板评论页。
  const BottomPanelCommentPage({
    super.key,
    required this.commentType,
  });

  /// 评论类型，沿用网易云接口中的歌曲评论分类。
  final int commentType;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;

    return KeepAliveWrapper(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: albumPadding),
        child: Obx(() {
          final currentSong = PlayerController.to.currentSongState.value;
          return CommentWidget(
            key: ValueKey(currentSong.id),
            context: context,
            id: currentSong.id,
            idType: 'song',
            commentType: commentType,
            listPaddingTop: albumPadding,
            listPaddingBottom: albumPadding,
            stringColor: SettingsController.to.panelWidgetColor.value,
          );
        }),
      ),
    );
  }
}
