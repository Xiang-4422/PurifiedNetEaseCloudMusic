import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/generated/assets.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

/// Lottie 动画资源预览页。
class LottiePreviewPageView extends StatefulWidget {
  /// 创建 Lottie 动画资源预览页。
  const LottiePreviewPageView({super.key});

  @override
  State<LottiePreviewPageView> createState() => _LottiePreviewPageViewState();
}

class _LottiePreviewPageViewState extends State<LottiePreviewPageView> {
  late final Future<List<String>> _assetFuture = _loadLottieAssets();

  Future<List<String>> _loadLottieAssets() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().where(_isLottieAsset).toList()..sort();
  }

  bool _isLottieAsset(String path) {
    return path.startsWith(Assets.lottieDirectory) && path.endsWith('.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lottie 预览'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<List<String>>(
        future: _assetFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done && snapshot.data == null) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return const ErrorView();
          }
          final assets = snapshot.data ?? const [];
          if (assets.isEmpty) {
            return const EmptyView();
          }
          return GridView.builder(
            padding: EdgeInsets.only(
              left: AppDimensions.paddingSmall,
              right: AppDimensions.paddingSmall,
              bottom: AppDimensions.paddingSmall + MediaQuery.paddingOf(context).bottom,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 240,
              crossAxisSpacing: AppDimensions.paddingSmall,
              mainAxisSpacing: AppDimensions.paddingSmall,
            ),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              return _LottiePreviewCard(assetPath: assets[index]);
            },
          );
        },
      ),
    );
  }
}

class _LottiePreviewCard extends StatelessWidget {
  const _LottiePreviewCard({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final fileName = assetPath.split('/').last;
    return Material(
      color: Colors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Lottie.asset(
                assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            color: Colors.black.withValues(alpha: 0.04),
            child: Text(
              fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
