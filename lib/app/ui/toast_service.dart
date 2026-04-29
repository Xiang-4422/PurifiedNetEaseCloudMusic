import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 应用 toast 服务，统一展示轻量提示。
class ToastService {
  const ToastService._();

  /// 在顶部展示短时文本提示。
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}
