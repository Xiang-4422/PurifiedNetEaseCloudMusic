import 'package:audio_service/audio_service.dart';

class ArtworkDisplay {
  const ArtworkDisplay._();

  /// 页面级封面展示优先使用已经存在于本地的封面文件，只有确实没有本地资源时才回退远程 URL。
  static String? resolvePreferredArtwork(
    String? artworkUrl, {
    Iterable<MediaItem> fallbackItems = const <MediaItem>[],
  }) {
    for (final item in fallbackItems) {
      final localArtworkPath = '${item.extras?['localArtworkPath'] ?? ''}';
      if (localArtworkPath.isNotEmpty) {
        return localArtworkPath;
      }
      final image = '${item.extras?['image'] ?? ''}';
      if (image.isNotEmpty && !image.startsWith('http')) {
        return image;
      }
    }
    if (artworkUrl?.isNotEmpty == true) {
      return artworkUrl;
    }
    for (final item in fallbackItems) {
      final image = '${item.extras?['image'] ?? ''}';
      if (image.isNotEmpty) {
        return image;
      }
    }
    return null;
  }
}
