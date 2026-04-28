import 'package:hive_flutter/hive_flutter.dart';

class CacheBox {
  const CacheBox._();

  static Box? _instance;

  static void init(Box box) {
    _instance = box;
  }

  static Box get instance {
    final box = _instance;
    if (box == null) {
      throw StateError('CacheBox has not been initialized.');
    }
    return box;
  }
}
