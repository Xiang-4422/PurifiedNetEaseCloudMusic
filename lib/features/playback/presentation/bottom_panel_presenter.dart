import 'package:bujuan/domain/entities/playback_queue_item.dart';

/// 底部播放面板的展示计算入口，先承接纯展示派生数据。
class BottomPanelPresenter {
  /// 创建底部播放面板展示计算器。
  const BottomPanelPresenter();

  /// 格式化当前进度和总时长文本。
  String progressText(Duration currentPosition, Duration? duration) {
    final total = duration ?? Duration.zero;
    return '${_formatDuration(currentPosition)} / ${_formatDuration(total)}';
  }

  /// 判断列表项是否为当前播放队列项。
  bool isCurrentQueueItem({
    required int currentIndex,
    required int itemIndex,
  }) {
    return currentIndex == itemIndex;
  }

  /// 将队列项中的歌手名称和 id 组合成展示条目。
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

/// 底部播放面板歌手入口展示数据。
class BottomPanelArtistEntry {
  /// 创建歌手入口展示数据。
  const BottomPanelArtistEntry({
    required this.name,
    required this.id,
  });

  /// 歌手名称。
  final String name;

  /// 歌手 id；本地或缺失数据时可能为空。
  final String id;
}
