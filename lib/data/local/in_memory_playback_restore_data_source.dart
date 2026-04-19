import 'package:bujuan/features/playback/playback_restore_state.dart';

import 'playback_restore_data_source.dart';

class InMemoryPlaybackRestoreDataSource implements PlaybackRestoreDataSource {
  const InMemoryPlaybackRestoreDataSource();

  static PlaybackRestoreState? _restoreState;

  @override
  Future<PlaybackRestoreState?> getRestoreState() async {
    return _restoreState;
  }

  @override
  Future<void> saveRestoreState(PlaybackRestoreState state) async {
    _restoreState = state;
  }
}
