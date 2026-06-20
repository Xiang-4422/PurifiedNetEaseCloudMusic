import 'package:bujuan/data/app_storage/app_preferences.dart';
import 'package:bujuan/data/app_storage/cache_box.dart';
import 'package:bujuan/data/music_data/sources/local/database/app_database.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_app_database.dart';
import 'package:bujuan/data/music_data/sources/local/database/local_database_config.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 数据源和 repository 构建前必须完成初始化的存储资源。
class AppStorageBootstrapResult {
  /// 创建存储启动结果。
  const AppStorageBootstrapResult({
    required this.appDatabase,
    required this.appPreferences,
  });

  /// Drift 驱动的应用数据库门面。
  final AppDatabase appDatabase;

  /// 经 key-value 边界访问的应用设置门面。
  final AppPreferences appPreferences;
}

/// 初始化数据库和轻量 key-value 存储。
Future<AppStorageBootstrapResult> initializeStorageInfrastructure() async {
  final appDatabase = DriftAppDatabase(databaseName: LocalDatabaseConfig.databaseName);
  await appDatabase.init();

  await Hive.initFlutter('BuJuan');
  final cacheBox = await Hive.openBox('cache');
  CacheBox.init(cacheBox);

  return AppStorageBootstrapResult(
    appDatabase: appDatabase,
    appPreferences: const AppPreferences(),
  );
}
