import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';

/// 封面展示路径选择工具。
///
/// 这里不下载图片，也不判断文件是否真实存在，只负责把页面手上已有的封面信息按
/// “本地优先”的展示顺序整理成一个可传给图片组件的字符串。真正的远程图片落盘由
/// `SimpleExtendedImage` / `LocalImageCacheRepository` 处理，歌曲封面资源入库由
/// `MusicDataRepository` / `LocalArtworkCacheRepository` 处理。
class ArtworkPathResolver {
  const ArtworkPathResolver._();

  /// 页面级封面展示优先返回已经存在于本地的封面路径。
  ///
  /// 优先级：
  /// 1. `fallbackItems` 中已经落盘的 `localArtworkPath`
  /// 2. `fallbackItems` 中误落在 `artworkUrl` 字段的本地路径
  /// 3. 调用方传入的 [artworkUrl]
  /// 4. `fallbackItems` 中可交给统一图片缓存处理的远程 HTTP(S) 封面
  ///
  /// 第 3 步可能是远程 URL；图片组件会先把远程 URL 写入应用本地图片缓存，再从
  /// 本地文件渲染。
  static String? resolvePreferredArtwork(
    String? artworkUrl, {
    Iterable<PlaybackQueueItem> fallbackItems = const <PlaybackQueueItem>[],
  }) {
    for (final item in fallbackItems) {
      final localArtworkPath = _localPath(item.localArtworkPath);
      if (localArtworkPath.isNotEmpty) {
        return localArtworkPath;
      }
      final image = _localPath(item.artworkUrl);
      if (image.isNotEmpty) {
        return image;
      }
    }
    final explicitArtwork = _displayPathOrNull(artworkUrl);
    if (explicitArtwork != null) {
      return explicitArtwork;
    }
    for (final item in fallbackItems) {
      final image = _remoteHttpArtwork(item.artworkUrl);
      if (image != null) {
        return image;
      }
    }
    return null;
  }

  /// 页面已经有明确封面时，优先保持该封面稳定。
  ///
  /// 适用于歌单、专辑等详情页的主视觉，避免列表歌曲加载后用第一首歌封面临时
  /// 替换页面封面。只有页面封面为空或不可展示时才退回到 [fallbackItems]。
  static String? resolveExplicitArtwork(
    String? artworkUrl, {
    Iterable<PlaybackQueueItem> fallbackItems = const <PlaybackQueueItem>[],
  }) {
    final explicitArtwork = _displayPathOrNull(artworkUrl);
    if (explicitArtwork != null) {
      return explicitArtwork;
    }
    return resolvePreferredArtwork(
      artworkUrl,
      fallbackItems: fallbackItems,
    );
  }

  /// 播放队列项或轻量展示项的封面路径选择。
  ///
  /// 当远程封面 URL 和本地封面路径同时存在时，优先返回已经落盘的本地封面。
  /// 本地路径无效时才回退到远程 URL。
  static String? resolvePlaybackArtwork({
    required String? artworkUrl,
    required String? localArtworkPath,
  }) {
    final localPath = _localPath(localArtworkPath);
    if (localPath.isNotEmpty) {
      return localPath;
    }
    final imageLocalPath = _localPath(artworkUrl);
    if (imageLocalPath.isNotEmpty) {
      return imageLocalPath;
    }
    final remoteArtwork = _remoteHttpArtwork(artworkUrl);
    if (remoteArtwork != null) {
      return remoteArtwork;
    }
    return null;
  }

  static String? _displayPathOrNull(String? artworkPath) {
    final displayPath = resolveDisplayPath(artworkPath);
    return displayPath.isEmpty ? null : displayPath;
  }

  static String _localPath(String? artworkPath) {
    return LocalFilePathNormalizer.normalize(artworkPath);
  }

  static String? _remoteHttpArtwork(String? artworkPath) {
    final rawPath = artworkPath?.trim() ?? '';
    if (_isRemoteHttpArtwork(rawPath)) {
      return ImageUrlNormalizer.normalize(rawPath);
    }
    return null;
  }

  /// 把 nullable 封面路径收敛成图片组件可直接接收的字符串。
  ///
  /// 本地路径会先规整成普通文件路径，远程 URL 会去掉网易云尺寸参数后继续交给
  /// 本地图片缓存处理；其它 URI scheme 直接返回空字符串，让图片组件显示占位。
  static String resolveDisplayPath(String? artworkPath) {
    final rawPath = artworkPath?.trim() ?? '';
    if (rawPath.isEmpty) {
      return '';
    }
    final localPath = _localPath(rawPath);
    if (localPath.isNotEmpty) {
      return localPath;
    }
    if (_isRemoteHttpArtwork(rawPath)) {
      return ImageUrlNormalizer.normalize(rawPath);
    }
    return '';
  }

  static bool _isRemoteHttpArtwork(String? artworkPath) {
    return ImageUrlNormalizer.isRemoteHttpUrl(artworkPath);
  }
}
