import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/playlist/playlist_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double _userPlaylistLibraryCacheExtent = 360;

const PlaylistSummaryData _userPlaylistLibraryPrototypePlaylist = PlaylistSummaryData(
  id: 'prototype',
  title: '我的歌单',
  trackCount: 12,
);

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
        return ListView.builder(
          cacheExtent: _userPlaylistLibraryCacheExtent,
          prototypeItem: const Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.paddingSmall / 2),
            child: PlayListItem(_userPlaylistLibraryPrototypePlaylist),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingSmall,
            AppDimensions.paddingSmall,
            AppDimensions.paddingSmall,
            AppDimensions.bottomPanelHeaderHeight,
          ),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall / 2),
              child: PlayListItem(playlists[index]),
            );
          },
        );
      }),
    );
  }
}
