import 'package:bujuan/app/theme/app_constants.dart';
import 'package:flutter/material.dart';

/// 通用列表分区标题。
class Header extends StatelessWidget {
  /// 创建列表分区标题。
  const Header(
    this.title, {
    super.key,
    this.padding = 0,
    this.height = AppDimensions.headerHeight,
  });

  /// 标题文本。
  final String title;

  /// 标题容器内边距。
  final double padding;

  /// 标题容器高度。
  final double height;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
