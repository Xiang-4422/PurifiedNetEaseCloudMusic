import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/constants/colors.dart';
import '../../../widget/simple_extended_image.dart';
import 'package:rive/rive.dart';

import '../../user/personal_page_controller.dart';

class MenuView extends GetView<HomePageController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 头像
          Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                child: ListView.builder(
              itemCount: controller.leftMenus.length,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (_, index) => Container(
                padding: EdgeInsets.zero,
                child: IconButton(
                  onPressed: () {
                    controller.zoomDrawerController.close!();
                    Future.delayed(const Duration(milliseconds: 200), () {
                      int onePageAnimationTime = 100;
                      Duration animationTime = Duration(milliseconds: onePageAnimationTime  * (controller.pageViewController.page! - index).abs().toInt());
                      controller.pageViewController.animateToPage(index, duration: animationTime, curve:Curves.linear);

                    });
                  },
                  icon: Obx(() => Container(
                    child: Icon(
                        controller.leftMenus[index].icon,
                        size: 52.sp,
                        color: controller.curPageIndex.value == index
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).iconTheme.color),
                  )),
                ),
              ),
            ),
          )
          ),
          //  菜单
        ],
      ),
    );
  }
}
