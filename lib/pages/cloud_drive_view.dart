import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/features/cloud/cloud_page_controller.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../common/netease_api/src/api/play/bean.dart';

class CloudDriveView extends StatefulWidget {
  const CloudDriveView({Key? key}) : super(key: key);

  @override
  State<CloudDriveView> createState() => _CloudDriveViewState();
}

class _CloudDriveViewState extends State<CloudDriveView> {
  static final CloudRepository _repository = CloudRepository();
  late final CloudPageController _controller;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _controller = CloudPageController(repository: _repository)..loadInitial();
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
          child: ValueListenableBuilder<PagedState<CloudSongItem>>(
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
              final mediaItems = _repository.mapCloudSongs(
                state.items,
                likedSongIds: AppController.to.likedSongIds.toList(),
              );
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
                  itemCount: mediaItems.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    return SongItem(
                      index: index,
                      playlist: mediaItems,
                      playListName: "云盘音乐",
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
