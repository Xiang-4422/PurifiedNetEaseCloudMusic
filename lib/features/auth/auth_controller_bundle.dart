import 'package:bujuan/features/auth/auth_controller.dart';

/// 登录页和全局登录副作用监听器需要的控制器组合。
class AuthControllerBundle {
  /// 创建登录控制器组合。
  const AuthControllerBundle({
    required this.authController,
  });

  /// 登录控制器。
  final AuthController authController;
}
