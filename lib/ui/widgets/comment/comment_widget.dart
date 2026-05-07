import 'package:bujuan/core/network/load_state.dart' show PagedState;
import 'package:bujuan/domain/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_list_controller.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/ui/widgets/comment/comment_item_view.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 评论列表组件。
class CommentWidget extends StatefulWidget {
  /// 创建评论列表组件。
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

  /// 父级页面上下文。
  final BuildContext context;

  /// 评论排序类型。
  final int commentType;

  /// 评论资源 id。
  final String id;

  /// 评论资源类型。
  final String idType;

  /// 列表顶部占位高度。
  final double listPaddingTop;

  /// 列表底部占位高度。
  final double listPaddingBottom;

  /// 评论文本颜色。
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
      repository: Get.find<CommentRepository>(),
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
        return AppSmartRefresher(
          controller: _refreshController,
          enablePullUp: state.hasMore,
          footer: loadingFooter(
            idleWidget: SizedBox(height: widget.listPaddingBottom),
          ),
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
            padding: EdgeInsets.fromLTRB(0, widget.listPaddingTop, 0, 0),
            itemBuilder: (BuildContext context, int index) {
              return CommentItemWidget(
                id: widget.id,
                idType: widget.idType,
                comment: state.items[index],
                stringColor: widget.stringColor,
              ).marginOnly(top: index == 0 ? 0 : 10);
            },
            itemCount: state.items.length,
          ),
        );
      },
    );
  }
}
