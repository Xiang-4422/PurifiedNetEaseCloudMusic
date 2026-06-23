import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/pages/user/widgets/quick_start_card_rail.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 个人页“马上开始”区域。
class QuickStartSection extends StatelessWidget {
  /// 创建“马上开始”区域。
  const QuickStartSection({
    super.key,
    required this.itemCountInScreen,
    required this.recommendationController,
    required this.libraryController,
    required this.playbackAction,
    required this.shellController,
  });

  /// 横向区域中一屏展示的快速入口卡片数量。
  final double itemCountInScreen;

  /// 首页推荐控制器。
  final RecommendationController recommendationController;

  /// 用户资料库控制器。
  final UserLibraryController libraryController;

  /// 播放控制器。
  final PlayerController playbackAction;

  /// Shell 控制器。
  final ShellController shellController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Header(
          '马上开始',
          padding: AppDimensions.paddingSmall,
        ).marginOnly(top: AppDimensions.paddingSmall),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final userItemWidth = (constraints.maxWidth - AppDimensions.paddingSmall * itemCountInScreen.ceil()) / itemCountInScreen;
            final cardHeight = userItemWidth * 1.3;
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              height: cardHeight,
              child: QuickStartCardRail(
                width: userItemWidth,
                height: cardHeight,
                recommendationController: recommendationController,
                libraryController: libraryController,
                playbackAction: playbackAction,
                shellController: shellController,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 方屏个人页中的“马上开始”首页。
class SquareQuickStartPage extends StatelessWidget {
  /// 创建方屏“马上开始”首页。
  const SquareQuickStartPage({
    super.key,
    required this.metrics,
    required this.recommendationController,
    required this.libraryController,
    required this.playbackAction,
    required this.shellController,
  });

  /// 方屏布局尺寸参数。
  final PersonalHomeLayoutMetrics metrics;

  /// 首页推荐控制器。
  final RecommendationController recommendationController;

  /// 用户资料库控制器。
  final UserLibraryController libraryController;

  /// 播放控制器。
  final PlayerController playbackAction;

  /// Shell 控制器。
  final ShellController shellController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentHeight = constraints.maxHeight - metrics.squareHeaderHeight - AppDimensions.paddingSmall * 2;
          final cardSize = metrics.squareQuickCardSize(
            maxWidth: constraints.maxWidth,
            maxHeight: contentHeight,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                '马上开始',
                padding: AppDimensions.paddingSmall,
                height: metrics.squareHeaderHeight,
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: cardSize.height,
                    child: QuickStartCardRail(
                      width: cardSize.width,
                      height: cardSize.height,
                      recommendationController: recommendationController,
                      libraryController: libraryController,
                      playbackAction: playbackAction,
                      shellController: shellController,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
