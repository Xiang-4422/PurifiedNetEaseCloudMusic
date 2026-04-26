import 'package:audio_service/audio_service.dart';

class ArtworkDisplay {
  const ArtworkDisplay._();

  /// 页面级封面展示优先返回已经存在于本地的封面路径。
  ///
  /// 如果没有本地路径，会返回原始远程 URL；图片组件会先把远程 URL 写入应用本地
  /// 图片缓存，再从本地文件渲染。
  static String? resolvePreferredArtwork(
    String? artworkUrl, {
    Iterable<MediaItem> fallbackItems = const <MediaItem>[],
  }) {
    for (final item in fallbackItems) {
      final localArtworkPath = '${item.extras?['localArtworkPath'] ?? ''}';
      if (_isLocalPath(localArtworkPath)) {
        return localArtworkPath;
      }
      final image = '${item.extras?['image'] ?? ''}';
      if (_isLocalPath(image)) {
        return image;
      }
    }
    if (artworkUrl?.isNotEmpty == true) {
      return artworkUrl;
    }
    for (final item in fallbackItems) {
      final image = '${item.extras?['image'] ?? ''}';
      if (_isLocalPath(image)) {
        return image;
      }
    }
    return null;
  }

  static String resolveDisplayPath(String? artworkPath) {
    return artworkPath ?? '';
  }

  static bool _isLocalPath(String? artworkPath) {
    if (artworkPath == null || artworkPath.isEmpty) {
      return false;
    }
    return !artworkPath.startsWith('http://') &&
        !artworkPath.startsWith('https://');
  }
}
