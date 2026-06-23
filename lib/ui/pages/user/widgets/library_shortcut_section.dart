import 'package:bujuan/ui/pages/user/widgets/library_shortcut_bar.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:flutter/material.dart';

/// 个人页“资料库”入口区域。
class LibraryShortcutSection extends StatelessWidget {
  /// 创建资料库入口区域。
  const LibraryShortcutSection({
    super.key,
    this.headerHeight = AppDimensions.headerHeight,
    this.headerTopMargin = 0,
  });

  /// 标题高度。
  final double headerHeight;

  /// 标题顶部间距。
  final double headerTopMargin;

  @override
  Widget build(BuildContext context) {
    final header = Header(
      '资料库',
      padding: AppDimensions.paddingSmall,
      height: headerHeight,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (headerTopMargin > 0)
          Padding(
            padding: EdgeInsets.only(top: headerTopMargin),
            child: header,
          )
        else
          header,
        const LibraryShortcutBar(),
      ],
    );
  }
}
