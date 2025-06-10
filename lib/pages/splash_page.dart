import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import '../common/constants/key.dart';
import '../routes/router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {

  Duration splashPageShowTime = const Duration(milliseconds: 1000);
  late String splashBg;

  @override
  void initState() {
    super.initState();

    splashBg = GetIt.instance<Box>().get(splashBackgroundSp, defaultValue: '');

    Brightness statusBarBrightness = Get.isPlatformDarkMode ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: statusBarBrightness,
      statusBarIconBrightness: statusBarBrightness,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(splashPageShowTime, () => AutoRouter.of(context).replaceNamed(Routes.home));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
        visible: splashBg.isEmpty,
        replacement: SimpleExtendedImage(
          splashBg,
          width: context.width,
          height: context.height,
          fit: BoxFit.cover,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/splash.svg',
            width: context.width / 1.8,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
