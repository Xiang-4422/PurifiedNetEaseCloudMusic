import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/home/bottom_panel/bottom_panel_view.dart';
import 'package:bujuan/widget/swipeable.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';



import '../../common/constants/other.dart';
import '../talk/custom_filed.dart';
import '../../widget/custom_zoom_drawer/src/flutter_zoom_drawer.dart';
import '../../widget/simple_extended_image.dart';
import 'top_panel/top_panel_view.dart';

class AppRootPageView extends GetView<AppController>{
  const AppRootPageView({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.buildContext = context;
     return Material(
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) => controller.onWillPop(),
          child: SlidingUpPanel(
            slideDirection: SlideDirection.DOWN,
            controller: controller.topPanelController,
            onPanelSlide: (openDegree) => controller.onTopPanelSlide(openDegree),
            color: Colors.transparent,
            // parallaxEnabled: true,
            // parallaxOffset: 1,
            maxHeight: context.height,
            minHeight: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
            boxShadow: null,
            // collapsed: const TopPanelHeaderAppBar(),
            footer: Obx(() => Visibility(visible: controller.topPanelFullyClosed.isTrue,child: const TopPanelHeaderAppBar())),
            panel: const TopPanelView(),
            body: SlidingUpPanel(
              controller: controller.bottomPanelController,
              onPanelSlide: (openDegree) => controller.onBottomPanelSlide(openDegree),
              color: Colors.transparent,
              boxShadow: null,
              // parallaxEnabled: true,
              // parallaxOffset: 1,
              minHeight: AppDimensions.bottomPanelHeaderHeight + context.mediaQueryPadding.bottom,
              maxHeight: context.height,
              header: const BottomPanelHeaderView(),
              panel: const BottomPanelView(),
              body: const AutoRouter(),
            ),
          ),
        ),
      );
  }
}

