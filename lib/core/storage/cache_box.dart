import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CacheBox {
  const CacheBox._();

  static Box get instance => GetIt.instance<Box>();
}
