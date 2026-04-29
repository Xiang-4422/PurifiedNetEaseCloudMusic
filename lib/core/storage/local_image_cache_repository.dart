import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// 本地图片缓存仓库，负责把远程图片落盘并解析本地图片路径。
class LocalImageCacheRepository {
  /// 创建本地图片缓存仓库。
  LocalImageCacheRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final Map<String, Future<String>> _pendingDownloads =
      <String, Future<String>>{};

  /// 解析可供本地读取的图片路径。
  Future<String> resolveImagePath(String imageUrl) {
    final normalizedUrl = imageUrl.trim();
    if (!_isRemoteUrl(normalizedUrl)) {
      return Future.value(_resolveLocalPath(normalizedUrl));
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
    final outputPath =
        '${cacheDirectory.path}/${_stableHash(imageUrl)}${_resolveExtension(imageUrl)}';
    if (File(outputPath).existsSync()) {
      return outputPath;
    }

    final temporaryPath = '$outputPath.download';
    final temporaryFile = File(temporaryPath);
    if (temporaryFile.existsSync()) {
      await temporaryFile.delete();
    }

    await _dio.download(
      imageUrl,
      temporaryPath,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        headers: _imageHttpHeaders,
      ),
    );

    final outputFile = File(outputPath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    await temporaryFile.rename(outputPath);
    return outputPath;
  }

  Future<Directory> _ensureCacheDirectory() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final cacheDirectory =
        Directory('${supportDirectory.path}/zmusic/image-cache');
    if (!cacheDirectory.existsSync()) {
      await cacheDirectory.create(recursive: true);
    }
    return cacheDirectory;
  }

  String _resolveLocalPath(String rawPath) {
    if (rawPath.isEmpty) {
      return '';
    }
    final uri = Uri.tryParse(rawPath);
    if (uri != null && uri.scheme == 'file') {
      return uri.toFilePath();
    }
    return rawPath.split('?').first;
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
    return value.startsWith('http://') || value.startsWith('https://');
  }

  static const Map<String, String> _imageHttpHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
  };
}
