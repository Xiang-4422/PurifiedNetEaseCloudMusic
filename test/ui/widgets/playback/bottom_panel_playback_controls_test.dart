import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart';
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
  });
}
