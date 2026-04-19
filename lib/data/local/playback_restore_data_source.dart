import 'package:bujuan/features/playback/playback_restore_state.dart';

abstract class PlaybackRestoreDataSource {
  Future<PlaybackRestoreState?> getRestoreState();

  Future<void> saveRestoreState(PlaybackRestoreState state);
}
