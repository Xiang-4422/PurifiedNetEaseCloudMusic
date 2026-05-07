import 'package:auto_route/auto_route.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/features/radio/radio_list_controller.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/app/routing/router.gr.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 我的播客列表页。
class MyRadioView extends StatefulWidget {
  /// 创建我的播客列表页。
  const MyRadioView({Key? key}) : super(key: key);

  @override
  State<MyRadioView> createState() => _MyRadioViewState();
}

class _MyRadioViewState extends State<MyRadioView> {
  late final RadioListController _controller;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _controller = RadioListController(
      userId: Get.find<UserSessionController>().userInfo.value.userId,
      repository: Get.find<RadioRepository>(),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) => _buildItem(state.items[index]),
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
