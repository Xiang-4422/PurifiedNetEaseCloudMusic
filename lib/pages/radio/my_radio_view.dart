import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/features/radio/radio_data.dart';
import 'package:bujuan/features/radio/radio_list_controller.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/routes/router.gr.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widget/simple_extended_image.dart';

class MyRadioView extends StatefulWidget {
  const MyRadioView({Key? key}) : super(key: key);

  @override
  State<MyRadioView> createState() => _MyRadioViewState();
}

class _MyRadioViewState extends State<MyRadioView> {
  final RadioRepository _repository = RadioRepository();
  late final RadioListController _controller;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _controller = RadioListController(repository: _repository)..loadInitial();
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
          height: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
        ),
        Expanded(
          child: ValueListenableBuilder<PagedState<RadioSummaryData>>(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) =>
                      _buildItem(state.items[index]),
                  itemCount: state.items.length,
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

  Widget _buildItem(RadioSummaryData data) {
    return InkWell(
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              SimpleExtendedImage(
                ArtworkPathResolver.resolveDisplayPath(data.coverUrl),
                width: 85,
                height: 85,
                borderRadius: BorderRadius.circular(10),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.name,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                    Text(
                      data.lastProgramName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 26, color: Colors.grey),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
        onTap: () {
          context.router.push(
            const RadioDetailsView().copyWith(
              queryParams: {
                'radioId': data.id,
                'radioName': data.name,
              },
            ),
          );
        });
  }
}
