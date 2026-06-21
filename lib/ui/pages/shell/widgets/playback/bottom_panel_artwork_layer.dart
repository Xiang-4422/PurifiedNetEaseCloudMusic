import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_artwork_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部面板从迷你封面到大封面的过渡层。
class BottomPanelArtworkTransitionLayer extends StatelessWidget {
  /// 创建封面过渡层。
  const BottomPanelArtworkTransitionLayer({
    required this.controller,
    super.key,
  });

  /// 壳层控制器，提供封面展开动画状态。
  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Offstage(
        offstage: controller.isAlbumScaleEnded.isTrue,
        child: Container(
          alignment: Alignment.topRight,
          child: Obx(
            () {
              final isBigAlbum = controller.isBigAlbum.isTrue;
              final size = isBigAlbum ? context.width - AppDimensions.paddingLarge * 2 : AppDimensions.albumMinSize;
              final borderRadius = isBigAlbum ? AppDimensions.paddingLarge / 2 : AppDimensions.albumMinSize;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: isBigAlbum
                    ? EdgeInsets.only(
                        right: AppDimensions.paddingLarge,
                        top: AppDimensions.appBarHeight + context.mediaQueryPadding.top + AppDimensions.paddingLarge,
                      )
                    : EdgeInsets.only(
                        right: AppDimensions.paddingLarge,
                        top: context.mediaQueryPadding.top + AppDimensions.paddingSmall,
                      ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                clipBehavior: Clip.hardEdge,
                width: size,
                height: size,
                child: BottomPanelCurrentArtworkImage(size: size),
                onEnd: () {
                  controller.isAlbumScaleEnded.value = true;
                  if (controller.isBigAlbum.isTrue) {
                    controller.syncAlbumPage(jump: true);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 底部面板大封面分页展示层。
class BottomPanelArtworkPageLayer extends StatefulWidget {
  /// 创建大封面分页展示层。
  const BottomPanelArtworkPageLayer({
    required this.controller,
    super.key,
  });

  /// 壳层控制器，提供专辑页控制器和面板状态。
  final ShellController controller;

  @override
  State<BottomPanelArtworkPageLayer> createState() => _BottomPanelArtworkPageLayerState();
}

class _BottomPanelArtworkPageLayerState extends State<BottomPanelArtworkPageLayer> {
  bool _wasVisible = false;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isVisible = widget.controller.bottomPanelFullyOpened.isTrue && widget.controller.isBigAlbum.isTrue && widget.controller.isAlbumScaleEnded.isTrue;
        if (isVisible && !_wasVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            widget.controller.syncAlbumPage(jump: true);
          });
        }
        _wasVisible = isVisible;
        return Offstage(
          offstage: !isVisible,
          child: Container(
            margin: EdgeInsets.only(
              top: context.mediaQueryPadding.top + AppDimensions.appBarHeight,
            ),
            height: context.width,
            child: BottomPanelArtworkPageViewport(
              controller: widget.controller,
            ),
          ),
        );
      },
    );
  }
}
