import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../common/constants/other.dart';
import '../../common/netease_api/src/api/bean.dart';
import '../../common/netease_api/src/api/login/bean.dart';
import '../../common/netease_api/src/netease_api.dart';
import '../user/personal_page_controller.dart';

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
          PersonalPageController.to.getUserState();
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
               color: Theme.of(context).cardColor.withOpacity(.5),
               width: context.width,
               height: context.height,
               alignment: Alignment.center,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   QrImageView(
                     backgroundColor: Colors.white,
                     data: qrCodeUrl,
                     version: QrVersions.auto,
                     size: 400.w,
                   ),
                   Padding(
                     padding: EdgeInsets.symmetric(vertical: 30.w),
                     child: Text(
                       '请扫描二维码码登录',
                       style: TextStyle(fontSize: 32.sp, color: Colors.white, fontWeight: FontWeight.bold),
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



