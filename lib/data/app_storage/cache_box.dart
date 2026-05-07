import 'package:hive_flutter/hive_flutter.dart';

/// Hive 缓存盒全局入口，仅用于轻量 session、设置和展示缓存。
class CacheBox {
  /// 禁止实例化缓存盒工具类。
  const CacheBox._();

  static Box? _instance;

  /// 初始化 Hive 缓存盒。
  static void init(Box box) {
    _instance = box;
  }

  /// 获取已初始化的 Hive 缓存盒。
  static Box get instance {
    final box = _instance;
    if (box == null) {
      throw StateError('CacheBox has not been initialized.');
    }
    return box;
  }
}
