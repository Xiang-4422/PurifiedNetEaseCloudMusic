import 'dart:async';

import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/auth/auth_ui_effect.dart';
import 'package:bujuan/features/auth/qr_login_data.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:get/get.dart';

/// 承接二维码登录流程的瞬时状态，避免登录页继续持有轮询与鉴权副作用。
class AuthController extends GetxController {
  /// 创建二维码登录控制器。
  AuthController({
    required AuthRepository repository,
    Duration qrPollingInterval = const Duration(seconds: 3),
  })  : _repository = repository,
        _qrPollingInterval = qrPollingInterval;

  final AuthRepository _repository;
  final Duration _qrPollingInterval;

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

  /// 登录流程的一次性展示副作用，由 presentation 边界消费。
  final Rxn<AuthUiEffect> uiEffect = Rxn<AuthUiEffect>();

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
    await _validateLoginStateInBackgroundSafely();
  }

  Future<void> _runBootstrap() async {
    if (_repository.hasCachedLogin) {
      final sessionController = UserSessionController.to;
      if (sessionController.userInfo.value.isLoggedIn) {
        loginCompleted.value = true;
        unawaited(_validateLoginStateInBackgroundSafely());
        return;
      }

      isLoading.value = true;
      final loaded = await _loadUserData();
      if (!loaded) {
        await refreshQrCode();
      }
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
    try {
      final qrCodeLoginKey = await _repository.createQrCodeKey();
      if (!qrCodeLoginKey.success) {
        _handleQrCodeRefreshFailure(qrCodeLoginKey.message ?? '二维码获取失败，请稍后重试');
        return;
      }

      qrCodeUrl.value = _repository.buildQrCodeUrl(qrCodeLoginKey.unikey);
      hintText.value = '扫描二维码登录';
      qrCodeNeedRefresh.value = false;
      _startPolling(qrCodeLoginKey.unikey);
    } catch (_) {
      _handleQrCodeRefreshFailure('二维码获取失败，请稍后重试');
    } finally {
      isLoading.value = false;
    }
  }

  /// 消费登录完成事件，避免页面重复跳转。
  void consumeLoginCompleted() {
    loginCompleted.value = false;
  }

  /// 消费当前登录展示副作用，避免重复展示。
  void consumeUiEffect(AuthUiEffect effect) {
    if (identical(uiEffect.value, effect)) {
      uiEffect.value = null;
    }
  }

  @override
  void onClose() {
    _qrPollingTimer?.cancel();
    super.onClose();
  }

  Future<bool> _loadUserData() async {
    try {
      final accountInfo = await _repository.fetchLoginAccountInfo();
      final isLoginStateActive = accountInfo.isLoggedIn;

      if (!isLoginStateActive) {
        await _expireLocalLoginSession();
        uiEffect.value = const AuthUiEffect.loginExpired('登录失效,请重新登录');
        _prepareQrRetry();
        return false;
      }

      final sessionController = UserSessionController.to;
      sessionController.userInfo.value = accountInfo;
      loginCompleted.value = true;
      return true;
    } catch (_) {
      if (!UserSessionController.to.userInfo.value.isLoggedIn) {
        await _expireLocalLoginSession();
      }
      uiEffect.value = const AuthUiEffect.message('登录状态校验失败，请重新登录');
      _prepareQrRetry();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _prepareQrRetry() {
    qrCodeNeedRefresh.value = true;
    hintText.value = '扫描二维码登录';
  }

  void _handleQrCodeRefreshFailure(String message) {
    uiEffect.value = AuthUiEffect.message(message);
    qrCodeNeedRefresh.value = true;
    hintText.value = '二维码获取失败，点击重试';
  }

  Future<void> _validateLoginStateInBackground() async {
    final sessionController = UserSessionController.to;
    final validatingUserId = sessionController.userInfo.value.userId;
    if (validatingUserId.isEmpty) {
      return;
    }
    final accountInfo = await _repository.fetchLoginAccountInfo();
    if (sessionController.userInfo.value.userId != validatingUserId) {
      return;
    }
    if (accountInfo.isLoggedIn) {
      sessionController.userInfo.value = accountInfo;
      return;
    }

    await _expireLocalLoginSession();
    uiEffect.value = const AuthUiEffect.loginExpired('登录失效,请重新登录');
  }

  Future<void> _expireLocalLoginSession() {
    return UserSessionController.to.expireLoginSession();
  }

  Future<void> _validateLoginStateInBackgroundSafely() async {
    try {
      await _validateLoginStateInBackground();
    } catch (_) {
      // Background validation is best-effort; keep the cached session on transient failures.
    }
  }

  void _startPolling(String unikey) {
    _qrPollingTimer?.cancel();
    _qrPollingTimer = Timer.periodic(_qrPollingInterval, (timer) async {
      final QrCodeStatusResult serverStatus;
      try {
        serverStatus = await _repository.checkQrCodeStatus(unikey);
      } catch (_) {
        hintText.value = '网络异常，等待重试';
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
          final loaded = await _loadUserData();
          if (!loaded) {
            await refreshQrCode();
          }
          break;
        default:
          break;
      }
    });
  }
}
