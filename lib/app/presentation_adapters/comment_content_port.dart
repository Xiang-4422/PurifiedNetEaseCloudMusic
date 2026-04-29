import 'package:flutter/material.dart';

class CommentContentPort {
  const CommentContentPort({
    required this.buildSongComments,
  });

  final Widget Function({
    required BuildContext context,
    required String songId,
    required int commentType,
    required double listPaddingTop,
    required double listPaddingBottom,
    required Color stringColor,
  }) buildSongComments;
}
