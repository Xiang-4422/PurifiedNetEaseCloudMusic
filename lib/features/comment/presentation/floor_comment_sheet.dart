import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/app/ui/toast_service.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/core/time/date_time_formatter.dart';
import 'package:bujuan/domain/entities/comment_data.dart';
import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:bujuan/features/comment/presentation/custom_field.dart';
import 'package:bujuan/features/comment/reply_sheet_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 楼层回复弹层页面。
class FoolTalk extends StatefulWidget {
  /// 创建楼层回复弹层。
  const FoolTalk({
    super.key,
    required this.commentItem,
    required this.id,
    required this.type,
    required this.backGroundColor,
  });

  /// 父评论数据。
  final CommentData commentItem;

  /// 评论资源 id。
  final String id;

  /// 评论资源类型。
  final String type;

  /// 弹层背景颜色。
  final Color backGroundColor;

  @override
  State<FoolTalk> createState() => _FoolTalkState();
}

class _FoolTalkState extends State<FoolTalk> {
  final RefreshController _refreshController = RefreshController();
  late final FloorCommentController _controller;
  late final ReplySheetController _replySheetController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<FeatureControllerFactory>().floorComment(
      id: widget.id,
      type: widget.type,
      parentCommentId: widget.commentItem.commentId,
      pageSize: 20,
    )..loadInitial();
    _replySheetController = ReplySheetController(floorController: _controller);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    _replySheetController.dispose();
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
                        ArtworkPathResolver.resolveDisplayPath(
                          widget.commentItem.user.avatarUrl,
                        ),
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
                                    ' (${DateTimeFormatter.commentTime(widget.commentItem.time)}) ',
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
                    textEditingController:
                        _replySheetController.textEditingController,
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
                ArtworkPathResolver.resolveDisplayPath(comment.user.avatarUrl),
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
                        text:
                            ' (${DateTimeFormatter.commentTime(comment.time)}) ',
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
    final errorMessage = await _replySheetController.sendReply(
      commentId: widget.commentItem.commentId,
    );
    if (errorMessage == null) {
      ToastService.show('评论成功');
    } else {
      ToastService.show(errorMessage);
    }
  }
}

/// 回复弹层 tab 数据。
class TalkItem {
  /// 创建回复弹层 tab 数据。
  TalkItem(this.title, this.type);

  /// tab 标题。
  String title;

  /// tab 对应评论类型。
  int type;
}
