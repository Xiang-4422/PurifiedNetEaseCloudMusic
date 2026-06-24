import 'package:auto_route/auto_route.dart';
import 'package:bujuan/features/auth/auth_controller_bundle.dart';
import 'package:bujuan/app/routing/router.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _loginQrRefreshControlLabel = '刷新登录二维码';

/// 登录二维码刷新按钮的稳定标签。
@visibleForTesting
String loginQrRefreshControlLabel() => _loginQrRefreshControlLabel;

/// 二维码登录页面，负责展示登录二维码并在登录成功后跳转首页。
class LoginPageView extends StatefulWidget {
  /// 创建二维码登录页面。
  const LoginPageView({Key? key}) : super(key: key);

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  late final controller = Get.find<AuthControllerBundle>().authController;
  Worker? _loginWorker;

  @override
  void initState() {
    super.initState();
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
            : controller.qrCodeUrl.value.isEmpty
                ? ErrorView(
                    message: controller.hintText.value,
                    onRetry: controller.refreshQrCode,
                  )
                : Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 420,
                                  maxHeight: 420,
                                ),
                                child: QrImageView(
                                  backgroundColor: Colors.white,
                                  data: controller.qrCodeUrl.value,
                                  version: QrVersions.auto,
                                  padding: const EdgeInsets.all(32),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              controller.hintText.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Tooltip(
                              message: loginQrRefreshControlLabel(),
                              child: OutlinedButton.icon(
                                onPressed: controller.refreshQrCode,
                                icon: const Icon(Icons.refresh),
                                label: Text(loginQrRefreshControlLabel()),
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
