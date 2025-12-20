import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/routes/router.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../common/constants/key.dart';
import '../../common/constants/other.dart';
import '../../common/netease_api/src/api/bean.dart';
import '../../common/netease_api/src/api/login/bean.dart';
import '../../common/netease_api/src/netease_api.dart';

class LoginPageView extends StatefulWidget {
  const LoginPageView({Key? key}) : super(key: key);

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  Timer? timer;
  String qrCodeUrl = '';
  String hintText = "扫描二维码登录";

  bool qrCodeNeedRefresh = true;

  late bool isLoading;
  Box box = GetIt.instance<Box>();

  @override
  initState() {
    super.initState();
    if (box.get(isLoginSP) == true) {
      isLoading = true;
      getUserInfo();
    } else {
      isLoading = false;
      refreshQrCode(context);
    }
  }

  refreshQrCode(context) async {
    if (!qrCodeNeedRefresh) {
      return;
    }

    QrCodeLoginKey qrCodeLoginKey = await NeteaseMusicApi().loginQrCodeKey();
    if (qrCodeLoginKey.code != 200) {
      WidgetUtil.showToast(qrCodeLoginKey.message ?? '未知错误');
      return;
    }
    String codeUrl = NeteaseMusicApi().loginQrCodeUrl(qrCodeLoginKey.unikey);
    setState(() {
      qrCodeUrl = codeUrl;
      hintText = "扫描二维码登录";
      qrCodeNeedRefresh = false;
    });

    // 不停获取二维码状态（已经登录/二维码过期）
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) async {
      ServerStatusBean serverStatusBean =
          await NeteaseMusicApi().loginQrCodeCheck(qrCodeLoginKey.unikey);
      switch (serverStatusBean.code) {
        case 800:
          setState(() {
            hintText = "二维码过期";
            qrCodeNeedRefresh = true;
          });
          timer?.cancel();
          timer = null;
          break;
        case 803:
          hintText = "授权成功!";
          timer?.cancel();
          timer = null;
          box.put(isLoginSP, true);
          setState(() {
            isLoading = true;
          });
          getUserInfo();
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const LoadingView()
            : Visibility(
                visible: qrCodeUrl.isNotEmpty,
                child: GestureDetector(
                  onTap: () {
                    refreshQrCode(context);
                  },
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        QrImageView(
                          backgroundColor: Colors.white,
                          data: qrCodeUrl,
                          version: QrVersions.auto,
                          padding: const EdgeInsets.all(100),
                        ),
                        Container(
                          height: 100,
                          alignment: Alignment.center,
                          child: Text(
                            '扫描二维码登录',
                            style: TextStyle(
                                fontSize: 28,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }

  loadUserData() async {
    await AppController.to.updateData();
    AutoRouter.of(context).replaceNamed(Routes.home);
  }

  /// 更新用户登录信息
  Future<bool> getUserInfo() async {
    NeteaseAccountInfoWrap neteaseAccountInfoWrap =
        await NeteaseMusicApi().loginAccountInfo();
    // 登录信息有效
    bool isLoginStatueActive = neteaseAccountInfoWrap.code == 200 &&
        neteaseAccountInfoWrap.profile != null;
    if (isLoginStatueActive) {
      AppController.to.userInfo.value = neteaseAccountInfoWrap;
      loadUserData();
      return true;
    } else {
      box.put(isLoginSP, false);
      WidgetUtil.showToast('登录失效,请重新登录');
      setState(() {
        isLoading = false;
      });
      return false;
    }
  }
}
