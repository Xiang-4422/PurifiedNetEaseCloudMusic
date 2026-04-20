import 'package:audio_service/audio_service.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/widget/artwork_display.dart';
import 'package:bujuan/widget/cover_flow/coverflow.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// CoverFlow 仍是预留组件，这个页面单独承接它的交互验证，避免把实验性 UI 混进主流程。
///
/// 数据直接取当前播放列表里的封面，能让我们验证：
/// 1. 组件在真实音乐数据上的表现；
/// 2. 本地封面优先链路是否能被 `CoverFlow` 正常消费；
/// 3. 后续如果把它重新接回播放页，不需要再临时造假数据。
class CoverFlowDemoPageView extends StatefulWidget {
  const CoverFlowDemoPageView({super.key});

  @override
  State<CoverFlowDemoPageView> createState() => _CoverFlowDemoPageViewState();
}

class _CoverFlowDemoPageViewState extends State<CoverFlowDemoPageView> {
  bool _enableListViewScrolling = false;
  double _cardSize = 280;

  List<Widget> _buildCoverWidgets(List<MediaItem> queue) {
    return queue.asMap().entries.map((entry) {
      final mediaItem = entry.value;
      final imageUrl = ArtworkDisplay.resolvePreferredArtwork(
        mediaItem.extras?['image'] as String?,
        fallbackItems: [mediaItem],
      );
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: .12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SimpleExtendedImage(
                imageUrl ?? '',
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: .18),
                      Colors.black.withValues(alpha: .72),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mediaItem.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${mediaItem.artist ?? '未知歌手'} · ${entry.key + 1}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final playerController = PlayerController.to;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoverFlow Demo'),
      ),
      body: SafeArea(
        child: Obx(() {
          final runtimeState = playerController.runtimeState.value;
          final queue = runtimeState.queue
              .where((item) {
                final artwork = ArtworkDisplay.resolvePreferredArtwork(
                  item.extras?['image'] as String?,
                  fallbackItems: [item],
                );
                return artwork?.isNotEmpty == true;
              })
              .toList(growable: false);
          if (queue.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '当前播放列表没有可用封面。先播放一组歌曲，再回来查看 CoverFlow 效果。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: .7),
                  ),
                ),
              ),
            );
          }

          final coverWidgets = _buildCoverWidgets(queue);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前播放列表封面',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '共 ${queue.length} 张封面，当前播放：${runtimeState.currentSong.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: .7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _enableListViewScrolling,
                      onChanged: (value) {
                        setState(() {
                          _enableListViewScrolling = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      _enableListViewScrolling ? '滚动模式' : '翻页模式',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: .7),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        min: 220,
                        max: 340,
                        divisions: 6,
                        value: _cardSize,
                        label: '${_cardSize.round()}',
                        onChanged: (value) {
                          setState(() {
                            _cardSize = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                  child: CoverFlow(
                    images: coverWidgets,
                    cardSize: _cardSize,
                    enableListViewScrolling: _enableListViewScrolling,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
