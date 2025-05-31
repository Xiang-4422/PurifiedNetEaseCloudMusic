import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:flutter/material.dart';

class MyGetView extends StatelessWidget {
  final Widget child;

  const MyGetView({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: WillPopScope(child: child, onWillPop: () => HomePageController.to.onWillPop()),
      onHorizontalDragEnd: (e) {},
    );
  }
}
