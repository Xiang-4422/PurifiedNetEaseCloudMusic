import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/home/view/drawer_main_screen_widget.dart';
import 'package:bujuan/pages/home/view/panel_view.dart';
import 'package:bujuan/widget/my_get_view.dart';
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
  const HomePageView({Key? key,}) : super(key: key);

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
    return MyGetView(
      child: Stack(
        children: [
          _buildBody(context),
          _buildAppBar(context),
        ],
      ),
    );
  }
  Widget _buildBigLandApp(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: const Text("大屏横屏")
    );
  }
  Widget _buildSmallLandApp(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: const Text("小屏横屏")
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
        mainScreenScale: 0,
        borderRadius: 0,
        mainScreenTapClose: true,
        mainScreenAbsorbPointer: false,
        clipMainScreen: true,

        // 动画配置
        openCurve: Curves.linear,
        closeCurve: Curves.linear,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
        androidCloseOnBackTap: true,
        dragOffset: context.width * 0.5,

        menuScreen: const MenuView(),
        mainScreen: const DrawerMainScreenView(),
      ),
      header: const PanelHeaderView(),
      panel: const PanelView(),
    );
  }
  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: context.width,
      height: context.height,
      alignment: Alignment.topCenter,
      child: BlurryContainer(
          width: context.width,
          height: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
          padding: EdgeInsets.only(top: context.mediaQueryPadding.top,),
          blur: controller.isInPlayListPage.value ? 0 : 20,
          borderRadius: BorderRadius.circular(0),
          child: Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
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
                          ? const Offset(0, 1)   // 旧标题出场（beging和end反转）
                          : const Offset(0, -1),  // 新标题入场
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
            child: FittedBox(
              key: ValueKey<String>(controller.curPageTitle.value), // 添加 key
              fit: BoxFit.scaleDown,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  //  标题（当前页/歌名）
                    text: controller.curPageTitle.value,
                    style: TextStyle(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.bold,
                        color: controller.panelOpened50.value ? Colors.white : Colors.black
                    ),
                    children: [
                      TextSpan(
                        // 副标题（歌手名）
                          text: controller.curPageSubTitle.value,
                          style: TextStyle(
                            fontSize: 21.sp,
                            color: (controller.panelOpened50.value ? Colors.white : Colors.black).withOpacity(0.5),
                          )
                      ),
                    ]
                ),
              ),
            ),
          ))
      ),
    );
  }
}
