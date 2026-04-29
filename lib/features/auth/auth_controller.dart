import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/routes/router.dart';
import 'package:get/get.dart';

/// 承接二维码登录流程的瞬时状态，避免登录页继续持有轮询与鉴权副作用。
class AuthController extends GetxController {
  AuthController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  final qrCodeUrl = ''.obs;
  final hintText = '扫描二维码登录'.obs;
  final isLoading = false.obs;
  final qrCodeNeedRefresh = true.obs;
  final loginCompleted = false.obs;

  Timer? _qrPollingTimer;
  Future<void>? _bootstrapFuture;

  Future<void> bootstrap() async {
    final pending = _bootstrapFuture;
    if (pending != null) {
      return pending;
    }

    final future = _runBootstrap();
    _bootstrapFuture = future;
    try {
      await future;
    } finally {
      _bootstrapFuture = null;
    }
  }

  Future<void> validateLoginStateInBackgroundIfNeeded() async {
    if (!_repository.hasCachedLogin) {
      return;
    }
    final sessionController = UserSessionController.to;
    if (!sessionController.userInfo.value.isLoggedIn) {
      return;
    }
    await _validateLoginStateInBackground();
  }

  Future<void> _runBootstrap() async {
    if (_repository.hasCachedLogin) {
      final sessionController = UserSessionController.to;
      if (sessionController.userInfo.value.isLoggedIn) {
        loginCompleted.value = true;
        unawaited(_validateLoginStateInBackground());
        return;
      }

      isLoading.value = true;
      await _loadUserData();
      return;
    }
    await refreshQrCode();
  }

  Future<void> refreshQrCode() async {
    if (!qrCodeNeedRefresh.value) {
      return;
    }

    final qrCodeLoginKey = await _repository.createQrCodeKey();
    if (!qrCodeLoginKey.success) {
      WidgetUtil.showToast(qrCodeLoginKey.message ?? '未知错误');
      return;
    }

    qrCodeUrl.value = _repository.buildQrCodeUrl(qrCodeLoginKey.unikey);
    hintText.value = '扫描二维码登录';
    qrCodeNeedRefresh.value = false;
    _startPolling(qrCodeLoginKey.unikey);
  }

  void consumeLoginCompleted() {
    loginCompleted.value = false;
  }

  @override
  void onClose() {
    _qrPollingTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadUserData() async {
    final accountInfo = await _repository.fetchLoginAccountInfo();
    final isLoginStateActive = accountInfo.isLoggedIn;

    if (!isLoginStateActive) {
      await _repository.setLoginFlag(false);
      await UserSessionController.to.expireLoginSession();
      WidgetUtil.showToast('登录失效,请重新登录');
      isLoading.value = false;
      return;
    }

    final sessionController = UserSessionController.to;
    sessionController.userInfo.value = accountInfo;
    loginCompleted.value = true;
  }

  Future<void> _validateLoginStateInBackground() async {
    final accountInfo = await _repository.fetchLoginAccountInfo();
    if (accountInfo.isLoggedIn) {
      final sessionController = UserSessionController.to;
      sessionController.userInfo.value = accountInfo;
      return;
    }

    await _repository.setLoginFlag(false);
    await UserSessionController.to.expireLoginSession();
    WidgetUtil.showToast('登录失效,请重新登录');
    Future.microtask(() {
      final context = Get.context;
      if (context != null) {
        // ignore: use_build_context_synchronously
        AutoRouter.of(context).replaceNamed(Routes.login);
      }
    });
  }

  void _startPolling(String unikey) {
    _qrPollingTimer?.cancel();
    _qrPollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final serverStatus = await _repository.checkQrCodeStatus(unikey);
      switch (serverStatus.code) {
        case 800:
          hintText.value = '二维码过期';
          qrCodeNeedRefresh.value = true;
          timer.cancel();
          _qrPollingTimer = null;
          break;
        case 803:
          hintText.value = '授权成功!';
          timer.cancel();
          _qrPollingTimer = null;
          await _repository.setLoginFlag(true);
          isLoading.value = true;
          await _loadUserData();
          break;
        default:
          break;
      }
    });
  }
}
