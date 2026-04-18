import 'dart:async';

import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/features/auth/repository/auth_repository.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  final qrCodeUrl = ''.obs;
  final hintText = '扫描二维码登录'.obs;
  final isLoading = false.obs;
  final qrCodeNeedRefresh = true.obs;
  final loginCompleted = false.obs;

  Timer? _qrPollingTimer;

  Future<void> bootstrap() async {
    if (_repository.hasCachedLogin) {
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
    if (qrCodeLoginKey.code != 200) {
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
    final isLoginStateActive =
        accountInfo.code == 200 && accountInfo.profile != null;

    if (!isLoginStateActive) {
      await _repository.setLoginFlag(false);
      WidgetUtil.showToast('登录失效,请重新登录');
      isLoading.value = false;
      return;
    }

    AppController.to.userInfo.value = accountInfo;
    await AppController.to.updateData();
    loginCompleted.value = true;
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
