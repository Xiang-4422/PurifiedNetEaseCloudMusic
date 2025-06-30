import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/app_controller.dart';
import 'package:bujuan/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widget/simple_extended_image.dart';
import '../../user/personal_page_controller.dart';

class MenuView extends GetView<AppController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
              child: Container(
                alignment: Alignment.center,
                child: ListView.separated(
                  itemCount: controller.leftMenus.length + 1,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    if (index == controller.leftMenus.length / 2) {
                      return IconButton(
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
                      );
                    } else {
                      int menuIndex = index > controller.leftMenus.length / 2 ? index - 1 : index;
                      return IconButton(
                        onPressed: () {
                          controller.zoomDrawerController.close!();
                          Future.delayed(const Duration(milliseconds: 200), () {
                            int onePageAnimationTime = 200;
                            Duration animationTime = Duration(milliseconds: onePageAnimationTime  * (controller.homePageController!.page! - menuIndex).abs().toInt());
                            controller.homePageController.animateToPage(menuIndex, duration: animationTime, curve:Curves.linear);
                            // AutoTabsRouter.of(context).setActiveIndex(menuIndex);
                          });
                        },
                        icon: Obx(() => Icon(
                            controller.leftMenus[menuIndex].icon,
                            size: 52.sp,
                            color: controller.curHomePageIndex.value == menuIndex
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).iconTheme.color)),
                      );
                    }
                  }, separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 15,
                    );
                },
                ),
              )
          ),
          Container(
              height: MediaQuery.of(context).padding.top,
          )
        ],
      ),
    );
  }
}

/// 左侧菜单栏bean
class LeftMenuBean {
  String title;
  IconData icon;
  String path;
  String pathUrl;

  LeftMenuBean(this.title, this.icon, this.path, this.pathUrl);
}
