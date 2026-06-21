import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// 图片下载函数，用于生产环境 Dio 下载和测试替身。
typedef ImageCacheDownloader = Future<void> Function(
  String imageUrl,
  String savePath,
  Options options,
);

/// 本地图片缓存仓库，负责把远程图片落盘并解析本地图片路径。
class LocalImageCacheRepository {
  /// 创建本地图片缓存仓库。
  LocalImageCacheRepository({
    Dio? dio,
    Future<Directory> Function()? cacheDirectoryProvider,
    ImageCacheDownloader? downloader,
  })  : _dio = dio ?? Dio(),
        _cacheDirectoryProvider = cacheDirectoryProvider,
        _downloader = downloader;

  final Dio _dio;
  final Future<Directory> Function()? _cacheDirectoryProvider;
  final ImageCacheDownloader? _downloader;
  static const int _maxResolvedPathCacheSize = 512;
  static const int _maxRemoteDownloadConcurrency = 4;
  static final Map<String, Future<String>> _pendingDownloads = <String, Future<String>>{};
  static final LinkedHashMap<String, String> _resolvedPaths = LinkedHashMap<String, String>();
  static final Queue<Completer<void>> _remoteDownloadWaiters = Queue<Completer<void>>();
  static int _activeRemoteDownloads = 0;

  /// 同步读取已知图片路径。
  ///
  /// 本地路径会直接解析；远程 URL 只在内存路径缓存已命中且文件仍存在时返回。
  String? peekResolvedImagePath(String imageUrl) {
    final normalizedUrl = _normalizeImageSource(imageUrl);
    if (normalizedUrl.isEmpty) {
      return '';
    }
    if (!_isRemoteUrl(normalizedUrl)) {
      return _resolveLocalPath(normalizedUrl);
    }
    return _cachedResolvedPath(normalizedUrl);
  }

  /// 解析可供本地读取的图片路径。
  Future<String> resolveImagePath(String imageUrl) {
    final normalizedUrl = _normalizeImageSource(imageUrl);
    if (!_isRemoteUrl(normalizedUrl)) {
      final resolvedPath = _resolveLocalPath(normalizedUrl);
      _rememberResolvedPath(normalizedUrl, resolvedPath);
      return Future.value(resolvedPath);
    }

    final cachedPath = _cachedResolvedPath(normalizedUrl);
    if (cachedPath != null) {
      return Future.value(cachedPath);
    }

    final pending = _pendingDownloads[normalizedUrl];
    if (pending != null) {
      return pending;
    }

    final future = _cacheRemoteImage(normalizedUrl).whenComplete(() {
      _pendingDownloads.remove(normalizedUrl);
    });
    _pendingDownloads[normalizedUrl] = future;
    return future;
  }

  Future<String> _cacheRemoteImage(String imageUrl) async {
    final cacheDirectory = await _ensureCacheDirectory();
    final outputPath = '${cacheDirectory.path}/${_stableHash(imageUrl)}${_resolveExtension(imageUrl)}';
    if (File(outputPath).existsSync()) {
      _rememberResolvedPath(imageUrl, outputPath);
      return outputPath;
    }

    final temporaryPath = '$outputPath.download';
    final uniqueTemporaryPath = '$temporaryPath.${DateTime.now().microsecondsSinceEpoch}';
    final temporaryFile = File(temporaryPath);
    final uniqueTemporaryFile = File(uniqueTemporaryPath);
    if (temporaryFile.existsSync()) {
      await _deleteFileIfExists(temporaryPath);
    }

    final options = Options(
      responseType: ResponseType.bytes,
      followRedirects: true,
      headers: _imageHttpHeaders,
    );
    try {
      await _withRemoteDownloadPermit(() async {
        if (_downloader == null) {
          await _dio.download(imageUrl, uniqueTemporaryPath, options: options);
        } else {
          await _downloader!(imageUrl, uniqueTemporaryPath, options);
        }
      });
    } catch (_) {
      await _deleteFileIfExists(uniqueTemporaryPath);
      rethrow;
    }

    final outputFile = File(outputPath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    if (uniqueTemporaryFile.existsSync()) {
      await uniqueTemporaryFile.rename(outputPath);
    } else if (!outputFile.existsSync()) {
      throw PathNotFoundException(uniqueTemporaryPath, const OSError());
    }
    _rememberResolvedPath(imageUrl, outputPath);
    return outputPath;
  }

  Future<void> _deleteFileIfExists(String path) async {
    if (path.isEmpty) {
      return;
    }
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  String? _cachedResolvedPath(String imageUrl) {
    final cachedPath = _resolvedPaths[imageUrl];
    if (cachedPath == null) {
      return null;
    }
    if (cachedPath.isEmpty || File(cachedPath).existsSync()) {
      _rememberResolvedPath(imageUrl, cachedPath);
      return cachedPath;
    }
    _resolvedPaths.remove(imageUrl);
    return null;
  }

  void _rememberResolvedPath(String imageUrl, String resolvedPath) {
    if (imageUrl.isEmpty) {
      return;
    }
    _resolvedPaths.remove(imageUrl);
    _resolvedPaths[imageUrl] = resolvedPath;
    while (_resolvedPaths.length > _maxResolvedPathCacheSize) {
      _resolvedPaths.remove(_resolvedPaths.keys.first);
    }
  }

  Future<T> _withRemoteDownloadPermit<T>(Future<T> Function() action) async {
    await _acquireRemoteDownloadPermit();
    try {
      return await action();
    } finally {
      _releaseRemoteDownloadPermit();
    }
  }

  Future<void> _acquireRemoteDownloadPermit() async {
    if (_activeRemoteDownloads < _maxRemoteDownloadConcurrency) {
      _activeRemoteDownloads++;
      return;
    }
    final waiter = Completer<void>();
    _remoteDownloadWaiters.add(waiter);
    await waiter.future;
  }

  void _releaseRemoteDownloadPermit() {
    final nextWaiter = _remoteDownloadWaiters.isEmpty ? null : _remoteDownloadWaiters.removeFirst();
    if (nextWaiter != null) {
      nextWaiter.complete();
      return;
    }
    _activeRemoteDownloads--;
  }

  Future<Directory> _ensureCacheDirectory() async {
    final supportDirectory = _cacheDirectoryProvider == null ? await getApplicationSupportDirectory() : await _cacheDirectoryProvider!();
    final cacheDirectory = Directory('${supportDirectory.path}/zmusic/image-cache');
    if (!cacheDirectory.existsSync()) {
      await cacheDirectory.create(recursive: true);
    }
    return cacheDirectory;
  }

  String _resolveLocalPath(String rawPath) {
    return LocalFilePathNormalizer.normalize(rawPath);
  }

  String _resolveExtension(String url) {
    final uri = Uri.tryParse(url);
    final path = uri?.path ?? '';
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return '.jpg';
    }
    final extension = path.substring(dotIndex).toLowerCase();
    if (extension.length > 10) {
      return '.jpg';
    }
    return extension;
  }

  String _stableHash(String value) {
    var hash = 0xcbf29ce484222325;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return hash.toRadixString(16);
  }

  bool _isRemoteUrl(String value) {
    return ImageUrlNormalizer.isRemoteHttpUrl(value);
  }

  String _normalizeImageSource(String imageUrl) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return '';
    }
    if (_isRemoteUrl(trimmedUrl)) {
      return ImageUrlNormalizer.normalize(trimmedUrl);
    }
    return trimmedUrl;
  }

  static const Map<String, String> _imageHttpHeaders = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
  };
}
