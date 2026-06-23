import 'package:bujuan/features/settings/cache_analysis_controller.dart';
import 'package:bujuan/features/settings/cache_analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CacheAnalysisController', () {
    test('forwards analysis and clear commands to service boundary', () async {
      const result = CacheAnalysisResult(
        categories: [
          CacheCategoryAnalysis(
            category: CacheCategory.image,
            title: '图片展示缓存',
            description: 'description',
            sizeBytes: 10,
            fileCount: 1,
          ),
        ],
      );
      final service = _FakeCacheAnalysisService(result);
      final controller = CacheAnalysisController(service: service);

      expect(await controller.analyze(), same(result));
      await controller.clear(CacheCategory.image);
      await controller.clearAll();

      expect(service.clearCategories, [CacheCategory.image]);
      expect(service.clearAllCallCount, 1);
      expect(controller.titleFor(CacheCategory.playback), '播放音频缓存');
    });

    test('factory creates page-owned controller with injected service', () async {
      const result = CacheAnalysisResult(categories: []);
      final service = _FakeCacheAnalysisService(result);
      final factory = CacheAnalysisControllerFactory(service: service);

      final controller = factory.create();

      expect(await controller.analyze(), same(result));
    });
  });
}

class _FakeCacheAnalysisService implements CacheAnalysisService {
  _FakeCacheAnalysisService(this.result);

  final CacheAnalysisResult result;
  final List<CacheCategory> clearCategories = [];
  int clearAllCallCount = 0;

  @override
  Future<CacheAnalysisResult> analyze() async {
    return result;
  }

  @override
  Future<void> clear(CacheCategory category) async {
    clearCategories.add(category);
  }

  @override
  Future<void> clearAll() async {
    clearAllCallCount++;
  }
}
