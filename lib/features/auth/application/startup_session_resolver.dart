import 'package:bujuan/features/auth/auth_state_store.dart';

/// 启动 session 解析器，用于决定首屏进入登录页还是主页。
class StartupSessionResolver {
  /// 创建启动 session 解析器。
  const StartupSessionResolver({
    AuthStateStore authStateStore = const AuthStateStore(),
  }) : _authStateStore = authStateStore;

  final AuthStateStore _authStateStore;

  /// 是否应直接打开主页。
  bool get shouldOpenHome => _authStateStore.hasCachedSession;
}
