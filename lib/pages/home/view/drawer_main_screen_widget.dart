
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/router.gr.dart';

class DrawerMainScreenView extends GetView<HomePageController> {
  const DrawerMainScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      height: context.height,
      child: Obx(() => AutoTabsRouter.pageView(
          routes: const [
            RouteOne(),
            RouteTwo(),
            SettingRouteView(),
            CoffeeRoute(),
          ],
          physics: controller.isDrawerClosed.value
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(),
          scrollDirection: Axis.vertical,
          animatePageTransition: true,
          builder: (context, child, pageController) {
            if (!controller.isHomePageControllerInited) {
              controller.initHomePageController(pageController);
            }
            return child;
          },
        )),
    );
  }
}


