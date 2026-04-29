import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/cloud/cloud_page_controller.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CloudDriveView extends StatefulWidget {
  const CloudDriveView({Key? key}) : super(key: key);

  @override
  State<CloudDriveView> createState() => _CloudDriveViewState();
}

class _CloudDriveViewState extends State<CloudDriveView> {
  late final CloudPageController _controller;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<FeatureControllerFactory>().cloudPage()
      ..loadInitial();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height:
              MediaQuery.of(context).padding.top + AppDimensions.appBarHeight,
        ),
        Expanded(
          child: ValueListenableBuilder<PagedState<PlaybackQueueItem>>(
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
                  itemCount: state.items.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    return SongItem(
                      index: index,
                      playlist: state.items,
                      playListName: "云盘音乐",
                      onPlay: PlayerController.to.playPlaylist,
                    );
                  },
                ),
              );
            },
          ),
        ),
        Container(
          height: AppDimensions.bottomPanelHeaderHeight,
        ),
      ],
    );
  }
}
