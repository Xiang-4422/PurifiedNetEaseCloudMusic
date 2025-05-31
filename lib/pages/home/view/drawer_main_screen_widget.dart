
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/home/view/home_page_view.dart';
import 'package:bujuan/pages/setting/coffee.dart';
import 'package:bujuan/pages/setting/settring_view.dart';
import 'package:bujuan/pages/user/personal_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../common/constants/platform_utils.dart';
import '../../../widget/simple_extended_image.dart';
import '../../index/explore_page_view.dart';

class DrawerMainScreenView extends GetView<HomePageController> {
  const DrawerMainScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.buildContext = context;
    double bottomHeight = MediaQuery.of(controller.buildContext).padding.bottom * (PlatformUtils.isIOS ? 0.6 : .85);
    if (bottomHeight == 0 && PlatformUtils.isAndroid || PlatformUtils.isIOS) bottomHeight = 32.w;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Obx(()=>PageView(
          physics: controller.isDrawerClosed.value ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
          controller: controller.pageViewController,
          scrollDirection: Axis.vertical,
          children: [
            _buildPage(const PersonalPageView(), true, false),
            _buildPage(const ExplorePageView(), false, false),
            _buildPage(const SettingView(), false, false),
            _buildPage(const CoffeePage(), false, true),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Widget child, bool isTopRadius, bool isBottomRadius) {

    const double radius = 40.0;

    return AbsorbPointer(
        absorbing: !controller.isDrawerClosed.value,
        child: Container(
            clipBehavior: Clip.hardEdge,
            decoration:  BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular((isTopRadius ? radius : 0.0)), // 左上角圆角
                topRight: Radius.circular((isTopRadius ? radius : 0.0)), // 右上角圆角
                bottomLeft: Radius.circular((isBottomRadius ? radius : 0.0)), // 左下角圆角
                bottomRight: Radius.circular((isBottomRadius ? radius : 0.0)), // 右下角无圆角
              ),            ),
            child: child,
        )
    );
  }

}


