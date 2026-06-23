import 'package:bujuan/features/settings/cache_analysis_service.dart';

export 'cache_analysis_service.dart' show CacheAnalysisResult, CacheCategory, CacheCategoryAnalysis;

/// 设置页缓存分析和清理的页面级控制器。
class CacheAnalysisController {
  /// 创建缓存分析控制器。
  const CacheAnalysisController({
    required CacheAnalysisService service,
  }) : _service = service;

  final CacheAnalysisService _service;

  /// 分析当前可安全清理的缓存。
  Future<CacheAnalysisResult> analyze() {
    return _service.analyze();
  }

  /// 清理指定缓存分类。
  Future<void> clear(CacheCategory category) {
    return _service.clear(category);
  }

  /// 清理全部可安全清理的缓存。
  Future<void> clearAll() {
    return _service.clearAll();
  }

  /// 返回缓存分类标题，用于确认弹窗。
  String titleFor(CacheCategory category) {
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
}

/// 创建设置页缓存分析控制器。
class CacheAnalysisControllerFactory {
  /// 创建缓存分析控制器工厂。
  const CacheAnalysisControllerFactory({
    required CacheAnalysisService service,
  }) : _service = service;

  final CacheAnalysisService _service;

  /// 创建页面拥有的缓存分析控制器。
  CacheAnalysisController create() {
    return CacheAnalysisController(service: _service);
  }
}
