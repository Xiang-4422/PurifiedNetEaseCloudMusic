import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/radio/radio_controller_factory.dart';
import 'package:bujuan/features/radio/radio_detail_controller.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 电台节目分页列表的预渲染范围。
@visibleForTesting
const double radioProgramListCacheExtent = 480;

/// 播客详情页，展示节目列表并支持播放节目队列。
class RadioDetailsView extends StatefulWidget {
  /// 创建播客详情页。
  const RadioDetailsView({Key? key}) : super(key: key);

  @override
  State<RadioDetailsView> createState() => _RadioDetailsViewState();
}

class _RadioDetailsViewState extends State<RadioDetailsView> {
  late final String _radioId;
  late final String _radioName;
  late final RadioDetailController _controller;
  final PlayerController _playerController = Get.find<PlayerController>();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _radioId = context.routeData.queryParams.get('radioId');
    _radioName = context.routeData.queryParams.get('radioName');
    _controller = Get.find<RadioControllerFactory>().createDetail(radioId: _radioId)..loadInitial();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_radioName),
        backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder<PagedState<RadioProgramData>>(
        valueListenable: _controller.state,
        builder: (context, state, child) {
          if (state.initialLoading) {
            return const LoadingView();
          }
          if (state.hasInitialError) {
            return ErrorView(
              onRetry: () => unawaited(_controller.loadInitial()),
            );
          }
          if (state.isEmpty) {
            return const EmptyView();
          }
          final queueItems = _controller.queueItems;
          return AppSmartRefresher(
            controller: _refreshController,
            enablePullUp: state.hasMore,
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
              cacheExtent: radioProgramListCacheExtent,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return SongItem(
                  index: index,
                  playlist: queueItems,
                  playListName: _radioName,
                  onPlay: _playerController.playPlaylist,
                );
              },
              itemCount: state.items.length,
            ),
          );
        },
      ),
    );
  }
}
