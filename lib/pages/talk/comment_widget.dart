import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/netease_api/src/netease_api.dart';
import 'package:bujuan/widget/custom_filed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../common/constants/appConstants.dart';
import '../../common/netease_api/src/api/event/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';
import '../../widget/request_widget/request_loadmore_view.dart';
import '../../widget/simple_extended_image.dart';
import '../../controllers/app_controller.dart';

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
              return _buildItem(comments[index - 1]);
            }
          },
          itemCount: comments.length,
        ),
      );
  }

  Widget _buildItem(CommentItem comment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
            ]
          ),
          // 评论内容
          Text(
            (comment.content ?? '').replaceAll('\n', ''),
            style: TextStyle(
                color: stringColor.withOpacity(0.6),
                fontSize: 20
            ),
          ),
          // 该评论的回复
          Visibility(
              visible: (comment.replyCount ?? 0) > 0,
              child: GestureDetector(
                onTap: () {
                },
                child: Container(
                  alignment: FractionalOffset.centerRight,
                  child: Text(
                      '—— ${comment.replyCount}条回复 >',
                      style: TextStyle(
                        fontSize: 15,
                        color: stringColor.withOpacity(0.4),
                      )
                  ),
                ),
              )
          ),
        ],
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // 当前评论
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
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
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                      Expanded(
                          child: RichText(
                              text: TextSpan(text: widget.commentItem.user.nickname ?? '', style: TextStyle(fontSize: 28, color: Theme.of(context).cardColor), children: [
                                TextSpan(
                                  text: ' (${OtherUtils.formatDate2Str(widget.commentItem.time ?? 0)}) ',
                                  style: TextStyle(fontSize: 22, color: Colors.grey),
                                )
                              ]))),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 80),
                    child: Text(
                      (widget.commentItem.content ?? '').replaceAll('\n', ''),
                      style: TextStyle(fontSize: 24),
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
                Padding(padding: EdgeInsets.only(left: 20)),
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
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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
              Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
              Expanded(
                  child: RichText(
                      text: TextSpan(text: comment.user.nickname ?? '', style: TextStyle(fontSize: 28, color: Theme.of(context).cardColor), children: [
                TextSpan(
                  text: ' (${OtherUtils.formatDate2Str(comment.time ?? 0)}) ',
                  style: TextStyle(fontSize: 22, color: Colors.grey),
                )
              ]))),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, left: 80),
            child: Text(
              (comment.content ?? '').replaceAll('\n', ''),
              style: TextStyle(fontSize: 24),
            ),
          ),
          Visibility(
              visible: (comment.replyCount ?? 0) > 0,
              child: GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left: 60),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Text('—— ${comment.replyCount}条回复 >', style: TextStyle(fontSize: 24, color: Colors.blue)),
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