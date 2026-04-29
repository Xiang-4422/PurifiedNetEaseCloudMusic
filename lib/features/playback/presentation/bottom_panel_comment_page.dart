import 'package:bujuan/app/presentation_adapters/comment_content_port.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/widget/keep_alive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// BottomPanelCommentPage。
class BottomPanelCommentPage extends StatelessWidget {
  /// 创建 BottomPanelCommentPage。
  const BottomPanelCommentPage({
    super.key,
    required this.commentType,
  });

  /// commentType。
  final int commentType;

  CommentContentPort get _commentContentPort => Get.find<CommentContentPort>();

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;

    return KeepAliveWrapper(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: albumPadding),
        child: Obx(() {
          final currentSong = PlayerController.to.currentSongState.value;
          return _commentContentPort.buildSongComments(
            context: context,
            songId: currentSong.id,
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
