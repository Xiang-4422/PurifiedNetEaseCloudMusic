import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/routes/router.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
// 导入permission_handler包用于处理通知权限
// 替换了原来使用的notification_permissions包
import 'package:permission_handler/permission_handler.dart';

// TODO YU4422 待重写首次启动时的引导界面
class GuideView extends StatefulWidget {
  const GuideView({Key? key}) : super(key: key);

  @override
  State<GuideView> createState() => _GuideViewState();
}

class _GuideViewState extends State<GuideView> with WidgetsBindingObserver {
  bool gradient = true;
  bool left = true;
  PageController pageController = PageController();
  Timer? _timer;
  List<BottomData>? _bottomData;

  // final BujuanAudioHandler audioServeHandler = GetIt.instance<BujuanAudioHandler>();
  bool openSetting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      setState(() {
        gradient = !gradient;
        left = !left;
      });
    });
    _bottomData = [
      BottomData('title', 'subTitle'),
      BottomData('是否开启播放页渐变', '请观看上方图片示例', onCancel: () {
        _jumpToPage(2);
        // StorageUtil().setBool(gradientBackgroundSp, false);
      }, onOk: () {
        _jumpToPage(2);
        // StorageUtil().setBool(gradientBackgroundSp, true);
      }),
      BottomData('为了更好的为您服务', '请授予通知权限', onCancel: () {
        AutoRouter.of(context).replaceNamed(Routes.home);
      }, onOk: () async {
        // 使用permission_handler获取通知权限
        // 替换了原来使用的NotificationPermissions.getNotificationPermissionStatus()
        var status = await Permission.notification.status;
        // 检查权限状态
        if (status.isDenied || status.isRestricted) {
          // 请求通知权限
          await Permission.notification.request();
          // 检查是否永久拒绝
          if (await Permission.notification.isPermanentlyDenied) {
            openSetting = true;
            // 打开应用设置页面，让用户手动开启权限
            // 替换了原来使用的NotificationPermissions.openSettings()
            await openAppSettings();
          } else {
            openSetting = true;
          }
        } else {
          AutoRouter.of(context).replaceNamed(Routes.home);
        }
      }, cancelTitle: '不授权', okTitle: '授权'),
    ];
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当应用从后台恢复到前台且之前打开过设置页面时
    if (state == AppLifecycleState.resumed && openSetting) {
      // 使用permission_handler检查通知权限状态
      // 替换了原来使用的NotificationPermissions.getNotificationPermissionStatus()
      Permission.notification.status.then((status) {
        // 检查权限状态
        // 替换了原来使用的NotificationPermissionStatus.denied等状态检查
        if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
          WidgetUtil.showToast('您未开启通知权限哦');
        } else {
          if (mounted) AutoRouter.of(context).replaceNamed(Routes.home);
        }
      });
    }
  }

  void _jumpToPage(int page) {
    pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  @override
  void dispose() {
    pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildWelcome(),
              // _buildLeftImage(context),
              _buildSolidBackground(context),
              _buildNotification(),
            ],
          ),
          SafeArea(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: IconButton(
                onPressed: () {
                  AutoRouter.of(context).replaceNamed(Routes.home);
                  // StorageUtil().setBool(leftImageSp, false);
                  // StorageUtil().setBool(gradientBackgroundSp, true);
                },
                icon: Text(
                  'Skip',
                  style: TextStyle(fontSize: 32),
                )),
          ))
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset('assets/lottie/personal_character.json', width: 750 / 1.6),
        Padding(padding: EdgeInsets.symmetric(vertical: 20)),
        Text(
          '欢迎来到不倦',
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Text(
          '使用之前请先设置个性化功能',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.normal),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 30)),
        GestureDetector(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xfffac9c9), Theme.of(context).primaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            width: 530,
            height: 86,
            child: Text(
              '前往设置',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
          onTap: () => pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.linear),
        ),
      ],
    );
  }

  Widget _buildLeftImage(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SafeArea(
            child: Transform.rotate(
          angle: -math.pi / 20,
          child: Container(
            margin: EdgeInsets.only(top: 100),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(25),
            ),
            width: 750 / 2,
            height: 750,
          ),
        )),
        SafeArea(
            child: Transform.rotate(
          angle: -math.pi / 40,
          child: Container(
            margin: EdgeInsets.only(top: 100),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(.2),
              borderRadius: BorderRadius.circular(25),
            ),
            width: 750 / 2,
            height: 750,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Opacity(
                  opacity: left ? 1 : 0,
                  child: IconButton(
                    iconSize: 180,
                    icon: Opacity(
                        opacity: .9,
                        child: Lottie.asset(
                          'assets/lottie/vr_animation.json',
                          width: 180,
                          height: 180,
                          // fit: BoxFit.fitWidth,
                          // filterQuality: FilterQuality.low,
                        )),
                    onPressed: () {},
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.5),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 180,
                            height: 20,
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.5),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            width: 80,
                            height: 20,
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.5),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.5),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 180,
                            height: 20,
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.5),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            width: 80,
                            height: 20,
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.5),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )),
        _buildItem(_bottomData![0])
      ],
    );
  }

  Widget _buildSolidBackground(context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SafeArea(
            child: Transform.rotate(
          angle: -math.pi / 20,
          child: Container(
            margin: EdgeInsets.only(top: 100),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [!gradient ? Theme.of(context).primaryColor.withOpacity(.5) : const Color(0xfffac9c9).withOpacity(.5), Theme.of(context).primaryColor.withOpacity(.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            width: 750 / 2,
            height: 750,
          ),
        )),
        SafeArea(
            child: Transform.rotate(
          angle: -math.pi / 40,
          child: Container(
            margin: EdgeInsets.only(top: 100),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [!gradient ? Theme.of(context).primaryColor : const Color(0xfffac9c9), Theme.of(context).primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            width: 750 / 2,
            height: 750,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  color: Theme.of(context).cardColor.withOpacity(.2),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: Theme.of(context).cardColor.withOpacity(.2),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        color: Theme.of(context).cardColor.withOpacity(.2),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        color: Theme.of(context).cardColor.withOpacity(.2),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 30))
              ],
            ),
          ),
        )),
        _buildItem(_bottomData![1])
      ],
    );
  }

  Widget _buildNotification() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SafeArea(
            child: Transform.rotate(
          angle: -math.pi / 20,
          child: Container(
            margin: EdgeInsets.only(top: 100),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(155, 178, 255, .3),
              borderRadius: BorderRadius.circular(25),
            ),
            width: 750 / 2,
            height: 750,
          ),
        )),
        SafeArea(
            child: Transform.rotate(
          angle: -math.pi / 40,
          child: Container(
            margin: EdgeInsets.only(top: 100),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(155, 178, 255, 1),
              borderRadius: BorderRadius.circular(25),
            ),
            width: 750 / 2,
            height: 750,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lottie/notification_request.json', width: 750 / 3),
                Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 46,
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.5),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
                    Container(
                      width: 100,
                      height: 46,
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )),
        _buildItem(_bottomData![2])
      ],
    );
  }

  Widget _buildItem(BottomData data) {
    return Positioned(
      bottom: 70,
      child: SafeArea(
        child: Column(
          children: [
            Text(
              data.title,
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Text(
              data.subTitle,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.normal),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 30)),
            Row(
              children: [
                GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: 230,
                    height: 80,
                    child: Text(
                      data.cancelTitle ?? '关闭',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                  onTap: () {
                    data.onCancel?.call();
                  },
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 40)),
                GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xfffac9c9), Theme.of(context).primaryColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: 230,
                    height: 80,
                    child: Text(
                      data.okTitle ?? '开启',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    data.onOk?.call();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BottomData {
  String title;
  String subTitle;
  String? cancelTitle;
  String? okTitle;
  VoidCallback? onCancel;
  VoidCallback? onOk;

  BottomData(this.title, this.subTitle, {this.cancelTitle, this.okTitle, this.onCancel, this.onOk});
}
