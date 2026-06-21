import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:flutter/material.dart';

/// 歌单歌曲列表加载中的骨架占位。
class PlaylistSkeletonSliver extends StatelessWidget {
  /// 创建歌单歌曲骨架列表。
  const PlaylistSkeletonSliver({
    super.key,
    required this.foregroundColor,
  });

  /// 用于计算占位颜色的前景色。
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final color = foregroundColor.withValues(alpha: 0.12);
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final thumbnailSize = (44 * textScale).clamp(40.0, 52.0);
            final verticalPadding = (6 * textScale).clamp(6.0, 10.0);
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox.square(
                      dimension: thumbnailSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FractionallySizedBox(
                            widthFactor: 0.55,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: 8,
        ),
      ),
    );
  }
}

/// 歌单歌曲列表底部的加载或失败状态提示。
class PlaylistStatusFooterSliver extends StatelessWidget {
  /// 创建歌单底部状态提示。
  const PlaylistStatusFooterSliver({
    super.key,
    required this.message,
    required this.foregroundColor,
  });

  /// 状态文案。
  final String message;

  /// 文案前景色。
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
        ),
        child: Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.7),
                ),
          ),
        ),
      ),
    );
  }
}
