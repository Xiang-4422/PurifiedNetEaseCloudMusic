import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/core/entities/playback_order_mode.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart';
import 'package:bujuan/ui/widgets/common/progress/circular_playback_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bottom panel playback control helpers', () {
    test('builds like button semantics label', () {
      expect(playbackLikeControlLabel(isLiked: false), '喜欢歌曲');
      expect(playbackLikeControlLabel(isLiked: true), '取消喜欢');
    });

    test('builds play pause button semantics label', () {
      expect(playbackPlayPauseControlLabel(isPlaying: false), '播放');
      expect(playbackPlayPauseControlLabel(isPlaying: true), '暂停');
    });

    test('builds progress bar semantics label', () {
      expect(
        playbackProgressSemanticsLabel(
          position: const Duration(minutes: 1, seconds: 5),
          total: const Duration(minutes: 3, seconds: 9),
        ),
        '播放进度：01:05 / 03:09',
      );
      expect(
        playbackProgressSemanticsLabel(
          position: const Duration(seconds: -5),
          total: const Duration(minutes: 3),
        ),
        '播放进度：00:00 / 03:00',
      );
      expect(
        playbackProgressSemanticsLabel(
          position: const Duration(minutes: 5),
          total: const Duration(minutes: 3),
        ),
        '播放进度：03:00 / 03:00',
      );
      expect(
        playbackProgressSemanticsLabel(
          position: const Duration(seconds: 5),
          total: null,
        ),
        '播放进度：00:05 / 未知时长',
      );
      expect(
        playbackProgressSemanticsLabel(
          position: const Duration(seconds: 5),
          total: Duration.zero,
        ),
        '播放进度：00:05 / 未知时长',
      );
    });

    test('builds quality button semantics label', () {
      expect(
        playbackQualityControlLabel(preferHighQuality: false),
        '音质：标准音质',
      );
      expect(
        playbackQualityControlLabel(preferHighQuality: true),
        '音质：高音质优先',
      );
    });

    test('builds playback mode button semantics label', () {
      expect(
        playbackModeControlLabel(
          playbackMode: PlaybackMode.roaming,
          orderMode: PlaybackOrderMode.sequential,
          repeatMode: PlaybackRepeatMode.all,
        ),
        '播放模式：私人 FM',
      );
      expect(
        playbackModeControlLabel(
          playbackMode: PlaybackMode.heartbeat,
          orderMode: PlaybackOrderMode.sequential,
          repeatMode: PlaybackRepeatMode.all,
        ),
        '播放模式：心动模式',
      );
      expect(
        playbackModeControlLabel(
          playbackMode: PlaybackMode.playlist,
          orderMode: PlaybackOrderMode.shuffle,
          repeatMode: PlaybackRepeatMode.one,
        ),
        '播放模式：随机播放',
      );
      expect(
        playbackModeControlLabel(
          playbackMode: PlaybackMode.playlist,
          orderMode: PlaybackOrderMode.sequential,
          repeatMode: PlaybackRepeatMode.one,
        ),
        '播放模式：单曲循环',
      );
      expect(
        playbackModeControlLabel(
          playbackMode: PlaybackMode.playlist,
          orderMode: PlaybackOrderMode.sequential,
          repeatMode: PlaybackRepeatMode.none,
        ),
        '播放模式：不循环',
      );
      expect(
        playbackModeControlLabel(
          playbackMode: PlaybackMode.playlist,
          orderMode: PlaybackOrderMode.sequential,
          repeatMode: PlaybackRepeatMode.all,
        ),
        '播放模式：列表循环',
      );
      expect(
        playbackModeControlLabel(
          playbackMode: PlaybackMode.playlist,
          orderMode: PlaybackOrderMode.sequential,
          repeatMode: PlaybackRepeatMode.group,
        ),
        '播放模式：分组循环',
      );
    });
  });
}
