import 'package:bujuan/core/storage/local_image_cache_repository.dart';

/// 解析歌单封面取色使用的本地图片路径。
class PlaylistArtworkColorService {
  /// 创建歌单封面取色服务。
  PlaylistArtworkColorService({
    LocalImageCacheRepository? imageCacheRepository,
  }) : _imageCacheRepository = imageCacheRepository ?? LocalImageCacheRepository();

  final LocalImageCacheRepository _imageCacheRepository;

  /// 将远程封面地址解析成本地缓存路径，非远程地址原样返回。
  Future<String?> resolveColorPath(String? artworkPath) async {
    if (artworkPath == null || artworkPath.isEmpty || !_isRemoteArtwork(artworkPath)) {
      return artworkPath;
    }
    try {
      return await _imageCacheRepository.resolveImagePath(artworkPath);
    } catch (_) {
      return null;
    }
  }

  bool _isRemoteArtwork(String artworkPath) {
    return artworkPath.startsWith('http://') || artworkPath.startsWith('https://');
  }
}
