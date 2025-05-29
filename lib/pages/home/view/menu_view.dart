import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/root_controller.dart';
import 'package:bujuan/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/constants/colors.dart';
import '../../../widget/simple_extended_image.dart';
import 'package:rive/rive.dart';

import '../../user/user_controller.dart';

class MenuView extends GetView<RootController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top)),
          // 头像
          GestureDetector(
            child: Obx(() => SimpleExtendedImage.avatar(
                  '${controller.userData.value.profile?.avatarUrl ?? ''}?param=300y300',
                  width: 90.w,
                )),
            onTap: () {
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
          //  菜单
          Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context1, index) => Container(
                  padding: EdgeInsets.symmetric(vertical: 12.w),
                  child: IconButton(
                    onPressed: () {
                      controller.zoomDrawerController.close!();
                      Future.delayed(const Duration(milliseconds: 200), () {
                        int onePageAnimationTime = 100;
                        Duration animationTime = Duration(milliseconds: onePageAnimationTime  * (controller.pageViewController.page! - index).abs().toInt());
                        controller.pageViewController.animateToPage(index, duration: animationTime, curve:Curves.linear);

                      });
                    },
                    icon: Obx(() => Icon(
                        controller.leftMenus[index].icon,
                        size: 52.sp,
                        color: controller.pageIndex.value == index
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).iconTheme.color)),
                  ),
                ),
                itemCount: controller.leftMenus.length,
                        )),
        ],
          ),
    );
  }
}
