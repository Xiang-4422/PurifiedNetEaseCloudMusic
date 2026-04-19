import 'package:bujuan/app/bootstrap/app_bootstrap.dart';
import 'package:bujuan/app/routing/app_root_router.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await bootstrapApplication();
  runApp(AppRootRouter());
}
