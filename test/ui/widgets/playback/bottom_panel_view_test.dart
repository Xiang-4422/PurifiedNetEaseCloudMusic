import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bottom panel mini player helpers', () {
    test('builds expand control label with title and artist', () {
      expect(
        miniPlayerExpandControlLabel(
          title: 'Song',
          artist: 'Artist',
        ),
        '打开播放器：Song - Artist',
      );
    });

    test('builds expand control label with fallbacks', () {
      expect(
        miniPlayerExpandControlLabel(title: '  ', artist: '  '),
        '打开播放器：当前歌曲',
      );
      expect(
        miniPlayerExpandControlLabel(title: 'Song'),
        '打开播放器：Song',
      );
    });

    test('builds play pause control label', () {
      expect(miniPlayerPlayPauseControlLabel(isPlaying: false), '播放');
      expect(miniPlayerPlayPauseControlLabel(isPlaying: true), '暂停');
    });
  });
}
