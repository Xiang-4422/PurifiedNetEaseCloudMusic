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
      final localArtworkPath = item.localArtworkPath ?? '';
      if (_isLocalPath(localArtworkPath)) {
        return localArtworkPath;
      }
      final image = item.artworkUrl ?? '';
      if (_isLocalPath(image)) {
        return image;
      }
    }
    if (artworkUrl?.isNotEmpty == true) {
      return artworkUrl;
    }
    for (final item in fallbackItems) {
      final image = item.artworkUrl ?? '';
      if (_isRemoteHttpArtwork(image)) {
        return image;
      }
    }
    return null;
  }

  /// 页面已经有明确封面时，优先保持该封面稳定。
  ///
  /// 适用于歌单、专辑等详情页的主视觉，避免列表歌曲加载后用第一首歌封面临时
  /// 替换页面封面。只有页面封面为空时才退回到 [fallbackItems]。
  static String? resolveExplicitArtwork(
    String? artworkUrl, {
    Iterable<PlaybackQueueItem> fallbackItems = const <PlaybackQueueItem>[],
  }) {
    if (artworkUrl?.isNotEmpty == true) {
      return artworkUrl;
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
    if (_isLocalPath(localArtworkPath)) {
      return localArtworkPath;
    }
    if (_isLocalPath(artworkUrl)) {
      return artworkUrl;
    }
    if (artworkUrl?.isNotEmpty == true) {
      return artworkUrl;
    }
    return localArtworkPath?.isNotEmpty == true ? localArtworkPath : null;
  }

  /// 把 nullable 封面路径收敛成图片组件可直接接收的字符串。
  ///
  /// 这里故意不丢弃远程 URL，因为远程 URL 仍需要进入本地图片缓存后展示。
  static String resolveDisplayPath(String? artworkPath) {
    return artworkPath ?? '';
  }

  /// 判断路径是否已经是本地资源。
  ///
  /// 普通文件路径、合法 `file://` 和 Windows 盘符路径视为本地。
  /// HTTP(S) URL 交给本地图片缓存处理，其它 URI 不参与本地优先。
  static bool _isLocalPath(String? artworkPath) {
    return LocalFilePathNormalizer.normalize(artworkPath).isNotEmpty;
  }

  static bool _isRemoteHttpArtwork(String? artworkPath) {
    return ImageUrlNormalizer.isRemoteHttpUrl(artworkPath);
  }
}
