import 'package:auto_route/auto_route.dart';
import 'package:bujuan/features/auth/auth_controller.dart';
import 'package:bujuan/routes/router.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LoginPageView extends StatefulWidget {
  const LoginPageView({Key? key}) : super(key: key);

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  late final AuthController controller;
  Worker? _loginWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
    _loginWorker = ever(controller.loginCompleted, (bool completed) {
      if (!completed || !mounted) {
        return;
      }
      AutoRouter.of(context).replaceNamed(Routes.home);
      controller.consumeLoginCompleted();
    });
    if (controller.loginCompleted.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        AutoRouter.of(context).replaceNamed(Routes.home);
        controller.consumeLoginCompleted();
      });
    }
    controller.bootstrap();
  }

  @override
  void dispose() {
    _loginWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? const LoadingView()
            : Visibility(
                visible: controller.qrCodeUrl.isNotEmpty,
                child: GestureDetector(
                  onTap: controller.refreshQrCode,
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        QrImageView(
                          backgroundColor: Colors.white,
                          data: controller.qrCodeUrl.value,
                          version: QrVersions.auto,
                          padding: const EdgeInsets.all(100),
                        ),
                        Container(
                          height: 100,
                          alignment: Alignment.center,
                          child: Text(
                            controller.hintText.value,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
