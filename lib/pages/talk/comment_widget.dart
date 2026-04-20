import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/features/comment/comment_data.dart';
import 'package:bujuan/features/comment/comment_list_controller.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:bujuan/pages/talk/custom_field.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widget/simple_extended_image.dart';

class CommentWidget extends StatefulWidget {
  const CommentWidget({
    super.key,
    required this.context,
    required this.id,
    required this.idType,
    required this.commentType,
    required this.listPaddingTop,
    required this.listPaddingBottom,
    required this.stringColor,
  });

  final BuildContext context;
  final int commentType;
  final String id;
  final String idType;
  final double listPaddingTop;
  final double listPaddingBottom;
  final Color stringColor;

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late final CommentListController _controller;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _controller = CommentListController(
      id: widget.id,
      type: widget.idType,
      sortType: widget.commentType,
    )..loadInitial();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PagedState<CommentData>>(
      valueListenable: _controller.state,
      builder: (context, state, child) {
        if (state.initialLoading) {
          return const LoadingView();
        }
        if (state.hasInitialError) {
          return const ErrorView();
        }
        if (state.isEmpty) {
          return const EmptyView();
        }
        return SmartRefresher(
          enablePullDown: true,
          enablePullUp: state.hasMore,
          controller: _refreshController,
          onRefresh: () async {
            await _controller.refresh();
            _refreshController.refreshCompleted();
            _refreshController.resetNoData();
            if (!_controller.state.value.hasMore) {
              _refreshController.loadNoData();
            }
          },
          onLoading: () async {
            final success = await _controller.loadMore();
            if (!mounted) {
              return;
            }
            if (!success) {
              _refreshController.loadFailed();
              return;
            }
            if (_controller.state.value.hasMore) {
              _refreshController.loadComplete();
            } else {
              _refreshController.loadNoData();
            }
          },
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return SizedBox(height: widget.listPaddingTop);
              }
              if (index == state.items.length + 1) {
                return SizedBox(height: widget.listPaddingBottom);
              }
              return CommentItemWidget(
                id: widget.id,
                idType: widget.idType,
                comment: state.items[index - 1],
                stringColor: widget.stringColor,
              ).marginOnly(top: index == 1 ? 0 : 10);
            },
            itemCount: state.items.length + 2,
          ),
        );
      },
    );
  }
}

class CommentItemWidget extends StatefulWidget {
  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.stringColor,
    this.id = "",
    this.idType = "",
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
  static final CommentRepository _repository = CommentRepository();
  late final FloorCommentController _floorController;
  bool isCommentOnCommentVisible = false;

  late CommentData comment;
  late Color stringColor;
  late int replyCount;
  late int unExpandedReplyCount;

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
    stringColor = widget.stringColor;
    replyCount = comment.replyCount;
    unExpandedReplyCount = comment.replyCount;
    _floorController = FloorCommentController(
      id: widget.id,
      type: widget.idType,
      parentCommentId: widget.comment.commentId,
      pageSize: 5,
    );
  }

  @override
  void dispose() {
    _floorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showOrHideCommentOnComment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isCommentOnCommentVisible
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
                '${comment.user.avatarUrl}?param=150y150',
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
                                    '\n${OtherUtils.formatDate2Str(comment.time)}',
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
                            comment.likedCount == 0 ? '' : '${comment.likedCount}',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: "monospace",
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
                              onTap: () {
                                _repository
                                    .toggleCommentLike(
                                  widget.id,
                                  widget.idType,
                                  comment.commentId,
                                  !comment.liked,
                                )
                                    .then((value) {
                                  if (value.success) {
                                    setState(() {
                                      final liked = !comment.liked;
                                      comment = comment.copyWith(
                                        liked: liked,
                                        likedCount: liked
                                            ? comment.likedCount + 1
                                            : comment.likedCount - 1,
                                      );
                                    });
                                  }
                                });
                              },
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
                    offstage: !isCommentOnCommentVisible,
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
                    visible: !widget.isReply && replyCount > 0,
                    child: GestureDetector(
                      onTap: () {
                        if (unExpandedReplyCount > 0) {
                          expandComment();
                        } else {
                          foldComment();
                        }
                      },
                      child: Container(
                        alignment: FractionalOffset.centerLeft,
                        color: Colors.transparent,
                        child: Text(
                          unExpandedReplyCount > 0
                              ? '—— $unExpandedReplyCount条回复 >'
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

  void showOrHideCommentOnComment() {
    if (widget.isReply) {
      return;
    }
    if (isCommentOnCommentVisible) {
      foldComment();
    } else {
      expandComment();
    }
  }

  void foldComment() {
    setState(() {
      isCommentOnCommentVisible = false;
      unExpandedReplyCount = replyCount;
    });
  }

  Future<void> expandComment() async {
    if (!isCommentOnCommentVisible &&
        _floorController.state.value.items.isNotEmpty) {
      setState(() {
        isCommentOnCommentVisible = true;
        unExpandedReplyCount =
            replyCount - _floorController.state.value.items.length;
      });
      return;
    }
    if (_floorController.state.value.items.isEmpty) {
      await _floorController.loadInitial();
    } else if (_floorController.state.value.hasMore) {
      await _floorController.loadMore();
    }
    if (!mounted) {
      return;
    }
    setState(() {
      isCommentOnCommentVisible = true;
      unExpandedReplyCount =
          replyCount - _floorController.state.value.items.length;
    });
  }
}

class FoolTalk extends StatefulWidget {
  const FoolTalk({
    super.key,
    required this.commentItem,
    required this.id,
    required this.type,
    required this.backGroundColor,
  });

  final CommentData commentItem;
  final String id;
  final String type;
  final Color backGroundColor;

  @override
  State<FoolTalk> createState() => _FoolTalkState();
}

class _FoolTalkState extends State<FoolTalk> {
  static final CommentRepository _repository = CommentRepository();
  final TextEditingController _textEditingController = TextEditingController();
  final RefreshController _refreshController = RefreshController();
  late final FloorCommentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FloorCommentController(
      id: widget.id,
      type: widget.type,
      parentCommentId: widget.commentItem.commentId,
      pageSize: 20,
    )..loadInitial();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        color: widget.backGroundColor,
        height: context.height / 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              color: Theme.of(context).colorScheme.onSecondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SimpleExtendedImage.avatar(
                        '${widget.commentItem.user.avatarUrl}?param=150y150',
                        width: 60,
                        height: 60,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: widget.commentItem.user.nickname,
                            style: TextStyle(
                              fontSize: 28,
                              color: Theme.of(context).cardColor,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    ' (${OtherUtils.formatDate2Str(widget.commentItem.time)}) ',
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 80),
                    child: Text(
                      widget.commentItem.content.replaceAll('\n', ''),
                      style: const TextStyle(fontSize: 24),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<PagedState<CommentData>>(
                valueListenable: _controller.state,
                builder: (context, state, child) {
                  if (state.initialLoading) {
                    return const LoadingView();
                  }
                  if (state.hasInitialError) {
                    return const ErrorView();
                  }
                  if (state.isEmpty) {
                    return const EmptyView();
                  }
                  return SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: state.hasMore,
                    controller: _refreshController,
                    onRefresh: () async {
                      await _controller.refresh();
                      _refreshController.refreshCompleted();
                      _refreshController.resetNoData();
                      if (!_controller.state.value.hasMore) {
                        _refreshController.loadNoData();
                      }
                    },
                    onLoading: () async {
                      final success = await _controller.loadMore();
                      if (!mounted) {
                        return;
                      }
                      if (!success) {
                        _refreshController.loadFailed();
                        return;
                      }
                      if (_controller.state.value.hasMore) {
                        _refreshController.loadComplete();
                      } else {
                        _refreshController.loadNoData();
                      }
                    },
                    child: ListView.builder(
                      itemBuilder: (context, index) =>
                          _buildItem(state.items[index]),
                      itemCount: state.items.length,
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                const Padding(padding: EdgeInsets.only(left: 20)),
                Expanded(
                  child: CustomField(
                    iconData: TablerIcons.message_2,
                    textEditingController: _textEditingController,
                    hitText: '请输入想说的话',
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(TablerIcons.brand_telegram),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(CommentData comment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SimpleExtendedImage.avatar(
                '${comment.user.avatarUrl}?param=150y150',
                width: 60,
                height: 60,
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: comment.user.nickname,
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).cardColor,
                    ),
                    children: [
                      TextSpan(
                        text: ' (${OtherUtils.formatDate2Str(comment.time)}) ',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 80),
            child: Text(
              comment.content.replaceAll('\n', ''),
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Visibility(
            visible: comment.replyCount > 0,
            child: GestureDetector(
              child: Container(
                margin: const EdgeInsets.only(left: 60),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Text(
                  '—— ${comment.replyCount}条回复 >',
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => FoolTalk(
                    commentItem: comment,
                    id: context.routeData.queryParams.getString('id'),
                    type: context.routeData.queryParams.getString('type'),
                    backGroundColor: Colors.white,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textEditingController.text.isEmpty) {
      WidgetUtil.showToast('请输入评论');
      return;
    }
    final commentWrap = await _repository.sendComment(
      widget.id,
      widget.type,
      'reply',
      content: _textEditingController.text,
      commentId: widget.commentItem.commentId,
    );
    if (commentWrap.success) {
      _textEditingController.text = '';
      WidgetUtil.showToast('评论成功');
      await _controller.refresh();
    } else {
      WidgetUtil.showToast(commentWrap.message ?? '评论失败');
    }
  }
}

class TalkItem {
  TalkItem(this.title, this.type);

  String title;
  int type;
}
