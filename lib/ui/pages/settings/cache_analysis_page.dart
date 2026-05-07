import 'package:bujuan/app/ui/dialog_service.dart';
import 'package:bujuan/app/ui/toast_service.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/settings/cache_analysis_service.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

/// 缓存分析与清理页面。
class CacheAnalysisPageView extends StatefulWidget {
  /// 创建缓存分析页面。
  const CacheAnalysisPageView({super.key});

  @override
  State<CacheAnalysisPageView> createState() => _CacheAnalysisPageViewState();
}

class _CacheAnalysisPageViewState extends State<CacheAnalysisPageView> {
  late final CacheAnalysisService _service;
  late Future<CacheAnalysisResult> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _service = Get.find<CacheAnalysisService>();
    _analysisFuture = _service.analyze();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('缓存分析'),
        actions: [
          IconButton(
            tooltip: '重新分析',
            onPressed: _reload,
            icon: const Icon(TablerIcons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<CacheAnalysisResult>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && data == null) {
            return _CacheErrorView(onRetry: _reload);
          }
          return _CacheAnalysisContent(
            result: data ?? const CacheAnalysisResult(categories: []),
            onClearCategory: _clearCategory,
            onClearAll: _clearAll,
          );
        },
      ),
    );
  }

  void _reload() {
    setState(() {
      _analysisFuture = _service.analyze();
    });
  }

  Future<void> _clearCategory(CacheCategory category) async {
    final confirmed = await _confirmClear('清理${_titleFor(category)}？');
    if (!confirmed) {
      return;
    }
    if (!mounted) {
      return;
    }
    DialogService.showLoading(context);
    try {
      await _service.clear(category);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ToastService.show('缓存已清理');
      _reload();
    } catch (_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ToastService.show('缓存清理失败');
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await _confirmClear('清理全部可安全清理的缓存？');
    if (!confirmed) {
      return;
    }
    if (!mounted) {
      return;
    }
    DialogService.showLoading(context);
    try {
      await _service.clearAll();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ToastService.show('缓存已清理');
      _reload();
    } catch (_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ToastService.show('缓存清理失败');
    }
  }

  Future<bool> _confirmClear(String title) async {
    if (!mounted) {
      return false;
    }
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: const Text('该操作不会删除正式下载和本地导入的音乐。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('清理'),
                ),
              ],
            );
          },
        ) ??
        false;
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
}

class _CacheAnalysisContent extends StatelessWidget {
  const _CacheAnalysisContent({
    required this.result,
    required this.onClearCategory,
    required this.onClearAll,
  });

  final CacheAnalysisResult result;
  final Future<void> Function(CacheCategory category) onClearCategory;
  final Future<void> Function() onClearAll;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingSmall,
        right: AppDimensions.paddingSmall,
        bottom: AppDimensions.bottomPanelHeaderHeight,
      ),
      children: [
        const Header('缓存概览'),
        _CacheSummaryCard(result: result),
        const Header('缓存分类'),
        for (final category in result.categories)
          _CacheCategoryTile(
            analysis: category,
            onClear: () => onClearCategory(category.category),
          ),
        const SizedBox(height: AppDimensions.paddingMedium),
        FilledButton.icon(
          onPressed: result.totalSizeBytes > 0 ? onClearAll : null,
          icon: const Icon(TablerIcons.trash),
          label: const Text('清理全部缓存'),
        ),
      ],
    );
  }
}

class _CacheSummaryCard extends StatelessWidget {
  const _CacheSummaryCard({required this.result});

  final CacheAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            const Icon(TablerIcons.database, size: 36),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatBytes(result.totalSizeBytes),
                    style: context.textTheme.headlineSmall,
                  ),
                  Text(
                    '${result.totalFileCount} 个缓存文件',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).cardColor.withValues(alpha: .55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CacheCategoryTile extends StatelessWidget {
  const _CacheCategoryTile({
    required this.analysis,
    required this.onClear,
  });

  final CacheCategoryAnalysis analysis;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final canClear = analysis.sizeBytes > 0 || analysis.fileCount > 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        analysis.title,
        style: context.textTheme.titleLarge,
      ),
      subtitle: Text(
        '${analysis.description}\n${_formatBytes(analysis.sizeBytes)} · ${analysis.fileCount} 个文件',
        style: context.textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).cardColor.withValues(alpha: .5),
        ),
      ),
      isThreeLine: true,
      trailing: IconButton(
        tooltip: '清理',
        onPressed: canClear ? onClear : null,
        icon: const Icon(TablerIcons.trash),
      ),
    );
  }
}

class _CacheErrorView extends StatelessWidget {
  const _CacheErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(TablerIcons.refresh),
        label: const Text('缓存分析失败，点击重试'),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  final kb = bytes / 1024;
  if (kb < 1024) {
    return '${kb.toStringAsFixed(1)} KB';
  }
  final mb = kb / 1024;
  if (mb < 1024) {
    return '${mb.toStringAsFixed(1)} MB';
  }
  return '${(mb / 1024).toStringAsFixed(1)} GB';
}
