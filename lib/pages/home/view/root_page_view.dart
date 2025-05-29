import 'dart:ui';

import 'package:bujuan/common/constants/platform_utils.dart';
import 'package:bujuan/pages/home/root_controller.dart';
import 'package:bujuan/pages/home/view/drawer_main_screen_widget.dart';
import 'package:bujuan/pages/home/view/panel_view.dart';
import 'package:bujuan/widget/swipeable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/constants/other.dart';
import '../../../widget/custom_zoom_drawer/src/flutter_zoom_drawer.dart';
import '../../../widget/simple_extended_image.dart';
import '../../../widget/weslide/panel.dart';
import 'menu_view.dart';

/// 首页
class RootPageView extends GetView<RootController>{
  final Widget? body;
  /// 0-1，占据屏幕的比例
  final double _manuPanelWidth = 0.2;

  const RootPageView({
    Key? key,
    this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.buildContext = context;
    double bottomSafeAreaHeight = MediaQuery.of(controller.buildContext).padding.bottom;
    return Material(
        child: ScreenUtil().orientation == Orientation.portrait
              // 竖屏设备
              ? SlidingUpPanel(
                body: ZoomDrawer(
                  menuScreen: const MenuView(),
                  mainScreen: SizedBox(
                    width: context.width,
                    height: context.height / (1 - _manuPanelWidth),
                      child: const DrawerMainScreenView(),
                    // child: BodyView(),
                  ),
                  controller: controller.zoomDrawerController,

                  // 侧边抽屉配置
                  menuScreenTapClose: true,
                  slideWidth: context.width * _manuPanelWidth,
                  menuScreenWidth: context.width * _manuPanelWidth,
                  menuBackgroundColor: const Color(0xFFDCDADA),

                  // 主屏幕配置
                  angle: 0,
                  mainScreenScale: _manuPanelWidth,
                  mainScreenTapClose: true,
                  mainScreenAbsorbPointer: false,
                  clipMainScreen: true,

                  openCurve: Curves.linear,
                  closeCurve: Curves.linear,

                  androidCloseOnBackTap: true,
                  dragOffset: context.width * 0.5,
                  duration: const Duration(milliseconds: 200),
                  reverseDuration: const Duration(milliseconds: 200),
                ),
                header: _buildHeader(context, bottomSafeAreaHeight),
                panel: const PanelView(),
                controller: controller.firstPanelController,
                color: Colors.black,
                // parallaxEnabled: true,
                // parallaxOffset: 1,
                onPanelSlide: (value) => controller.changeSlidePosition(value),
                boxShadow: const [BoxShadow(blurRadius: 8.0, color: Color.fromRGBO(0, 0, 0, 0.05))],
                minHeight: controller.panelMobileMinSize + bottomSafeAreaHeight + controller.panelAlbumPadding * 2,
                maxHeight: context.height,
              )
              : OtherUtils.isPad()
                  ? Container(
                      alignment: Alignment.center,
                      child: Text("大屏横屏")
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: Text("小屏横屏")
                    )
      );
  }

  /// 底部播放状态栏
  Widget _buildHeader(context, bottomHeight) {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // 展开前
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top * controller.secondSlidePanelPosition.value),
              child: Obx(() => GestureDetector(
                onVerticalDragEnd: (controller.second.value) ? (e) {} : null,
                child: Swipeable(
                    background: const SizedBox.shrink(),
                    child: InkWell(
                      child: Container(
                        width: 750.w,
                        padding: EdgeInsets.all(controller.panelAlbumPadding),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            _buildMediaTitle(context),
                            _buildAlbum(),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (controller.firstPanelController.isPanelClosed) {
                          controller.firstPanelController.open();
                        } else {
                          if (controller.secondPanelController.isPanelOpen) controller.secondPanelController.close();
                        }
                      },
                    ),
                    onSwipeLeft: () => controller.audioServeHandler.skipToPrevious(),
                    onSwipeRight: () => controller.audioServeHandler.skipToNext()),
              )),
            ),
            // 展开后
            Container(
              padding: EdgeInsets.symmetric(horizontal: controller.panelAlbumPadding),
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              height: controller.panelTopSize*controller.animationController.value,
              width: 750.w ,
              child:  Obx(() => Visibility(
                visible: !controller.second.value&&controller.panelOpenPositionThan1.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => controller.firstPanelController.close(),
                      icon: Obx(() => Icon(Icons.keyboard_arrow_down_sharp, color: controller.bodyColor.value)),),
                    Text('Now Playing',style: TextStyle(color: controller.bodyColor.value,fontSize: 28.sp),),
                    IconButton(onPressed: () {}, icon: Obx(() => Icon(Icons.more_horiz, color: controller.bodyColor.value))),
                  ],
                ),
              )),
            ),
          ],
        );
      },
    );
  }
  /// 构建歌曲标题和播放按钮
  Widget _buildMediaTitle(context) {
    return Obx(() => Visibility(
          visible: !controller.panelOpenPositionThan1.value,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: controller.panelMobileMinSize + controller.panelAlbumPadding),
                      alignment: Alignment.centerLeft,
                      height: controller.panelMobileMinSize,
                      child: Obx(
                        () => RichText(
                          text: TextSpan(
                              text: '${RootController.to.mediaItem.value.title} - ',
                              children: [TextSpan(text: RootController.to.mediaItem.value.artist ?? '', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500))],
                              style: TextStyle(
                                  fontSize: 32.sp,
                                  color: controller.second.value ? controller.bodyColor.value : controller.getLightTextColor(context),
                                  fontWeight: FontWeight.w500)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))),
              IconButton(
                  onPressed: () => controller.playOrPause(),
                  icon: Obx(() => Icon(
                        controller.isPlaying.value ? TablerIcons.player_pause : TablerIcons.player_play,
                        color: controller.second.value ? controller.bodyColor.value : controller.getLightTextColor(context),
                        size: 44.sp,
                      ))),
            ],
          ),
        ));
  }
  /// 构建歌曲专辑图片
  Widget _buildAlbum() {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (context, index) {
        return Container(
          margin: EdgeInsets.only(
              left: (750.w - 630.w - controller.panelAlbumPadding * 2) / 2 * controller.animationController.value,
              top: (controller.panelTopSize + MediaQuery.of(context).padding.top - controller.panelAlbumPadding) * controller.animationController.value),
          width: controller.panelMobileMinSize + 550.w * controller.animationController.value,
          height: controller.panelMobileMinSize + 550.w * controller.animationController.value,
          child: index,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(controller.panelMobileMinSize / 2),
        child: Obx(() => SimpleExtendedImage(
              '${RootController.to.mediaItem.value.extras?['image'] ?? ''}?param=500y500',
              width: 630.w,
              height: 630.w,
            )),
      ),
    );
  }
}

/// 左侧菜单栏bean
class LeftMenu {
  String title;
  IconData icon;
  String path;
  String pathUrl;

  LeftMenu(this.title, this.icon, this.path, this.pathUrl);
}
