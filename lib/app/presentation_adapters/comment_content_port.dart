import 'package:flutter/material.dart';

/// 评论内容展示端口，用于让播放面板按需构建歌曲评论区域。
class CommentContentPort {
  /// 创建评论内容展示端口。
  const CommentContentPort({
    required this.buildSongComments,
  });

  /// 构建歌曲评论组件的回调。
  final Widget Function({
    required BuildContext context,
    required String songId,
    required int commentType,
    required double listPaddingTop,
    required double listPaddingBottom,
    required Color stringColor,
  }) buildSongComments;
}
