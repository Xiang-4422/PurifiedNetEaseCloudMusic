import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/core/time/date_time_formatter.dart';
import 'package:bujuan/domain/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_item_controller.dart';
import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentItemWidget extends StatefulWidget {
  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.stringColor,
    this.id = '',
    this.idType = '',
    this.isReply = false,
  });

  final String id;
  final String idType;
  final CommentData comment;
  final Color stringColor;
  final bool isReply;

  @override
  State<CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<CommentItemWidget> {
  late final FloorCommentController _floorController;
  late final CommentItemController _controller;

  late Color stringColor;

  @override
  void initState() {
    super.initState();
    stringColor = widget.stringColor;
    _floorController = Get.find<FeatureControllerFactory>().floorComment(
      id: widget.id,
      type: widget.idType,
      parentCommentId: widget.comment.commentId,
      pageSize: 5,
    );
    _controller = CommentItemController(
      comment: widget.comment,
      isReply: widget.isReply,
      floorController: _floorController,
    )..addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    _floorController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final comment = _controller.comment;
    return GestureDetector(
      onTap: _controller.toggleReplyVisibility,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: _controller.isReplyVisible
              ? Colors.black.withAlpha(20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.8,
              child: SimpleExtendedImage.avatar(
                ArtworkPathResolver.resolveDisplayPath(comment.user.avatarUrl),
                width: 30,
                height: 30,
              ),
            ).marginOnly(right: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: comment.user.nickname,
                            style: TextStyle(
                              fontSize: 15,
                              color: stringColor.withValues(alpha: 0.6),
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '\n${DateTimeFormatter.commentTime(comment.time)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: stringColor.withValues(alpha: 0.4),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            comment.likedCount == 0
                                ? ''
                                : '${comment.likedCount}',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: comment.liked
                                  ? Colors.red
                                  : stringColor.withValues(alpha: 0.4),
                            ),
                          ).marginOnly(right: 5),
                          Container(
                            height: 30,
                            width: 30,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: _controller.toggleLike,
                              child: Icon(
                                comment.liked
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                size: 20,
                                color: comment.liked
                                    ? Colors.red
                                    : stringColor.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Text(
                    comment.content.replaceAll('\n', ''),
                    style: TextStyle(
                      color: stringColor.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                  ).marginSymmetric(vertical: 10),
                  Offstage(
                    offstage: !_controller.isReplyVisible,
                    child: ValueListenableBuilder<PagedState<CommentData>>(
                      valueListenable: _floorController.state,
                      builder: (context, state, child) {
                        if (state.initialLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (state.hasInitialError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '回复加载失败',
                              style: TextStyle(
                                fontSize: 12,
                                color: stringColor.withValues(alpha: 0.4),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: state.items
                              .map(
                                (item) => CommentItemWidget(
                                  comment: item,
                                  id: widget.id,
                                  idType: widget.idType,
                                  stringColor: stringColor,
                                  isReply: true,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: !widget.isReply && _controller.replyCount > 0,
                    child: GestureDetector(
                      onTap: () {
                        if (_controller.unExpandedReplyCount > 0) {
                          _controller.expand();
                        } else {
                          _controller.fold();
                        }
                      },
                      child: Container(
                        alignment: FractionalOffset.centerLeft,
                        color: Colors.transparent,
                        child: Text(
                          _controller.unExpandedReplyCount > 0
                              ? '—— ${_controller.unExpandedReplyCount}条回复 >'
                              : '收起 <',
                          style: TextStyle(
                            fontSize: 15,
                            color: stringColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
