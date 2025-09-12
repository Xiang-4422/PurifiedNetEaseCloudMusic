import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/netease_api/src/netease_api.dart';
import 'package:bujuan/pages/talk/custom_filed.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../common/netease_api/src/api/event/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';
import '../../widget/request_widget/request_loadmore_view.dart';
import '../../widget/simple_extended_image.dart';

// TODO YU4422: 评论功能后续开发
/// 评论组件
class CommentWidget extends StatelessWidget {
  final BuildContext context;
  final int commentType;      // 热门、最新
  final String id;            // 歌曲或歌单ID
  final String idType;        // 歌曲、歌单
  final double listPaddingTop;
  final double listPaddingBottom;
  final Color stringColor;
  final TextEditingController _textEditingController = TextEditingController();

  CommentWidget({
    Key? key,
    required this.context,
    required this.id,
    required this.idType,
    required this.commentType,
    required this.listPaddingTop,
    required this.listPaddingBottom,
    required this.stringColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RequestLoadMoreWidget<CommentList2Wrap, CommentItem>(
        listKey: const ['data', 'comments'],
        isPageNmu: true,
        lastField: 'cursor',
        pageSize: 10,
        dioMetaData: commentListDioMetaData2(id, idType, sortType: commentType),
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
              return CommentItemWidget(id: id, idType: idType, comment: comments[index - 1], stringColor: stringColor, );
            }
          },
          itemCount: comments.length,
        ),
      );
  }

  DioMetaData commentListDioMetaData2(String id, String type, {int pageNo = 1, int pageSize = 20, bool showInner = false, int? sortType}) {
    String typeKey = _type2key(type) + id;
    var params = {
      'threadId': typeKey,
      'pageNo': pageNo,
      'pageSize': pageSize,
      'showInner': showInner,
      'sortType': sortType ?? 99,
      'cursor': 0,
    };
    return DioMetaData(joinUri('/api/v2/resource/comments'),
        data: params, options: joinOptions(encryptType: EncryptType.EApi, eApiUrl: '/api/v2/resource/comments', cookies: {'os': 'pc'}));
  }

  String _type2key(String type) {
    String typeKey = 'R_SO_4_';
    switch (type) {
      case 'song':
        typeKey = 'R_SO_4_';
        break;
      case 'mv':
        typeKey = 'R_MV_5_';
        break;
      case 'playlist':
        typeKey = 'A_PL_0_';
        break;
      case 'album':
        typeKey = 'R_AL_3_';
        break;
      case 'dj':
        typeKey = 'A_DJ_1_';
        break;
      case 'video':
        typeKey = 'R_VI_62_';
        break;
      case 'event':
        typeKey = 'A_EV_2_';
        break;
    }
    return typeKey;
  }

  _sendMessage(BuildContext context) async {
    if (_textEditingController.text.isEmpty) {
      WidgetUtil.showToast('请输入评论');
      return;
    }
    CommentWrap commentWrap = await NeteaseMusicApi().comment(id, idType, 'add', content: _textEditingController.text);
    if (commentWrap.code == 200) {
      _textEditingController.text = '';
      if(context.mounted) Focus.of(context).unfocus();
      WidgetUtil.showToast('评论成功');
    } else {
      WidgetUtil.showToast(commentWrap.message ?? '评论失败');
    }
  }
}


class CommentItemWidget extends StatefulWidget {
  CommentItemWidget({
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

  final List<CommentItem> _commentOnComment = [];
  bool isCommentOnCommentVisible = false;
  int lastLoadedTime = -1;

  late CommentItem comment;
  late Color stringColor;
  late int replyCount;
  late int unExpandedReplyCount;


  @override
  void initState() {
    comment = widget.comment;
    stringColor = widget.stringColor;
    replyCount = comment.replyCount ?? 0;
    unExpandedReplyCount = comment.replyCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => showOrHideCommentOnComment(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 头像、用户名、时间
            Row(
                children: [
                  // 头像
                  Opacity(
                    opacity: 0.8,
                    child: SimpleExtendedImage.avatar(
                      '${comment.user.avatarUrl ?? ''}?param=150y150',
                      width: 30,
                      height: 30,
                    ).paddingOnly(right: 10),
                  ),
                  // 用户名、评论时间
                  Expanded(
                      child: RichText(
                        // 评论用户
                          text: TextSpan(
                              text: comment.user.nickname ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                color: stringColor.withOpacity(0.6),
                              ),
                              children: [
                                // 评论时间
                                TextSpan(
                                  text: '\n${OtherUtils.formatDate2Str(comment.time ?? 0)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: stringColor.withOpacity(0.4),
                                  ),
                                )
                              ]
                          )
                      )
                  ),
                  // 点赞数
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (comment.likedCount ?? 0) == 0 ? '' : '${comment.likedCount ?? 0}',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: "monospace",
                          color: comment.liked ?? false ? Colors.red : stringColor.withOpacity(0.4),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          NeteaseMusicApi().likeComment(widget.id, comment.commentId, widget.idType, !(comment.liked ?? false), threadId: _type2key(widget.idType) + widget.id).then((value) {
                            if(value.code == 200) {
                              setState(() {
                                comment.liked = !(comment.liked ?? false);
                                comment.likedCount = comment.liked! ? (comment.likedCount ?? 0) + 1 : (comment.likedCount ?? 0) - 1;
                              });
                            }
                          });
                        },
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          comment.liked ?? false ? Icons.favorite :Icons.favorite_outline,
                          size: 20,
                          color: comment.liked ?? false ? Colors.red : stringColor.withOpacity(0.4),
                        ),
                      ),
                    ],
                  )
                ]
            ),
            // 评论内容
            Text(
              (comment.content ?? '').replaceAll('\n', ''),
              style: TextStyle(
                  color: stringColor.withOpacity(0.6),
                  fontSize: 15
              ),
            ).marginOnly(left: 40),
            // 评论的回复内容
            Offstage(
              offstage: !isCommentOnCommentVisible,
              child: Column(
                children: (_commentOnComment).map((CommentItem item) {
                  return CommentItemWidget(comment: item, stringColor: stringColor, isReply: true,);
                }).toList(),
              ).marginOnly(left: 40),
            ),
            // 该评论的回复数量
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
                        unExpandedReplyCount > 0 ? '—— $unExpandedReplyCount条回复 >' : '收起 <',
                        style: TextStyle(
                          fontSize: 15,
                          color: stringColor.withOpacity(0.2),
                        )
                    ),
                  ).paddingOnly(left: 40),
                )
            ),
          ],
        ),
      ),
    );
  }

  String _type2key(String type) {
    String typeKey = 'R_SO_4_';
    switch (type) {
      case 'song':
        typeKey = 'R_SO_4_';
        break;
      case 'mv':
        typeKey = 'R_MV_5_';
        break;
      case 'playlist':
        typeKey = 'A_PL_0_';
        break;
      case 'album':
        typeKey = 'R_AL_3_';
        break;
      case 'dj':
        typeKey = 'A_DJ_1_';
        break;
      case 'video':
        typeKey = 'R_VI_62_';
        break;
      case 'event':
        typeKey = 'A_EV_2_';
        break;
    }
    return typeKey;
  }


  showOrHideCommentOnComment() {
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
    FloorCommentDetailWrap floorCommentDetailWrap = await NeteaseMusicApi().floorComments(widget.id, widget.idType, widget.comment.commentId, time: lastLoadedTime, limit: 5);
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

  const FoolTalk({Key? key, required this.commentItem, required this.id, required this.type, required this.backGroundColor}) : super(key: key);

  @override
  State<FoolTalk> createState() => _FoolTalkState();
}
class _FoolTalkState extends State<FoolTalk> {
  final TextEditingController _textEditingController= TextEditingController();

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
              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
              color: Theme.of(context).colorScheme.onSecondary,
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SimpleExtendedImage.avatar(
                        '${widget.commentItem.user.avatarUrl ?? ''}?param=150y150',
                        width: 60,
                        height: 60,
                      ),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                      Expanded(
                          child: RichText(
                              text: TextSpan(text: widget.commentItem.user.nickname ?? '', style: TextStyle(fontSize: 28, color: Theme.of(context).cardColor), children: [
                                TextSpan(
                                  text: ' (${OtherUtils.formatDate2Str(widget.commentItem.time ?? 0)}) ',
                                  style: const TextStyle(fontSize: 22, color: Colors.grey),
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
                child: RequestLoadMoreWidget<FloorCommentDetailWrap, CommentItem>(
                  pageSize: 20,
                  lastField: 'time',
                  dioMetaData: floorCommentsDioMetaData(widget.id, widget.type, widget.commentItem.commentId),
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
                IconButton(onPressed: () => _sendMessage(), icon: const Icon(TablerIcons.brand_telegram))
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
                      text: TextSpan(text: comment.user.nickname ?? '', style: TextStyle(fontSize: 28, color: Theme.of(context).cardColor), children: [
                TextSpan(
                  text: ' (${OtherUtils.formatDate2Str(comment.time ?? 0)}) ',
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
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Text('—— ${comment.replyCount}条回复 >', style: const TextStyle(fontSize: 24, color: Colors.blue)),
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
    CommentWrap commentWrap = await NeteaseMusicApi()
        .comment(widget.id, widget.type, 'reply', content: _textEditingController.text,commentId: widget.commentItem.commentId);
    if (commentWrap.code == 200) {
      _textEditingController.text = '';
      WidgetUtil.showToast('评论成功');
    } else {
      WidgetUtil.showToast(commentWrap.message ?? '评论失败');
    }
  }
  String _type2key(String type) {
    String typeKey = 'R_SO_4_';
    switch (type) {
      case 'song':
        typeKey = 'R_SO_4_';
        break;
      case 'mv':
        typeKey = 'R_MV_5_';
        break;
      case 'playlist':
        typeKey = 'A_PL_0_';
        break;
      case 'album':
        typeKey = 'R_AL_3_';
        break;
      case 'dj':
        typeKey = 'A_DJ_1_';
        break;
      case 'video':
        typeKey = 'R_VI_62_';
        break;
      case 'event':
        typeKey = 'A_EV_2_';
        break;
    }
    return typeKey;
  }
  DioMetaData floorCommentsDioMetaData(String id, String type, String parentCommentId, {int time = -1, int limit = 20}) {
    var params = {'parentCommentId': parentCommentId, 'threadId': _type2key(type) + id, 'time': time, 'limit': limit};
    return DioMetaData(joinUri('/api/resource/comment/floor/get'), data: params, options: joinOptions());
  }
}

class TalkItem {
  String title;
  int type;

  TalkItem(this.title, this.type);
}