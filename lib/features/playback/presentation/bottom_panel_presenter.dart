import 'package:bujuan/domain/entities/playback_queue_item.dart';

/// 底部播放面板的展示计算入口，先承接纯展示派生数据。
class BottomPanelPresenter {
  /// 创建 BottomPanelPresenter。
  const BottomPanelPresenter();

  /// progressText。
  String progressText(Duration currentPosition, Duration? duration) {
    final total = duration ?? Duration.zero;
    return '${_formatDuration(currentPosition)} / ${_formatDuration(total)}';
  }

  /// isCurrentQueueItem。
  bool isCurrentQueueItem({
    required int currentIndex,
    required int itemIndex,
  }) {
    return currentIndex == itemIndex;
  }

  /// artistEntries。
  List<BottomPanelArtistEntry> artistEntries(PlaybackQueueItem item) {
    final names = item.artistNames;
    final ids = item.artistIds;
    return [
      for (var i = 0; i < names.length; i++)
        BottomPanelArtistEntry(
          name: names[i],
          id: i < ids.length ? ids[i] : '',
        ),
    ];
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// BottomPanelArtistEntry。
class BottomPanelArtistEntry {
  /// 创建 BottomPanelArtistEntry。
  const BottomPanelArtistEntry({
    required this.name,
    required this.id,
  });

  /// name。
  final String name;

  /// id。
  final String id;
}
