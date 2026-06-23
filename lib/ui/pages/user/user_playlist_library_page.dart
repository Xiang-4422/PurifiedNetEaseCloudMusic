import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/playlist/playlist_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double _userPlaylistLibraryCacheExtent = 360;

/// 当前账号的普通歌单列表页。
class UserPlaylistLibraryPageView extends StatelessWidget {
  /// 创建普通歌单列表页。
  const UserPlaylistLibraryPageView({
    super.key,
    required this.controller,
  });

  /// 用户资料库控制器。
  final UserLibraryController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的歌单'),
      ),
      body: Obx(() {
        final playlists = controller.userPlayLists;
        if (playlists.isEmpty) {
          return const Center(
            child: Text('暂无歌单'),
          );
        }
        return ListView.separated(
          cacheExtent: _userPlaylistLibraryCacheExtent,
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingSmall,
            AppDimensions.paddingSmall,
            AppDimensions.paddingSmall,
            AppDimensions.bottomPanelHeaderHeight,
          ),
          itemCount: playlists.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.paddingSmall / 2),
          itemBuilder: (context, index) => PlayListItem(playlists[index]),
        );
      }),
    );
  }
}
