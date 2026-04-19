import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';

abstract class AppDatabase {
  Future<void> init();

  LocalLibraryDataSource get localLibraryDataSource;

  PlaybackRestoreDataSource get playbackRestoreDataSource;
}
