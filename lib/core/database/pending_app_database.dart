import 'app_database.dart';

class PendingAppDatabase implements AppDatabase {
  PendingAppDatabase({required this.databaseName});

  final String databaseName;
  bool _initialized = false;

  @override
  Future<void> init() async {
    // 先把数据库生命周期和依赖入口固定下来，后续接入正式引擎时
    // 不需要再反复改应用启动顺序和依赖注册方式。
    _initialized = true;
  }

  bool get isInitialized => _initialized;
}
