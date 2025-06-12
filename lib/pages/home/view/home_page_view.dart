import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/appConstants.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
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
    return Stack(
      children: [
        _buildBody(context),
        _buildAppBar(context),
      ],
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

  final double appBarHeight = 60;

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: context.height,
      alignment: Alignment.topCenter,
      child: Obx(() => BlurryContainer(
          height: appBarHeight + context.mediaQueryPadding.top,
          padding: EdgeInsets.only(
            top: context.mediaQueryPadding.top,
            left: 0, right: 0, bottom: 0,
          ),
          blur: controller.panelFullyOpened.value
              ? controller.isAlbumVisible.value
                ? 0
                : 5
              : 20,
          borderRadius: BorderRadius.circular(0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: false,
                child: Expanded(
                    flex: 1,
                    child: Container(
                    )
                ),
              ),
              Expanded(
                flex: 2,
                child: Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    // 旧widget出场和新widget入场动画都在这里构建
                    // 判断当前标题是旧标题还是新标题
                    bool isOldWidgetAnimation = animation.status == AnimationStatus.completed;
                    bool isReversing = animation.status == AnimationStatus.reverse;

                    // 入场和出场的动画
                    switch(controller.comingDirection) {
                      case NewAppBarTitleComingDirection.up:
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: isOldWidgetAnimation || isReversing
                                ? Offset(0, 1)   // 旧标题出场（beging和end反转）
                                : Offset(0, -1),  // 新标题入场
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: Tween<double>(
                              begin: isOldWidgetAnimation || isReversing
                                  ? 0   // 旧标题出场（beging和end反转）
                                  : 1,  // 新标题入场
                              end: 1,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      case NewAppBarTitleComingDirection.down:
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: isOldWidgetAnimation || isReversing
                                ? Offset(0, -1)   // 旧标题出场（beging和end反转）
                                : Offset(0, 1),  // 新标题入场
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: Tween<double>(
                              begin: isOldWidgetAnimation || isReversing
                                  ? 0   // 旧标题出场（beging和end反转）
                                  : 1,  // 新标题入场
                              end: 1,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      case NewAppBarTitleComingDirection.left:
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: isOldWidgetAnimation || isReversing
                                ? Offset(1 , 0)   // 旧标题出场（beging和end反转）
                                : Offset(-1 , 0),  // 新标题入场
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: Tween<double>(
                              begin: isOldWidgetAnimation || isReversing
                                  ? 0   // 旧标题出场（beging和end反转）
                                  : 1,  // 新标题入场
                              end: 1,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      case NewAppBarTitleComingDirection.right:
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: isOldWidgetAnimation || isReversing
                                ? Offset(-1 , 0)   // 旧标题出场（beging和end反转）
                                : Offset(1, 0),  // 新标题入场
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: Tween<double>(
                              begin: isOldWidgetAnimation || isReversing
                                  ? 0   // 旧标题出场（beging和end反转）
                                  : 1,  // 新标题入场
                              end: 1,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                    }
                  },
                  child: Container(
                      key: ValueKey<String>(controller.curPageTitle.value), // 添加 key
                      width: MediaQuery.of(context).size.width,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            //  标题（当前页/歌名）
                              text: '${controller.curPageTitle.value}',
                              style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.bold, color: Colors.black),
                              children: [
                                TextSpan(
                                  // 副标题（歌手名）
                                    text: '${controller.curPageSubTitle.value}',
                                    style: TextStyle(fontSize: 21.sp, color: Colors.black.withOpacity(0.5), )
                                ),
                              ]
                          ),
                        ),
                      )
                  ),
                )),
              ),
              Visibility(
                visible: false,
                child: Expanded(
                    flex: 1,
                    child: Container(
                    )
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

  Widget _buildBody (BuildContext context) {
    return SlidingUpPanel(
      controller: controller.panelController,
      color: Colors.transparent,
      onPanelSlide: (value) => controller.changeSlidePosition(value),
      // boxShadow: const [BoxShadow(blurRadius: 8.0, color: Color.fromRGBO(0, 0, 0, 0.05))],
      boxShadow: null,
      minHeight: AppDimensions.bottomPanelHeaderHeight + context.mediaQueryPadding.bottom,
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
          height: context.height,
          child: const DrawerMainScreenView(),
          // child: BodyView(),
        ),
      ),
      header: _buildHeader(context),
      panel: const PanelView(),
    );
  }

  /// 底部播放状态栏
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: context.width,
      child: AnimatedBuilder(
        animation: controller.panelAnimationController,
        builder: (context, child) {
          return GestureDetector(
            onTap: controller.panelFullyOpened.value
                ? () => controller.isAlbumVisible.value = !controller.isAlbumVisible.value
                : () => controller.panelController.open(),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                _buildAlbum(context),
                _buildMediaTitle(context),
              ],
            ),
          );
        },
      ),
    );
  }
  /// 播放状态栏——歌曲标题和播放按钮
  Widget _buildMediaTitle(BuildContext context) {
    return Obx(() => Visibility(
        visible: controller.panelFullyClosed.value,
        child: Row(
          children: [
            Container(
              width: AppDimensions.bottomPanelHeaderHeight,
            ),
            Expanded(
              child: Swipeable(
                background: const SizedBox.shrink(),
                onSwipeLeft: () => controller.audioServeHandler.skipToPrevious(),
                onSwipeRight: () => controller.audioServeHandler.skipToNext(),
                child: Container(
                  height: AppDimensions.bottomPanelHeaderHeight,
                  alignment: Alignment.centerLeft,
                  child: Obx(() => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${HomePageController.to.curMediaItem.value.title}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 42.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '${HomePageController.to.curMediaItem.value.artist ?? ''}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 21.sp,
                            color: Colors.black.withOpacity(0.5)
                        ),
                      ),
                    ],
                  )
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: AppDimensions.bottomPanelHeaderHeight,
              height: AppDimensions.bottomPanelHeaderHeight,
              child: IconButton(
                  onPressed: () => controller.playOrPause(),
                  icon: Obx(() => Icon(
                    controller.isPlaying.value ? TablerIcons.player_pause : TablerIcons.player_play,
                    color: Theme.of(context).cardColor.withOpacity(.7),
                    size: 65.sp,
                  ))),
            ),
          ],
        ),
      ),
    );
  }
  /// 播放状态栏——专辑图片
  Widget _buildAlbum(BuildContext context) {
    /// 完全展开宽度
    double panelAlbumMaxWidth = context.width * AppDimensions.albumMaxWidth;
    /// 完全展开LeftMargin
    double maxMarginLeft = (context.width - panelAlbumMaxWidth) / 2;

    // 实时Album宽度、margin
    double albumWidth = AppDimensions.albumMinWidth + (panelAlbumMaxWidth - AppDimensions.albumMinWidth) * controller.panelAnimationController.value;
    double albumPadding = AppDimensions.panelHeaderPadding +  (maxMarginLeft - AppDimensions.panelHeaderPadding) * controller.panelAnimationController.value;
    double appBarPadding = (context.mediaQueryPadding.top + 60) * controller.panelAnimationController.value;
    double albumBorderRadius = AppDimensions.albumMinWidth * (1 - controller.panelAnimationController.value);

    print('albumWidth: $albumWidth');
    return Obx(() => IgnorePointer(
        ignoring: !controller.isAlbumVisible.value,
        child: SizedBox(
          width: albumWidth + albumPadding * 2,
          height: albumWidth + albumPadding * 2 + appBarPadding,
          child: OverflowBox(
            maxWidth: (albumWidth + albumPadding * 2) * 3,
            child: Obx(() => PageView.builder(
              // key: ValueKey<List>(controller.curPlayList),
              controller: controller.albumPageController,
              itemCount: controller.curPlayList.length,
              physics: controller.panelFullyClosed.value ? NeverScrollableScrollPhysics() : PageScrollPhysics(),
              onPageChanged: (index) async {
                if (index != controller.curPlayIndex.value) {
                  index > controller.curPlayIndex.value
                      ? await controller.audioServeHandler.skipToNext()
                      : await controller.audioServeHandler.skipToPrevious();
                }
              },
              itemBuilder: (BuildContext context, int index) {
                return Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Visibility(
                    visible: controller.isAlbumVisible.value
                        ? controller.panelFullyOpened.value
                          ? true
                          : index == controller.curPlayIndex.value
                        : controller.panelFullyClosed.value && index == controller.curPlayIndex.value,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: albumPadding,
                        right: albumPadding,
                        top: appBarPadding + albumPadding,
                        bottom: albumPadding,
                      ),
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(albumBorderRadius),
                          boxShadow: [
                            controller.panelFullyOpened.value
                                ? BoxShadow(
                                  color: Colors.black.withOpacity(0.4), // 阴影颜色
                                  blurRadius: 12, // 模糊半径
                                  spreadRadius: 2, // 扩散半径
                                )
                                : const BoxShadow()
                          ],
                        ),
                        child: Obx(() => SimpleExtendedImage(
                          '${controller.curPlayList.value[index].extras?['image'] ?? ''}?param=500y500',
                        )),
                      ),
                    ),
                  ),
                ),
                );
              },
            ),
            ),
          ),
        ),
      ),
    );
  }

}
