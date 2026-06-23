import 'dart:async';

import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/auth/auth_ui_effect.dart';
import 'package:bujuan/features/auth/qr_login_data.dart';
import 'package:get/get.dart';

/// 登录流程读写当前 App 用户 session 的窄边界。
class AuthSessionAccess {
  /// 创建登录会话访问边界。
  const AuthSessionAccess({
    required this.currentSession,
    required this.saveCurrentSession,
    required this.clearCurrentUser,
    required this.expireCurrentSession,
  });

  /// 读取当前 App 用户 session。
  final UserSessionData Function() currentSession;

  /// 写入当前 App 用户 session。
  final void Function(UserSessionData session) saveCurrentSession;

  /// 主动注销当前 App 用户。
  final Future<void> Function() clearCurrentUser;

  /// 标记当前 App 用户登录已失效。
  final Future<void> Function() expireCurrentSession;
}

/// 承接二维码登录流程的瞬时状态，避免登录页继续持有轮询与鉴权副作用。
class AuthController extends GetxController {
  /// 创建二维码登录控制器。
  AuthController({
    required AuthRepository repository,
    required AuthSessionAccess sessionAccess,
    Duration qrPollingInterval = const Duration(seconds: 3),
  })  : _repository = repository,
        _sessionAccess = sessionAccess,
        _qrPollingInterval = qrPollingInterval;

  final AuthRepository _repository;
  final AuthSessionAccess _sessionAccess;
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
  int _accountLoadGeneration = 0;
  int _qrFlowGeneration = 0;

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
    if (!_repository.hasCachedSession) {
      return;
    }
    if (!_sessionAccess.currentSession().isLoggedIn) {
      return;
    }
    await _validateLoginStateInBackgroundSafely();
  }

  Future<void> _runBootstrap() async {
    if (_repository.hasCachedSession) {
      if (_sessionAccess.currentSession().isLoggedIn) {
        loginCompleted.value = true;
        unawaited(_validateLoginStateInBackgroundSafely());
        return;
      }

      isLoading.value = true;
      final accountLoadGeneration = _startAccountLoad();
      final loaded = await _loadUserData(accountLoadGeneration);
      if (!_isCurrentAccountLoad(accountLoadGeneration)) {
        return;
      }
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

    _invalidateAccountLoad();
    final qrFlowGeneration = _startQrFlow();
    isLoading.value = true;
    try {
      final qrCodeLoginKey = await _repository.createQrCodeKey();
      if (!_isCurrentQrFlow(qrFlowGeneration)) {
        return;
      }
      if (!qrCodeLoginKey.success) {
        _handleQrCodeRefreshFailure(qrCodeLoginKey.message ?? '二维码获取失败，请稍后重试');
        return;
      }

      qrCodeUrl.value = _repository.buildQrCodeUrl(qrCodeLoginKey.unikey);
      hintText.value = '扫描二维码登录';
      qrCodeNeedRefresh.value = false;
      _startPolling(qrCodeLoginKey.unikey, qrFlowGeneration);
    } catch (_) {
      if (_isCurrentQrFlow(qrFlowGeneration)) {
        _handleQrCodeRefreshFailure('二维码获取失败，请稍后重试');
      }
    } finally {
      if (_isCurrentQrFlow(qrFlowGeneration)) {
        isLoading.value = false;
      }
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

  /// 主动退出当前账号，并交给根部展示副作用回到登录页。
  Future<void> logoutCurrentUser() async {
    _invalidateAccountLoad();
    _stopQrPolling();
    loginCompleted.value = false;
    isLoading.value = false;
    qrCodeNeedRefresh.value = true;
    await _sessionAccess.clearCurrentUser();
    uiEffect.value = const AuthUiEffect.loginExpired('已退出登录');
  }

  @override
  void onClose() {
    _invalidateAccountLoad();
    _stopQrPolling();
    super.onClose();
  }

  Future<bool> _loadUserData(int accountLoadGeneration) async {
    try {
      final accountInfo = await _repository.fetchLoginAccountInfo();
      if (!_isCurrentAccountLoad(accountLoadGeneration)) {
        return false;
      }
      final isLoginStateActive = accountInfo.isLoggedIn;

      if (!isLoginStateActive) {
        await _expireLocalLoginSession();
        uiEffect.value = const AuthUiEffect.loginExpired('登录失效,请重新登录');
        _prepareQrRetry();
        return false;
      }

      _sessionAccess.saveCurrentSession(accountInfo);
      loginCompleted.value = true;
      return true;
    } catch (_) {
      if (!_isCurrentAccountLoad(accountLoadGeneration)) {
        return false;
      }
      if (!_sessionAccess.currentSession().isLoggedIn) {
        await _expireLocalLoginSession();
      }
      uiEffect.value = const AuthUiEffect.message('登录状态校验失败，请重新登录');
      _prepareQrRetry();
      return false;
    } finally {
      if (_isCurrentAccountLoad(accountLoadGeneration)) {
        isLoading.value = false;
      }
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
    final validatingUserId = _sessionAccess.currentSession().userId;
    if (validatingUserId.isEmpty) {
      return;
    }
    final accountInfo = await _repository.fetchLoginAccountInfo();
    if (_sessionAccess.currentSession().userId != validatingUserId) {
      return;
    }
    if (accountInfo.isLoggedIn) {
      _sessionAccess.saveCurrentSession(accountInfo);
      return;
    }

    await _expireLocalLoginSession();
    uiEffect.value = const AuthUiEffect.loginExpired('登录失效,请重新登录');
  }

  Future<void> _expireLocalLoginSession() {
    return _sessionAccess.expireCurrentSession();
  }

  Future<void> _validateLoginStateInBackgroundSafely() async {
    try {
      await _validateLoginStateInBackground();
    } catch (_) {
      // Background validation is best-effort; keep the cached session on transient failures.
    }
  }

  void _startPolling(String unikey, int qrFlowGeneration) {
    _qrPollingTimer = Timer.periodic(_qrPollingInterval, (timer) async {
      if (!_isCurrentQrFlow(qrFlowGeneration)) {
        timer.cancel();
        return;
      }
      final QrCodeStatusResult serverStatus;
      try {
        serverStatus = await _repository.checkQrCodeStatus(unikey);
      } catch (_) {
        if (_isCurrentQrFlow(qrFlowGeneration)) {
          hintText.value = '网络异常，等待重试';
        }
        return;
      }
      if (!_isCurrentQrFlow(qrFlowGeneration)) {
        return;
      }
      switch (serverStatus.code) {
        case 800:
          hintText.value = '二维码过期';
          qrCodeNeedRefresh.value = true;
          timer.cancel();
          if (_isCurrentQrFlow(qrFlowGeneration)) {
            _qrPollingTimer = null;
          }
          break;
        case 803:
          hintText.value = '授权成功!';
          timer.cancel();
          if (_isCurrentQrFlow(qrFlowGeneration)) {
            _qrPollingTimer = null;
          }
          await _repository.setLoginFlag(true);
          if (!_isCurrentQrFlow(qrFlowGeneration)) {
            return;
          }
          isLoading.value = true;
          final accountLoadGeneration = _startAccountLoad();
          final loaded = await _loadUserData(accountLoadGeneration);
          if (!_isCurrentAccountLoad(accountLoadGeneration) || !_isCurrentQrFlow(qrFlowGeneration)) {
            return;
          }
          if (!loaded) {
            await refreshQrCode();
          }
          break;
        default:
          break;
      }
    });
  }

  int _startAccountLoad() {
    return ++_accountLoadGeneration;
  }

  void _invalidateAccountLoad() {
    _accountLoadGeneration++;
  }

  bool _isCurrentAccountLoad(int generation) {
    return generation == _accountLoadGeneration;
  }

  int _startQrFlow() {
    _qrFlowGeneration++;
    _qrPollingTimer?.cancel();
    _qrPollingTimer = null;
    return _qrFlowGeneration;
  }

  void _stopQrPolling() {
    _qrFlowGeneration++;
    _qrPollingTimer?.cancel();
    _qrPollingTimer = null;
  }

  bool _isCurrentQrFlow(int generation) {
    return generation == _qrFlowGeneration;
  }
}
