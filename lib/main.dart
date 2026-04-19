import 'package:bujuan/app/bootstrap/app_bootstrap.dart';
import 'package:bujuan/app/routing/app_root_router.dart';
import 'package:flutter/material.dart';

/// 仅保留应用启动顺序，避免初始化细节继续回流到入口文件。
Future<void> main() async {
  await bootstrapApplication();
  runApp(AppRootRouter());
}
