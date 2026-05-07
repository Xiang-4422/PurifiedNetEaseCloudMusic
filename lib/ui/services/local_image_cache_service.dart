import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';

/// UI 图片本地缓存路径解析服务。
class LocalImageCacheService {
  const LocalImageCacheService._();

  static final LocalImageCacheRepository _repository = LocalImageCacheRepository();

  /// 同步读取已知图片路径。
  static String? peekResolvedImagePath(String imageUrl) {
    return _repository.peekResolvedImagePath(imageUrl);
  }

  /// 解析图片本地缓存路径。
  static Future<String> resolveImagePath(String imageUrl) {
    return _repository.resolveImagePath(imageUrl);
  }
}
