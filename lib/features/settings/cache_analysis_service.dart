import 'dart:io';

import 'package:bujuan/core/entities/track.dart';
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
      await _analyzeDirectory(
        CacheCategory.artwork,
        Directory('${supportDirectory.path}/zmusic/artwork-cache'),
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
        await _clearDirectory(Directory('${supportDirectory.path}/zmusic/artwork-cache'));
        await _resourceIndexRepository.removeResourcesByOrigin(
          TrackResourceOrigin.artworkCache,
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
