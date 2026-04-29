import 'package:bujuan/domain/entities/user_session_data.dart';
import 'package:get/get.dart';

class ShellUserPort {
  const ShellUserPort({
    required this.userInfo,
    required this.currentNickname,
  });

  final Rx<UserSessionData> Function() userInfo;
  final String Function() currentNickname;
}
