import 'package:bujuan/domain/entities/playback_restore_state.dart';

abstract class PlaybackRestoreDataSource {
  Future<PlaybackRestoreState?> getRestoreState();

  Future<void> saveRestoreState(PlaybackRestoreState state);
}
