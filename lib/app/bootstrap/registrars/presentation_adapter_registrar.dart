import 'package:bujuan/app/ui/toast_service.dart';
import 'package:bujuan/app/presentation_adapters/comment_content_port.dart';
import 'package:bujuan/app/presentation_adapters/playback_artwork_presenter.dart';
import 'package:bujuan/app/presentation_adapters/playback_selection_ui_effect_coordinator.dart';
import 'package:bujuan/app/presentation_adapters/playback_theme_port.dart';
import 'package:bujuan/app/presentation_adapters/settings_navigation_port.dart';
import 'package:bujuan/app/presentation_adapters/shell_playback_port.dart';
import 'package:bujuan/app/presentation_adapters/shell_user_port.dart';
import 'package:bujuan/features/comment/presentation/comment_widget.dart';
import 'package:bujuan/features/download/presentation/download_task_page_view.dart';
import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/application/playback_toast_port.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/debug/presentation/coverflow_demo_page_view.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 展示层适配器注册器，集中装配依赖 Flutter UI 类型的 port。
class PresentationAdapterRegistrar {
  /// 禁止实例化展示层适配器注册器。
  const PresentationAdapterRegistrar._();

  /// 注册 toast、主题、路由和评论内容等展示层 adapter。
  static void register() {
    Get.put<PlaybackToastPort>(
      const PlaybackToastPort(show: ToastService.show),
      permanent: true,
    );
    Get.put<PlaybackThemePort>(
      PlaybackThemePort(
        applyDominantColor: (color) {
          final settingsController = Get.find<SettingsController>();
          settingsController.albumColor.value = color;
          settingsController.panelWidgetColor.value =
              color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
        },
      ),
      permanent: true,
    );
    Get.put<ShellPlaybackPort>(
      ShellPlaybackPort(
        lyricState: () => Get.find<PlayerController>().lyricState,
        currentQueueIndex: () => Get.find<PlayerController>().currentQueueIndex,
        selectionState: () => Get.find<PlayerController>().selectionState.value,
        runtimeState: () => Get.find<PlayerController>().runtimeState.value,
        isFullScreenLyricOpen: () =>
            Get.find<PlayerController>().isFullScreenLyricOpen.value,
        updateFullScreenLyricTimerCounter: ({cancelTimer = false}) =>
            Get.find<PlayerController>().updateFullScreenLyricTimerCounter(
          cancelTimer: cancelTimer,
        ),
        playQueueIndex: (index) =>
            Get.find<PlayerController>().playQueueIndex(index),
      ),
      permanent: true,
    );
    Get.put<ShellUserPort>(
      ShellUserPort(
        userInfo: () => Get.find<UserSessionController>().userInfo,
        currentNickname: () =>
            Get.find<UserSessionController>().userInfo.value.nickname,
      ),
      permanent: true,
    );
    Get.put<PlaybackArtworkPresenter>(
      PlaybackArtworkPresenter(repository: Get.find<PlaybackRepository>()),
      permanent: true,
    );
    Get.put<PlaybackSelectionUiEffectCoordinator>(
      PlaybackSelectionUiEffectCoordinator(
        sideEffectCoordinator: Get.find<CurrentTrackSideEffectCoordinator>(),
        lyricsPresenter: Get.find<PlaybackLyricsPresenter>(),
        artworkPresenter: Get.find<PlaybackArtworkPresenter>(),
        themePort: Get.find<PlaybackThemePort>(),
      ),
      permanent: true,
    );
    Get.put<SettingsNavigationPort>(
      SettingsNavigationPort(
        openLocalSongs: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DownloadTaskPageView(),
            ),
          );
        },
        openCoverFlowDemo: (context) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => const CoverFlowDemoPageView(),
              fullscreenDialog: true,
            ),
          );
        },
      ),
      permanent: true,
    );
    Get.put<CommentContentPort>(
      CommentContentPort(
        buildSongComments: ({
          required context,
          required songId,
          required commentType,
          required listPaddingTop,
          required listPaddingBottom,
          required stringColor,
        }) =>
            CommentWidget(
          key: ValueKey(songId),
          context: context,
          id: songId,
          idType: 'song',
          commentType: commentType,
          listPaddingTop: listPaddingTop,
          listPaddingBottom: listPaddingBottom,
          stringColor: stringColor,
        ),
      ),
      permanent: true,
    );
  }
}
