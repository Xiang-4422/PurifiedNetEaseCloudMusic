import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  final TextEditingController phone = TextEditingController();
  final TextEditingController pass = TextEditingController();
  Timer? timer;
  String qrCodeUrl = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getQrCode(context);
  }

  getQrCode(context) async {
    QrCodeLoginKey qrCodeLoginKey = await NeteaseMusicApi().loginQrCodeKey();
    if (qrCodeLoginKey.code != 200) {
      WidgetUtil.showToast(qrCodeLoginKey.message ?? '未知错误');
      return;
    }
    String codeUrl = NeteaseMusicApi().loginQrCodeUrl(qrCodeLoginKey.unikey);
    setState(() => qrCodeUrl = codeUrl);

    // 不停获取二维码状态（已经登录/二维码过期）
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) async {
      ServerStatusBean serverStatusBean = await NeteaseMusicApi().loginQrCodeCheck(qrCodeLoginKey.unikey);
      switch (serverStatusBean.code) {
        case 800:
          WidgetUtil.showToast('二维码过期请重新获取');
          timer?.cancel();
          timer = null;
          break;
        case 803:
          WidgetUtil.showToast('授权成功！');
          AppController.to.updateUserState();
          AppController.to.updateData();
          AutoRouter.of(context).pop();
          timer?.cancel();
          timer = null;
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    phone.dispose();
    timer?.cancel();
    pass.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: Stack(
       children: [
         Visibility(
           visible: qrCodeUrl.isNotEmpty,
           child: GestureDetector(
             onTap: () {
               timer?.cancel();
               timer = null;
               getQrCode(context);
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
                           fontWeight: FontWeight.bold
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ),
         )
       ],
     ),
   );
  }

}



