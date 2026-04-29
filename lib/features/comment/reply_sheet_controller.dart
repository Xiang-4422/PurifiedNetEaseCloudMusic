import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:flutter/widgets.dart';

/// 评论回复弹层状态，集中管理输入框和发送后的刷新动作。
class ReplySheetController {
  /// 创建回复弹层控制器。
  ReplySheetController({required FloorCommentController floorController})
      : _floorController = floorController;

  final FloorCommentController _floorController;

  /// 回复输入框控制器。
  final TextEditingController textEditingController = TextEditingController();

  /// 发送回复，失败时返回可展示错误文案。
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

  /// 释放输入框控制器。
  void dispose() {
    textEditingController.dispose();
  }
}
