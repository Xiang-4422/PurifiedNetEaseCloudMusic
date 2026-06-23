import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:bujuan/ui/widgets/playlist/playlist_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

/// 推荐歌单吸顶标题。
class RecommendedPlaylistPinnedHeaderSliver extends StatelessWidget {
  /// 创建推荐歌单吸顶标题。
  const RecommendedPlaylistPinnedHeaderSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        final isPinned = constraints.scrollOffset > 0;
        return PinnedHeaderSliver(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: Theme.of(context).colorScheme.surface,
            padding: isPinned ? EdgeInsets.only(top: MediaQuery.paddingOf(context).top) : EdgeInsets.zero,
            child: const Header(
              '推荐歌单',
              padding: AppDimensions.paddingSmall,
            ),
          ),
        );
      },
    );
  }
}

/// 推荐歌单普通标题。
class RecommendedPlaylistHeaderSliver extends StatelessWidget {
  /// 创建推荐歌单普通标题。
  const RecommendedPlaylistHeaderSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Header(
        '推荐歌单',
        padding: AppDimensions.paddingSmall,
      ),
    );
  }
}

/// 推荐歌单列表。
class RecommendedPlaylistListSliver extends StatelessWidget {
  /// 创建推荐歌单列表。
  const RecommendedPlaylistListSliver({
    super.key,
    required this.controller,
  });

  /// 首页推荐控制器。
  final RecommendationController controller;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: controller.recoPlayLists.length,
      itemBuilder: (BuildContext context, int index) {
        return PlayListItem(
          controller.recoPlayLists[index],
        ).paddingSymmetric(horizontal: AppDimensions.paddingSmall);
      },
    );
  }
}
