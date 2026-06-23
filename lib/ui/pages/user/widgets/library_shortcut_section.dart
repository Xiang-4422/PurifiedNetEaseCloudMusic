import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/pages/user/user_playlist_library_page.dart';
import 'package:bujuan/ui/pages/user/widgets/library_shortcut_bar.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:flutter/material.dart';

/// 个人页“资料库”入口区域。
class LibraryShortcutSection extends StatelessWidget {
  /// 创建资料库入口区域。
  const LibraryShortcutSection({
    super.key,
    required this.libraryController,
    this.headerHeight = AppDimensions.headerHeight,
    this.headerTopMargin = 0,
  });

  /// 用户资料库控制器。
  final UserLibraryController libraryController;

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
        LibraryShortcutBar(
          likedPlaylist: () => libraryController.userLikedSongPlayList.value,
          userPlaylistsPageBuilder: (_) => UserPlaylistLibraryPageView(
            controller: libraryController,
          ),
        ),
      ],
    );
  }
}
