import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/application/playback_toast_port.dart';
import 'package:bujuan/features/playback/playback_artwork_presenter.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/playback_selection_ui_effect_coordinator.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/ui/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Registers presentation adapters that bridge pure playback services to UI effects.
void registerPresentationAdapters() {
  Get.put<PlaybackToastPort>(
    const PlaybackToastPort(show: ToastService.show),
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
      applyDominantColor: (color) {
        final settingsController = Get.find<SettingsController>();
        settingsController.albumColor.value = color;
        settingsController.panelWidgetColor.value = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
      },
    ),
    permanent: true,
  );
}
