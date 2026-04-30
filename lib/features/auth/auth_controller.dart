import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/ui/toast_service.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/auth/qr_login_data.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/routes/router.dart';
import 'package:get/get.dart';

/// 承接二维码登录流程的瞬时状态，避免登录页继续持有轮询与鉴权副作用。
class AuthController extends GetxController {
  /// 创建二维码登录控制器。
  AuthController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  /// 当前二维码图片地址。
  final qrCodeUrl = ''.obs;

  /// 登录页展示给用户的二维码状态提示。
  final hintText = '扫描二维码登录'.obs;

  /// 是否正在加载登录账号信息。
  final isLoading = false.obs;

  /// 当前二维码是否已经失效并需要重新获取。
  final qrCodeNeedRefresh = true.obs;

  /// 本轮登录流程是否已经完成。
  final loginCompleted = false.obs;

  Timer? _qrPollingTimer;
  Future<void>? _bootstrapFuture;

  /// 启动登录页状态；有缓存登录时优先校验账号状态，否则刷新二维码。
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

  /// 在后台校验已缓存登录态是否仍然有效。
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

  /// 重新获取二维码并启动轮询。
  Future<void> refreshQrCode() async {
    if (!qrCodeNeedRefresh.value) {
      return;
    }

    isLoading.value = true;
    final QrCodeCreationResult qrCodeLoginKey;
    try {
      qrCodeLoginKey = await _repository.createQrCodeKey();
    } catch (_) {
      isLoading.value = false;
      qrCodeNeedRefresh.value = true;
      hintText.value = '二维码获取失败';
      ToastService.show('网络连接超时，请稍后重试');
      return;
    }
    isLoading.value = false;
    if (!qrCodeLoginKey.success) {
      ToastService.show(qrCodeLoginKey.message ?? '未知错误');
      return;
    }

    qrCodeUrl.value = _repository.buildQrCodeUrl(qrCodeLoginKey.unikey);
    hintText.value = '扫描二维码登录';
    qrCodeNeedRefresh.value = false;
    _startPolling(qrCodeLoginKey.unikey);
  }

  /// 消费登录完成事件，避免页面重复跳转。
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
      ToastService.show('登录失效,请重新登录');
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
    ToastService.show('登录失效,请重新登录');
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
      final QrCodeStatusResult serverStatus;
      try {
        serverStatus = await _repository.checkQrCodeStatus(unikey);
      } catch (_) {
        hintText.value = '二维码状态检查失败';
        qrCodeNeedRefresh.value = true;
        timer.cancel();
        _qrPollingTimer = null;
        ToastService.show('网络连接超时，请刷新二维码');
        return;
      }
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
