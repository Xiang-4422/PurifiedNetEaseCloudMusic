import 'package:auto_route/auto_route.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/domain/entities/radio_data.dart';
import 'package:bujuan/features/radio/radio_detail_controller.dart';
import 'package:bujuan/features/radio/radio_playback_queue_item_mapper.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RadioDetailsView extends StatefulWidget {
  const RadioDetailsView({Key? key}) : super(key: key);

  @override
  State<RadioDetailsView> createState() => _RadioDetailsViewState();
}

class _RadioDetailsViewState extends State<RadioDetailsView> {
  RadioRepository get _repository => Get.find<RadioRepository>();
  late final String _radioId;
  late final String _radioName;
  late final RadioDetailController _controller;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _radioId = context.routeData.queryParams.get('radioId');
    _radioName = context.routeData.queryParams.get('radioName');
    _controller = RadioDetailController(
      repository: _repository,
      radioId: _radioId,
      userId: UserSessionController.to.userInfo.value.userId,
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
            return const ErrorView();
          }
          if (state.isEmpty) {
            return const EmptyView();
          }
          final queueItems = RadioPlaybackQueueItemMapper.fromPrograms(
            state.items,
            likedSongIds: UserLibraryController.to.likedSongIds.toList(),
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
              itemBuilder: (context, index) {
                return SongItem(
                  index: index,
                  playlist: queueItems,
                  playListName: _radioName,
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
