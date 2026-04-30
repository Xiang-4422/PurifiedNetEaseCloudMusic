/// 播放源类型，区分本地文件、远程 URL 和网易云缓存流。
enum PlaybackResolvedSourceKind {
  /// 没有可播放音源。
  empty,

  /// 本地文件路径音源。
  filePath,

  /// 普通远程 URL 音源。
  url,

  /// 网易云加密缓存文件流。
  neteaseCacheStream,
}

/// 解析后的真实播放源。
class PlaybackResolvedSource {
  /// 创建解析后的播放源。
  const PlaybackResolvedSource({
    required this.kind,
    this.url = '',
    this.fileType = '',
    this.markAsCached = false,
  });

  /// 播放源类型。
  final PlaybackResolvedSourceKind kind;

  /// 播放源地址或本地路径。
  final String url;

  /// 缓存流解密后的文件类型。
  final String fileType;

  /// 该音源是否应被标记为已缓存。
  final bool markAsCached;

  /// 当前播放源是否为空。
  bool get isEmpty => kind == PlaybackResolvedSourceKind.empty || url.isEmpty;
}
