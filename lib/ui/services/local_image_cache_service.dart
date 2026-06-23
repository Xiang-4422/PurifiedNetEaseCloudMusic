import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';

/// UI 图片本地缓存路径解析服务。
class LocalImageCacheService {
  const LocalImageCacheService._();

  static LocalImageCacheRepository? _repository;

  /// 绑定应用启动阶段创建的本地图片缓存仓库。
  static void configure({
    required LocalImageCacheRepository repository,
  }) {
    _repository = repository;
  }

  /// 同步读取已知图片路径。
  static String? peekResolvedImagePath(String imageUrl) {
    return _configuredRepository.peekResolvedImagePath(imageUrl);
  }

  /// 解析图片本地缓存路径。
  static Future<String> resolveImagePath(String imageUrl) {
    return _configuredRepository.resolveImagePath(imageUrl);
  }

  static LocalImageCacheRepository get _configuredRepository {
    final repository = _repository;
    if (repository == null) {
      throw StateError('LocalImageCacheService must be configured before resolving images.');
    }
    return repository;
  }
}
