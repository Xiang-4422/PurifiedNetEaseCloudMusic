import 'dart:io';

import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:path_provider/path_provider.dart';

/// 缓存分类。
enum CacheCategory {
  /// 图片展示缓存。
  image,

  /// 曲目封面缓存。
  artwork,

  /// 播放音频缓存。
  playback,

  /// 应用临时文件。
  temporary,
}

/// 单类缓存统计结果。
class CacheCategoryAnalysis {
  /// 创建单类缓存统计结果。
  const CacheCategoryAnalysis({
    required this.category,
    required this.title,
    required this.description,
    required this.sizeBytes,
    required this.fileCount,
  });

  /// 缓存分类。
  final CacheCategory category;

  /// 展示标题。
  final String title;

  /// 展示说明。
  final String description;

  /// 缓存大小。
  final int sizeBytes;

  /// 文件数量。
  final int fileCount;
}

/// 缓存分析结果。
class CacheAnalysisResult {
  /// 创建缓存分析结果。
  const CacheAnalysisResult({required this.categories});

  /// 分类结果。
  final List<CacheCategoryAnalysis> categories;

  /// 总大小。
  int get totalSizeBytes => categories.fold<int>(
        0,
        (sum, item) => sum + item.sizeBytes,
      );

  /// 总文件数。
  int get totalFileCount => categories.fold<int>(
        0,
        (sum, item) => sum + item.fileCount,
      );
}

/// 分析和清理应用缓存。
class CacheAnalysisService {
  /// 创建缓存分析服务。
  const CacheAnalysisService({
    required MusicDataRepository musicDataRepository,
    required LocalResourceIndexRepository resourceIndexRepository,
  })  : _musicDataRepository = musicDataRepository,
        _resourceIndexRepository = resourceIndexRepository;

  final MusicDataRepository _musicDataRepository;
  final LocalResourceIndexRepository _resourceIndexRepository;

  /// 分析当前可安全清理的缓存。
  Future<CacheAnalysisResult> analyze() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final temporaryDirectory = await getTemporaryDirectory();
    final playbackResources = await _resourceIndexRepository.listResources(
      origins: const {TrackResourceOrigin.playbackCache},
    );
    final categories = [
      await _analyzeDirectory(
        CacheCategory.image,
        Directory('${supportDirectory.path}/zmusic/image-cache'),
      ),
      await _analyzeIndexedResourceCacheDirectory(
        CacheCategory.artwork,
        Directory('${supportDirectory.path}/zmusic/artwork-cache'),
        origin: TrackResourceOrigin.artworkCache,
      ),
      CacheCategoryAnalysis(
        category: CacheCategory.playback,
        title: _titleFor(CacheCategory.playback),
        description: _descriptionFor(CacheCategory.playback),
        sizeBytes: playbackResources.fold<int>(
          0,
          (sum, item) => sum + item.sizeBytes,
        ),
        fileCount: playbackResources.length,
      ),
      await _analyzeDirectory(
        CacheCategory.temporary,
        temporaryDirectory,
      ),
    ];
    return CacheAnalysisResult(categories: categories);
  }

  /// 清理指定分类。
  Future<void> clear(CacheCategory category) async {
    final supportDirectory = await getApplicationSupportDirectory();
    switch (category) {
      case CacheCategory.image:
        await _clearDirectory(Directory('${supportDirectory.path}/zmusic/image-cache'));
        return;
      case CacheCategory.artwork:
        await _clearIndexedResourceCacheDirectory(
          Directory('${supportDirectory.path}/zmusic/artwork-cache'),
          origin: TrackResourceOrigin.artworkCache,
        );
        return;
      case CacheCategory.playback:
        await _musicDataRepository.removePlaybackCache();
        return;
      case CacheCategory.temporary:
        await _clearDirectory(await getTemporaryDirectory());
        return;
    }
  }

  /// 清理全部可安全清理的缓存。
  Future<void> clearAll() async {
    for (final category in CacheCategory.values) {
      await clear(category);
    }
  }

  Future<CacheCategoryAnalysis> _analyzeDirectory(
    CacheCategory category,
    Directory directory,
  ) async {
    final stats = await _directoryStats(directory);
    return CacheCategoryAnalysis(
      category: category,
      title: _titleFor(category),
      description: _descriptionFor(category),
      sizeBytes: stats.sizeBytes,
      fileCount: stats.fileCount,
    );
  }

  Future<CacheCategoryAnalysis> _analyzeIndexedResourceCacheDirectory(
    CacheCategory category,
    Directory directory, {
    required TrackResourceOrigin origin,
  }) async {
    final cacheResources = await _resourceIndexRepository.listResources(
      origins: {origin},
    );
    final retainedPaths = _retainedResourcePathsAfterRemoving(
      await _resourceIndexRepository.listResources(),
      shouldRemove: (resource) => resource.origin == origin,
    );
    final countedPaths = <String>{};
    var sizeBytes = 0;
    var fileCount = 0;
    for (final resource in cacheResources) {
      final path = _resourceFilePath(resource);
      if (path.isEmpty || retainedPaths.contains(path) || !countedPaths.add(path)) {
        continue;
      }
      sizeBytes += resource.sizeBytes;
      fileCount++;
    }
    final orphanStats = await _unretainedDirectoryStats(
      directory,
      retainedPaths: retainedPaths,
      countedPaths: countedPaths,
    );
    return CacheCategoryAnalysis(
      category: category,
      title: _titleFor(category),
      description: _descriptionFor(category),
      sizeBytes: sizeBytes + orphanStats.sizeBytes,
      fileCount: fileCount + orphanStats.fileCount,
    );
  }

  Future<({int sizeBytes, int fileCount})> _directoryStats(
    Directory directory,
  ) async {
    if (!directory.existsSync()) {
      return (sizeBytes: 0, fileCount: 0);
    }
    var sizeBytes = 0;
    var fileCount = 0;
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        fileCount++;
        sizeBytes += await entity.length().catchError((_) => 0);
      }
    }
    return (sizeBytes: sizeBytes, fileCount: fileCount);
  }

  Future<({int sizeBytes, int fileCount})> _unretainedDirectoryStats(
    Directory directory, {
    required Set<String> retainedPaths,
    required Set<String> countedPaths,
  }) async {
    if (!directory.existsSync()) {
      return (sizeBytes: 0, fileCount: 0);
    }
    var sizeBytes = 0;
    var fileCount = 0;
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }
      final path = LocalFilePathNormalizer.normalize(entity.path);
      if (path.isEmpty || retainedPaths.contains(path) || !countedPaths.add(path)) {
        continue;
      }
      fileCount++;
      sizeBytes += await entity.length().catchError((_) => 0);
    }
    return (sizeBytes: sizeBytes, fileCount: fileCount);
  }

  Future<void> _clearDirectory(Directory directory) async {
    if (directory.existsSync()) {
      await for (final entity in directory.list(followLinks: false)) {
        try {
          await entity.delete(recursive: true);
        } catch (_) {}
      }
    }
    await directory.create(recursive: true);
  }

  Future<void> _clearIndexedResourceCacheDirectory(
    Directory directory, {
    required TrackResourceOrigin origin,
  }) async {
    final cacheResources = await _resourceIndexRepository.listResources(
      origins: {origin},
    );
    final retainedPaths = _retainedResourcePathsAfterRemoving(
      await _resourceIndexRepository.listResources(),
      shouldRemove: (resource) => resource.origin == origin,
    );
    for (final resource in cacheResources) {
      await _deleteFileUnlessRetained(resource.path, retainedPaths);
    }
    await _deleteUnretainedDirectoryFiles(
      directory,
      retainedPaths: retainedPaths,
    );
    await _resourceIndexRepository.removeResourcesByOrigin(origin);
    await directory.create(recursive: true);
  }

  Set<String> _retainedResourcePathsAfterRemoving(
    List<LocalResourceEntry> indexedResources, {
    required bool Function(LocalResourceEntry resource) shouldRemove,
  }) {
    final retainedPaths = <String>{};
    for (final resource in indexedResources) {
      if (shouldRemove(resource)) {
        continue;
      }
      final path = _resourceFilePath(resource);
      if (path.isNotEmpty) {
        retainedPaths.add(path);
      }
    }
    return retainedPaths;
  }

  Future<void> _deleteFileUnlessRetained(
    String path,
    Set<String> retainedPaths,
  ) async {
    final localPath = LocalFilePathNormalizer.normalize(path);
    if (localPath.isEmpty || retainedPaths.contains(localPath)) {
      return;
    }
    final file = File(localPath);
    if (!file.existsSync()) {
      return;
    }
    try {
      await file.delete();
    } catch (_) {}
  }

  Future<void> _deleteUnretainedDirectoryFiles(
    Directory directory, {
    required Set<String> retainedPaths,
  }) async {
    if (!directory.existsSync()) {
      return;
    }
    final childDirectories = <Directory>[];
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        await _deleteFileUnlessRetained(entity.path, retainedPaths);
      } else if (entity is Directory) {
        childDirectories.add(entity);
      }
    }
    childDirectories.sort(
      (left, right) => right.path.length.compareTo(left.path.length),
    );
    for (final childDirectory in childDirectories) {
      try {
        await childDirectory.delete();
      } catch (_) {}
    }
  }

  String _resourceFilePath(LocalResourceEntry resource) {
    return LocalFilePathNormalizer.normalize(resource.path);
  }

  String _titleFor(CacheCategory category) {
    switch (category) {
      case CacheCategory.image:
        return '图片展示缓存';
      case CacheCategory.artwork:
        return '曲目封面缓存';
      case CacheCategory.playback:
        return '播放音频缓存';
      case CacheCategory.temporary:
        return '临时文件';
    }
  }

  String _descriptionFor(CacheCategory category) {
    switch (category) {
      case CacheCategory.image:
        return '页面图片加载后写入的本地图片文件';
      case CacheCategory.artwork:
        return '曲目封面预缓存文件，可重新按需生成';
      case CacheCategory.playback:
        return '在线播放时保留的音频缓存，不包含正式下载';
      case CacheCategory.temporary:
        return '系统分配给应用的临时目录内容';
    }
  }
}
