import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:flutter/widgets.dart';

/// 评论回复弹层状态，集中管理输入框和发送后的刷新动作。
class ReplySheetController {
  ReplySheetController({required FloorCommentController floorController})
      : _floorController = floorController;

  final FloorCommentController _floorController;
  final TextEditingController textEditingController = TextEditingController();

  Future<String?> sendReply({required String commentId}) async {
    final content = textEditingController.text;
    if (content.isEmpty) {
      return '请输入评论';
    }
    final errorMessage = await _floorController.sendReply(
      content: content,
      commentId: commentId,
    );
    if (errorMessage != null) {
      return errorMessage;
    }
    textEditingController.text = '';
    await _floorController.refresh();
    return null;
  }

  void dispose() {
    textEditingController.dispose();
  }
}
