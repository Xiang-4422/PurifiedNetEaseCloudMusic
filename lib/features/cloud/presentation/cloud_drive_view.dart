import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/cloud/cloud_page_controller.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/app_smart_refresher.dart';
import 'package:bujuan/widget/music_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 云盘歌曲列表页面，支持分页刷新和直接发起播放。
class CloudDriveView extends StatefulWidget {
  /// 创建云盘歌曲列表页面。
  const CloudDriveView({Key? key}) : super(key: key);

  @override
  State<CloudDriveView> createState() => _CloudDriveViewState();
}

class _CloudDriveViewState extends State<CloudDriveView> {
  late final CloudPageController _controller;
  final PlayerController _playerController = Get.find<PlayerController>();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _controller = CloudPageController(
      repository: Get.find<CloudRepository>(),
      userId: Get.find<UserSessionController>().userInfo.value.userId,
      likedSongIds: Get.find<UserLibraryController>().likedSongIds.toList(),
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
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top + AppDimensions.appBarHeight,
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
                  itemCount: state.items.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return SongItem(
                      index: index,
                      playlist: state.items,
                      playListName: "云盘音乐",
                      onPlay: _playerController.playPlaylist,
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
