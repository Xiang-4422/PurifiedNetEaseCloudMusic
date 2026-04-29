import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_list_controller.dart';
import 'package:bujuan/features/comment/presentation/comment_item_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// CommentWidget。
class CommentWidget extends StatefulWidget {
  /// 创建 CommentWidget。
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

  /// context。
  final BuildContext context;

  /// commentType。
  final int commentType;

  /// id。
  final String id;

  /// idType。
  final String idType;

  /// listPaddingTop。
  final double listPaddingTop;

  /// listPaddingBottom。
  final double listPaddingBottom;

  /// stringColor。
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
    _controller = Get.find<FeatureControllerFactory>().commentList(
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
