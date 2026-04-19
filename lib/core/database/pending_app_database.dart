import 'app_database.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/persistent_playback_restore_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/data/local/persistent_local_library_data_source.dart';

class PendingAppDatabase implements AppDatabase {
  PendingAppDatabase({required this.databaseName});

  final String databaseName;
  bool _initialized = false;
  final LocalLibraryDataSource _localLibraryDataSource =
      const PersistentLocalLibraryDataSource();
  final PlaybackRestoreDataSource _playbackRestoreDataSource =
      const PersistentPlaybackRestoreDataSource();

  @override
  Future<void> init() async {
    // 先把数据库生命周期和依赖入口固定下来，后续接入正式引擎时
    // 不需要再反复改应用启动顺序和依赖注册方式。
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  @override
  LocalLibraryDataSource get localLibraryDataSource => _localLibraryDataSource;

  @override
  PlaybackRestoreDataSource get playbackRestoreDataSource =>
      _playbackRestoreDataSource;
}
