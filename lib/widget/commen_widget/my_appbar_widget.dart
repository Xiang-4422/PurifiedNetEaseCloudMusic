import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget{
  const MyAppBar({
    Key? key,
    this.leadingWidget,
    this.title,
    this.actions,
    this.bottom,
    this.appBarHeight = 80,
  }) : super(key: key);

  // 可定制参数
  final Widget? leadingWidget;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double appBarHeight;

  // 固定参数
  final double blur = 25;
  final Color backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
      blur: blur,
      padding: EdgeInsets.all(0),
      borderRadius: BorderRadius.circular(0),
      child: AppBar(
        title: title,
        toolbarHeight: appBarHeight,
        leading: leadingWidget,
        leadingWidth: 80,
        actions: actions,
        bottom: bottom,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: backgroundColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        //bottom: getTitle(),
      )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}