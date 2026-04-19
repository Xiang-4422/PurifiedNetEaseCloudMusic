import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/pages/talk/custom_filed.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../common/netease_api/src/api/event/bean.dart';
import '../../widget/request_widget/request_loadmore_view.dart';
import '../../widget/simple_extended_image.dart';

class CommentWidget extends StatelessWidget {
  static final CommentRepository _repository = CommentRepository();
  final BuildContext context;
  final int commentType;
  final String id;
  final String idType;
  final double listPaddingTop;
  final double listPaddingBottom;
  final Color stringColor;

  const CommentWidget(
      {Key? key,
      required this.context,
      required this.id,
      required this.idType,
      required this.commentType,
      required this.listPaddingTop,
      required this.listPaddingBottom,
      required this.stringColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RequestLoadMoreWidget<CommentList2Wrap, CommentItem>(
      listKey: const ['data', 'comments'],
      isPageNmu: true,
      lastField: 'cursor',
      pageSize: 10,
      dioMetaData: _repository.buildCommentListRequest(
        id,
        idType,
        sortType: commentType,
      ),
      childBuilder: (List<CommentItem> comments) => ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container(
              height: listPaddingTop,
            );
          } else if (index == comments.length) {
            return Container(
              height: listPaddingBottom,
            );
          } else {
            return CommentItemWidget(
                    id: id,
                    idType: idType,
                    comment: comments[index - 1],
                    stringColor: stringColor)
                .marginOnly(top: index == 1 ? 0 : 10);
          }
        },
        itemCount: comments.length,
      ),
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

  /// 这个id是歌单、歌曲等的id
  final String id;
  final String idType;
  final CommentItem comment;

  final Color stringColor;
  final bool isReply;

  @override
  State<CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<CommentItemWidget> {
  static final CommentRepository _repository = CommentRepository();
  final List<CommentItem> _commentOnComment = [];
  bool isCommentOnCommentVisible = false;
  int lastLoadedTime = -1;

  late CommentItem comment;
  late Color stringColor;
  late int replyCount;
  late int unExpandedReplyCount;

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
    stringColor = widget.stringColor;
    replyCount = comment.replyCount ?? 0;
    unExpandedReplyCount = comment.replyCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showOrHideCommentOnComment(),
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
          crossAxisAlignment: CrossAxisAlignment.start, // 子组件拉伸对齐
          children: [
            // 头像
            Opacity(
              opacity: 0.8,
              child: SimpleExtendedImage.avatar(
                '${comment.user.avatarUrl ?? ''}?param=150y150',
                width: 30,
                height: 30,
              ),
            ).marginOnly(right: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 用户名&时间、点赞
                  Row(children: [
                    // 用户名、评论时间
                    Expanded(
                        child: RichText(
                            // 评论用户
                            text: TextSpan(
                                text: comment.user.nickname ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: stringColor.withValues(alpha: 0.6),
                                ),
                                children: [
                          // 评论时间
                          TextSpan(
                            text:
                                '\n${OtherUtils.formatDate2Str(comment.time ?? 0)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: stringColor.withValues(alpha: 0.4),
                            ),
                          )
                        ]))),
                    // 点赞数
                    Row(
                      children: [
                        Text(
                          (comment.likedCount ?? 0) == 0
                              ? ''
                              : '${comment.likedCount ?? 0}',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: "monospace",
                            color: comment.liked ?? false
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
                                !(comment.liked ?? false),
                              )
                                  .then((value) {
                                if (value.code == 200) {
                                  setState(() {
                                    comment.liked = !(comment.liked ?? false);
                                    comment.likedCount = comment.liked!
                                        ? (comment.likedCount ?? 0) + 1
                                        : (comment.likedCount ?? 0) - 1;
                                  });
                                }
                              });
                            },
                            child: Icon(
                              comment.liked ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              size: 20,
                              color: comment.liked ?? false
                                  ? Colors.red
                                  : stringColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    )
                  ]),
                  // 评论内容
                  Text(
                    (comment.content ?? '').replaceAll('\n', ''),
                    style: TextStyle(
                        color: stringColor.withValues(alpha: 0.6),
                        fontSize: 15),
                  ).marginSymmetric(vertical: 10),
                  // 评论的回复内容
                  Offstage(
                    offstage: !isCommentOnCommentVisible,
                    child: Column(
                      children: (_commentOnComment).map((CommentItem item) {
                        return CommentItemWidget(
                          comment: item,
                          id: widget.id,
                          idType: widget.idType,
                          stringColor: stringColor,
                          isReply: true,
                        );
                      }).toList(),
                    ),
                  ),
                  // 展开回复按钮
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
                              )),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showOrHideCommentOnComment() {
    if (widget.isReply) return;
    // 收起回复
    if (isCommentOnCommentVisible) {
      foldComment();
    } else {
      // 展开回复
      expandComment();
    }
  }

  foldComment() {
    setState(() {
      isCommentOnCommentVisible = false;
      unExpandedReplyCount = replyCount;
    });
  }

  expandComment() async {
    // 已经加载数据，且回复折叠，打开折叠的回复
    if (!isCommentOnCommentVisible && _commentOnComment.isNotEmpty) {
      setState(() {
        isCommentOnCommentVisible = true;
        unExpandedReplyCount = replyCount - _commentOnComment.length;
      });
      return;
    }
    // 加载数据
    FloorCommentDetailWrap floorCommentDetailWrap =
        await _repository.fetchFloorComments(
      widget.id,
      widget.idType,
      widget.comment.commentId,
      time: lastLoadedTime,
      limit: 5,
    );
    lastLoadedTime = floorCommentDetailWrap.data.time ?? -1;
    setState(() {
      isCommentOnCommentVisible = true;
      _commentOnComment.addAll(floorCommentDetailWrap.data.comments ?? []);
      unExpandedReplyCount = replyCount - _commentOnComment.length;
    });
  }
}

/// 评论的回复
class FoolTalk extends StatefulWidget {
  final CommentItem commentItem;
  final String id;
  final String type;
  final Color backGroundColor;

  const FoolTalk(
      {Key? key,
      required this.commentItem,
      required this.id,
      required this.type,
      required this.backGroundColor})
      : super(key: key);

  @override
  State<FoolTalk> createState() => _FoolTalkState();
}

class _FoolTalkState extends State<FoolTalk> {
  static final CommentRepository _repository = CommentRepository();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
            // 当前评论
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              color: Theme.of(context).colorScheme.onSecondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SimpleExtendedImage.avatar(
                        '${widget.commentItem.user.avatarUrl ?? ''}?param=150y150',
                        width: 60,
                        height: 60,
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8)),
                      Expanded(
                          child: RichText(
                              text: TextSpan(
                                  text: widget.commentItem.user.nickname ?? '',
                                  style: TextStyle(
                                      fontSize: 28,
                                      color: Theme.of(context).cardColor),
                                  children: [
                            TextSpan(
                              text:
                                  ' (${OtherUtils.formatDate2Str(widget.commentItem.time ?? 0)}) ',
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.grey),
                            )
                          ]))),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 80),
                    child: Text(
                      (widget.commentItem.content ?? '').replaceAll('\n', ''),
                      style: const TextStyle(fontSize: 24),
                    ),
                  )
                ],
              ),
            ),
            // 当前评论的回复
            Expanded(
                child:
                    RequestLoadMoreWidget<FloorCommentDetailWrap, CommentItem>(
              pageSize: 20,
              lastField: 'time',
              dioMetaData: _repository.buildFloorCommentsRequest(
                widget.id,
                widget.type,
                widget.commentItem.commentId,
              ),
              childBuilder: (list) {
                return ListView.builder(
                  itemBuilder: (context, index) => _buildItem(list[index]),
                  itemCount: list.length,
                );
              },
              listKey: const ['data', 'comments'],
            )),
            // 回复当前评论
            Row(
              children: [
                const Padding(padding: EdgeInsets.only(left: 20)),
                Expanded(
                    child: CustomFiled(
                  iconData: TablerIcons.message_2,
                  textEditingController: _textEditingController,
                  hitText: '请输入想说的话',
                )),
                IconButton(
                    onPressed: () => _sendMessage(),
                    icon: const Icon(TablerIcons.brand_telegram))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(CommentItem comment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SimpleExtendedImage.avatar(
                '${comment.user.avatarUrl ?? ''}?param=150y150',
                width: 60,
                height: 60,
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
              Expanded(
                  child: RichText(
                      text: TextSpan(
                          text: comment.user.nickname ?? '',
                          style: TextStyle(
                              fontSize: 28, color: Theme.of(context).cardColor),
                          children: [
                    TextSpan(
                      text:
                          ' (${OtherUtils.formatDate2Str(comment.time ?? 0)}) ',
                      style: const TextStyle(fontSize: 22, color: Colors.grey),
                    )
                  ]))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 80),
            child: Text(
              (comment.content ?? '').replaceAll('\n', ''),
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Visibility(
              visible: (comment.replyCount ?? 0) > 0,
              child: GestureDetector(
                child: Container(
                  margin: const EdgeInsets.only(left: 60),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Text('—— ${comment.replyCount}条回复 >',
                      style: const TextStyle(fontSize: 24, color: Colors.blue)),
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
              ))
        ],
      ),
    );
  }

  _sendMessage() async {
    if (_textEditingController.text.isEmpty) {
      WidgetUtil.showToast('请输入评论');
      return;
    }
    CommentWrap commentWrap = await _repository.sendComment(
      widget.id,
      widget.type,
      'reply',
      content: _textEditingController.text,
      commentId: widget.commentItem.commentId,
    );
    if (commentWrap.code == 200) {
      _textEditingController.text = '';
      WidgetUtil.showToast('评论成功');
    } else {
      WidgetUtil.showToast(commentWrap.message ?? '评论失败');
    }
  }
}

class TalkItem {
  String title;
  int type;

  TalkItem(this.title, this.type);
}
