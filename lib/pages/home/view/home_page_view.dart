import 'dart:developer';
// import 'dart:ffi';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/colors.dart';
import 'package:bujuan/common/constants/platform_utils.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/home/view/drawer_main_screen_widget.dart';
import 'package:bujuan/pages/home/view/panel_view.dart';
import 'package:bujuan/widget/commen_widget/my_appbar_widget.dart';
import 'package:bujuan/widget/swipeable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../../common/constants/other.dart';
import '../../../routes/router.dart';
import '../../../widget/custom_zoom_drawer/src/flutter_zoom_drawer.dart';
import '../../../widget/simple_extended_image.dart';
import '../../../widget/weslide/panel.dart';
import '../../user/personal_page_controller.dart';
import 'menu_view.dart';

/// 首页
class HomePageView extends GetView<HomePageController>{
  const HomePageView({
    Key? key,
    this.body,
  }) : super(key: key);

  final Widget? body;
  /// 0-1，占据屏幕的比例
  final double _manuPanelWidth = 0.2;

  @override
  Widget build(BuildContext context) {
    controller.buildContext = context;
    return Material(
        child: ScreenUtil().orientation == Orientation.portrait
              // 竖屏
              ? _buildPortraitApp(context)
              // 横屏
              : OtherUtils.isPad()
                  ? _buildBigLandApp(context)
                  : _buildSmallLandApp(context)
      );
  }

  Widget _buildPortraitApp(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return MyAppBar(
      leadingWidget: Obx(() => AnimatedSwitcher(
        duration: Duration(milliseconds: 100),
        transitionBuilder:  (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Visibility (
          key: ValueKey(!controller.panelOpened50.value && (controller.curPageIndex.value == 0 || !controller.isDrawerClosed.value)),
          visible: !controller.panelOpened50.value && (controller.curPageIndex.value == 0 || !controller.isDrawerClosed.value),
          child: IconButton(
            icon: Obx(() => SimpleExtendedImage.avatar(
              '${controller.userData.value.profile?.avatarUrl ?? ''}?param=300y300',
              shape: BoxShape.circle,
              width: 50,
            ),),
            onPressed: () {
              if (controller.loginStatus.value == LoginStatus.noLogin) {
                context.router.pushNamed(Routes.login);
                return;
              }
              controller.zoomDrawerController.close!();
              Future.delayed(const Duration(milliseconds: 200), () {
                context.router.pushNamed(Routes.userSetting);
              });
            },
          ),
        )
      ),),
      title: Obx(() => AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          log(animation.status.toString(), name: "XY4422", level: 4);
          // 判断当前标题是旧标题还是新标题
          bool isOldWidgetAnimation = animation.status == AnimationStatus.completed;
          bool isReversing = animation.status == AnimationStatus.reverse;

          bool isSlidingUp = !controller.panelOpened10.value
              ? controller.curPageIndex.value > controller.lastPageIndex.value
              : controller.panelOpened50.value;

          // 执行入场和出场的滑动动画
          return SlideTransition(
            position: Tween<Offset>(
              begin: isOldWidgetAnimation || isReversing
                  ? Offset(0, (isSlidingUp) ? -1.5 : 1.5)   // 旧标题出场（beging和end反转）
                  : Offset(0, (isSlidingUp) ? 1.5 : -1.5),  // 新标题入场
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: RichText(
          key: ValueKey<String>(controller.curTitle.value), // 添加 key
          text: TextSpan(
              style: TextStyle(fontSize: 42.sp, color: Colors.grey, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: '${controller.curTitle.value}',
                    style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(.9))),
              ]
          ),
        ),
      )),
    );
  }
  Widget _buildBody (BuildContext context) {
    return SlidingUpPanel(
      controller: controller.firstPanelController,
      color: Colors.transparent,
      // parallaxEnabled: true,
      // parallaxOffset: 1,
      onPanelSlide: (value) => controller.changeSlidePosition(value),
      boxShadow: const [BoxShadow(blurRadius: 8.0, color: Color.fromRGBO(0, 0, 0, 0.05))],
      minHeight: controller.panelMobileMinSize + MediaQuery.of(context).padding.bottom + controller.panelAlbumPadding * 2,
      maxHeight: context.height,
      body: ZoomDrawer(
        controller: controller.zoomDrawerController,
        // 侧边抽屉配置
        menuScreenTapClose: true,
        slideWidth: context.width * _manuPanelWidth,
        menuScreenWidth: context.width * _manuPanelWidth,
        menuBackgroundColor: Colors.transparent,

        // 主屏幕配置
        angle: 0,
        // mainScreenScale: _manuPanelWidth,
        mainScreenScale: 0,
        borderRadius: 0,

        mainScreenTapClose: true,
        mainScreenAbsorbPointer: false,
        clipMainScreen: true,

        openCurve: Curves.linear,
        closeCurve: Curves.linear,

        androidCloseOnBackTap: true,
        dragOffset: context.width * 0.5,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
        menuScreen: const MenuView(),
        mainScreen: SizedBox(
          width: context.width,
          // height: context.height / (1 - _manuPanelWidth),
          height: context.height,
          child: const DrawerMainScreenView(),
          // child: BodyView(),
        ),
      ),
      header: _buildHeader(context),
      panel: const PanelView(),
    );
  }


  Widget _buildBigLandApp(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Text("大屏横屏")
    );
  }

  Widget _buildSmallLandApp(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Text("小屏横屏")
    );
  }

  /// 底部播放状态栏
  Widget _buildHeader(context) {
    return AnimatedBuilder(
      animation: controller.firstPanelAnimationController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              // color: Colors.black,
              // alignment: Alignment.center,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top * controller.secondSlidePanelPosition.value),
              child: Obx(() => GestureDetector(
                onVerticalDragEnd: (controller.second.value) ? (e) {} : null,
                child: Swipeable(
                    background: const SizedBox.shrink(),
                    child: Container(
                      width: 750.w,
                      padding: EdgeInsets.all(controller.panelAlbumPadding),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          _buildMediaTitle(context),
                          _buildAlbum(context),
                        ],
                      ),
                    ),
                    onSwipeLeft: () => controller.audioServeHandler.skipToPrevious(),
                    onSwipeRight: () => controller.audioServeHandler.skipToNext()
                ),
              )),
            ),
          ],
        );
      },
    );
  }
  /// 播放状态栏——歌曲标题和播放按钮
  Widget _buildMediaTitle(context) {
    return Obx(() => Visibility(
          visible: !controller.panelOpened10.value,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 歌名-歌手
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: controller.panelMobileMinSize + controller.panelAlbumPadding),
                      alignment: Alignment.centerLeft,
                      height: controller.panelMobileMinSize,
                      child: Obx(
                        () => RichText(
                          text: TextSpan(
                              text: '${HomePageController.to.mediaItem.value.title} - ',
                              children: [TextSpan(text: HomePageController.to.mediaItem.value.artist ?? '', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500))],
                              style: TextStyle(
                                  fontSize: 32.sp,
                                  color: controller.second.value ? controller.bodyColor.value : controller.getLightTextColor(context),
                                  fontWeight: FontWeight.w500)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))),
              // 播放暂停按钮
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
  /// 播放状态栏——专辑图片
  Widget _buildAlbum(BuildContext context) {
    double albumWidth = controller.panelMobileMinSize + 550.w * controller.firstPanelAnimationController.value;
    double marginLeft = (750.w - 630.w - controller.panelAlbumPadding * 2) / 2 * controller.firstPanelAnimationController.value;
    double marginTop = (controller.panelTopSize + MediaQuery.of(context).padding.top - controller.panelAlbumPadding) * controller.firstPanelAnimationController.value;

    return AnimatedBuilder(
      animation: controller.firstPanelAnimationController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(left: marginLeft, top: marginTop,),
          width: albumWidth,
          height: albumWidth,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(controller.panelMobileMinSize / 2),
        child: Obx(() => SimpleExtendedImage(
              '${HomePageController.to.mediaItem.value.extras?['image'] ?? ''}?param=500y500',
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
