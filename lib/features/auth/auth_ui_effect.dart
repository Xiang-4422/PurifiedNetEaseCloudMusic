/// 登录流程需要展示层消费的一次性副作用类型。
enum AuthUiEffectType {
  /// 展示普通提示消息。
  message,

  /// 登录状态已失效或用户已退出，需要回到登录页。
  loginExpired,
}

/// 登录流程展示副作用，只表达展示意图，不直接触碰 Toast、路由或 BuildContext。
class AuthUiEffect {
  /// 创建登录展示副作用。
  const AuthUiEffect({
    required this.type,
    required this.message,
  });

  /// 展示普通提示消息。
  const AuthUiEffect.message(String message)
      : this(
          type: AuthUiEffectType.message,
          message: message,
        );

  /// 展示登录结束提示并返回登录页。
  const AuthUiEffect.loginExpired(String message)
      : this(
          type: AuthUiEffectType.loginExpired,
          message: message,
        );

  /// 副作用类型。
  final AuthUiEffectType type;

  /// 展示给用户的消息。
  final String message;
}
