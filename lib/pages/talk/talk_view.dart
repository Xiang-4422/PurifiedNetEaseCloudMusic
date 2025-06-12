import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/netease_api/src/netease_api.dart';
import 'package:bujuan/widget/custom_filed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../common/appConstants.dart';
import '../../common/netease_api/src/api/event/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../common/netease_api/src/netease_handler.dart';
import '../../widget/request_widget/request_loadmore_view.dart';
import '../../widget/simple_extended_image.dart';
import '../home/home_page_controller.dart';

class TalkView extends GetView<HomePageController>{
  final TextEditingController _textEditingController = TextEditingController();

  late String id;
  late String type;
  final List<TalkItem> _tabs = [
    TalkItem('热门', 2),
    TalkItem('最新', 3),
  ];
  late bool isPage = false;

  TalkView({Key? key, this.id = "", this.type = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(id.isEmpty) {
      isPage = true;
      id = context.routeData.queryParams.getString('id');
      type = context.routeData.queryParams.getString('type');
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            height: isPage ? AppDimensions.appBarHeight + context.mediaQueryPadding.top : 0,
          ),
          Expanded(
            child: TabBarView(
                controller: controller.panelCommentTabController,
                children: _tabs.map((talkItem) {
                  return ListWidget(id: id, idType: type, commentType: talkItem.type, context: context,);
                }).toList()
            ),
          ),
        ],
      ),
      // bottomSheet: Row(
      //   children: [
      //     Padding(padding: EdgeInsets.only(left: 20.w)),
      //     Expanded(
      //         child: CustomFiled(
      //           iconData: TablerIcons.message_2,
      //           textEditingController: _textEditingController,
      //           hitText: '请输入想说的话',
      //         )
      //     ),
      //     IconButton(onPressed: () => _sendMessage(context), icon: const Icon(TablerIcons.brand_telegram))
      //   ],
      // ),
    );
  }

  _sendMessage(BuildContext context) async {
    if (_textEditingController.text.isEmpty) {
      WidgetUtil.showToast('请输入评论');
      return;
    }
    CommentWrap commentWrap = await NeteaseMusicApi().comment(id, type, 'add', content: _textEditingController.text);
    if (commentWrap.code == 200) {
      _textEditingController.text = '';
      if(context.mounted) Focus.of(context).unfocus();
      WidgetUtil.showToast('评论成功');
    } else {
      WidgetUtil.showToast(commentWrap.message ?? '评论失败');
    }
  }

}

class ListWidget extends StatelessWidget {
  final int commentType; // 热门、最新
  final String id;  // 歌曲或歌单ID
  final String idType;  // 歌曲、歌单
  final BuildContext context;

  ListWidget({Key? key, required this.id, required this.idType, required this.commentType, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: context.width * (1 - AppDimensions.albumMaxWidth) / 2),
        child: RequestLoadMoreWidget<CommentList2Wrap, CommentItem>(
          listKey: const ['data', 'comments'],
          isPageNmu: true,
          lastField: 'cursor',
          pageSize: 20,
          dioMetaData: commentListDioMetaData2(id, idType, sortType: commentType),
          childBuilder: (List<CommentItem> comments) => ListView.builder(
            itemBuilder: (BuildContext context, int index) => _buildItem(comments[index]),
            itemCount: comments.length,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(CommentItem comment) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 头像
              SimpleExtendedImage.avatar(
                '${comment.user.avatarUrl ?? ''}?param=150y150',
                width: 60.w,
                height: 60.w,
              ).paddingOnly(right: 10),
              Expanded(
                  child: RichText(
                      text: TextSpan(
                          text: comment.user.nickname ?? '',
                          style: TextStyle(
                              fontSize: 28.sp,
                              color: Theme.of(context).cardColor),
                          children: [
                            TextSpan(
                              text: '\n${OtherUtils.formatDate2Str(comment.time ?? 0)}',
                              style: TextStyle(fontSize: 22.sp, color: Colors.grey),
                        )
                      ]
                      )
                  )
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.w, left: 80.w),
            child: Text(
              (comment.content ?? '').replaceAll('\n', ''),
              style: TextStyle(fontSize: 24.sp),
            ),
          ),
          Visibility(
              visible: (comment.replyCount ?? 0) > 0,
              child: GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left: 60.w),
                  padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 20.w),
                  child: Text('${comment.replyCount}条回复 >', style: TextStyle(fontSize: 24.sp, color: Colors.blue)),
                ),
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context1) => FoolTalk(
                      commentItem: comment,
                      id: context.routeData.queryParams.getString('id'),
                      type: context.routeData.queryParams.getString('type'),
                    ),
                  );
                },
              ))
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
}

class FoolTalk extends StatefulWidget {
  final CommentItem commentItem;
  final String id;
  final String type;

  const FoolTalk({Key? key, required this.commentItem, required this.id, required this.type}) : super(key: key);

  @override
  State<FoolTalk> createState() => _FoolTalkState();
}
class _FoolTalkState extends State<FoolTalk> {
  final TextEditingController _textEditingController= TextEditingController();
  DioMetaData floorCommentsDioMetaData(String id, String type, String parentCommentId, {int time = -1, int limit = 20}) {
    var params = {'parentCommentId': parentCommentId, 'threadId': _type2key(type) + id, 'time': time, 'limit': limit};
    return DioMetaData(joinUri('/api/resource/comment/floor/get'), data: params, options: joinOptions());
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

  @override
  void initState() {
    super.initState();
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
        color: Theme.of(context).scaffoldBackgroundColor,
        height: context.height/1.3,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 20.w),
              color: Theme.of(context).colorScheme.onSecondary,
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SimpleExtendedImage.avatar(
                        '${widget.commentItem.user.avatarUrl ?? ''}?param=150y150',
                        width: 60.w,
                        height: 60.w,
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8.w)),
                      Expanded(
                          child: RichText(
                              text: TextSpan(text: widget.commentItem.user.nickname ?? '', style: TextStyle(fontSize: 28.sp, color: Theme.of(context).cardColor), children: [
                                TextSpan(
                                  text: ' (${OtherUtils.formatDate2Str(widget.commentItem.time ?? 0)}) ',
                                  style: TextStyle(fontSize: 22.sp, color: Colors.grey),
                                )
                              ]))),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.w, left: 80.w),
                    child: Text(
                      (widget.commentItem.content ?? '').replaceAll('\n', ''),
                      style: TextStyle(fontSize: 24.sp),
                    ),
                  )
                ],
              ),
            ),
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
            Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 20.w)),
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
      padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SimpleExtendedImage.avatar(
                '${comment.user.avatarUrl ?? ''}?param=150y150',
                width: 60.w,
                height: 60.w,
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8.w)),
              Expanded(
                  child: RichText(
                      text: TextSpan(text: comment.user.nickname ?? '', style: TextStyle(fontSize: 28.sp, color: Theme.of(context).cardColor), children: [
                TextSpan(
                  text: ' (${OtherUtils.formatDate2Str(comment.time ?? 0)}) ',
                  style: TextStyle(fontSize: 22.sp, color: Colors.grey),
                )
              ]))),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.w, left: 80.w),
            child: Text(
              (comment.content ?? '').replaceAll('\n', ''),
              style: TextStyle(fontSize: 24.sp),
            ),
          ),
          Visibility(
              visible: (comment.replyCount ?? 0) > 0,
              child: GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left: 60.w),
                  padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 20.w),
                  child: Text('${comment.replyCount}条回复 >', style: TextStyle(fontSize: 24.sp, color: Colors.blue)),
                ),
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => FoolTalk(
                      commentItem: comment,
                      id: context.routeData.queryParams.getString('id'),
                      type: context.routeData.queryParams.getString('type'),
                    ),
                  );
                },
              ))
        ],
      ),
    );
  }
}

class TalkItem {
  String title;
  int type;

  TalkItem(this.title, this.type);
}