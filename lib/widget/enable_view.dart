import 'package:flutter/material.dart';

// TODO YU4422: 后续删除
/// 应用停用提示视图。
class EnableView extends StatelessWidget {
  /// 创建应用停用提示视图。
  const EnableView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Text(
            '由于不可抗力因素\n本软件停止使用\n敬请谅解',
            style: TextStyle(
              fontSize: 26,
              height: 2,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
