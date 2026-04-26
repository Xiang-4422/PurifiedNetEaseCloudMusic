import 'package:audio_service/audio_service.dart';

/// 封面展示路径选择工具。
///
/// 这里不下载图片，也不判断文件是否真实存在，只负责把页面手上已有的封面信息按
/// “本地优先”的展示顺序整理成一个可传给图片组件的字符串。真正的远程图片落盘由
/// `SimpleExtendedImage` / `LocalImageCacheRepository` 处理，歌曲封面资源入库由
/// `LibraryRepository` / `LocalArtworkCacheRepository` 处理。
class ArtworkPathResolver {
  const ArtworkPathResolver._();

  /// 页面级封面展示优先返回已经存在于本地的封面路径。
  ///
  /// 优先级：
  /// 1. `fallbackItems` 中的 `extras['localArtworkPath']`
  /// 2. `fallbackItems` 中已经是本地路径的 `extras['image']`
  /// 3. 调用方传入的 [artworkUrl]
  /// 4. `fallbackItems` 中其他可用本地 `extras['image']`
  ///
  /// 第 3 步可能是远程 URL；图片组件会先把远程 URL 写入应用本地图片缓存，再从
  /// 本地文件渲染。
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

  /// 把 nullable 封面路径收敛成图片组件可直接接收的字符串。
  ///
  /// 这里故意不丢弃远程 URL，因为远程 URL 仍需要进入本地图片缓存后展示。
  static String resolveDisplayPath(String? artworkPath) {
    return artworkPath ?? '';
  }

  /// 判断路径是否已经是本地资源。
  ///
  /// `file://` 和普通文件路径都视为本地；HTTP(S) URL 交给本地图片缓存处理。
  static bool _isLocalPath(String? artworkPath) {
    if (artworkPath == null || artworkPath.isEmpty) {
      return false;
    }
    return !artworkPath.startsWith('http://') &&
        !artworkPath.startsWith('https://');
  }
}
