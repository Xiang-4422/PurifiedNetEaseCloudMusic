import 'package:bujuan/domain/entities/user_session_data.dart';
import 'package:get/get.dart';

/// Shell 访问用户展示状态的端口，避免壳层直接依赖用户控制器。
class ShellUserPort {
  /// 创建 Shell 用户端口。
  const ShellUserPort({
    required this.userInfo,
    required this.currentNickname,
  });

  /// 当前登录用户 session 状态。
  final Rx<UserSessionData> Function() userInfo;

  /// 当前用户昵称。
  final String Function() currentNickname;
}
