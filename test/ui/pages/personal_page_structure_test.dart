import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('personal page keeps continue playback as the first quick start action', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final continueIndex = source.indexOf('_ContinuePlaybackQuickStartCard(');
    final squareContinueIndex = source.indexOf('_ContinuePlaybackQuickStartCard(', continueIndex + 1);
    final dailyIndex = source.indexOf('title: "每日推荐"');
    final squareDailyIndex = source.indexOf("title: '每日推荐'");

    expect(continueIndex, isNonNegative);
    expect(squareContinueIndex, isNonNegative);
    expect(dailyIndex, isNonNegative);
    expect(squareDailyIndex, isNonNegative);
    expect(continueIndex, lessThan(dailyIndex));
    expect(squareContinueIndex, lessThan(squareDailyIndex));
  });

  test('personal page exposes focused library shortcuts before recommendations', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final libraryIndex = source.indexOf("'资料库'");
    final squareLibraryIndex = source.indexOf("'资料库'", libraryIndex + 1);
    final recommendedIndex = source.indexOf("'推荐歌单'");

    expect(libraryIndex, isNonNegative);
    expect(squareLibraryIndex, isNonNegative);
    expect(recommendedIndex, isNonNegative);
    expect(libraryIndex, lessThan(recommendedIndex));
    expect(source, contains("label: '本地音乐'"));
    expect(source, contains("label: '已下载'"));
    expect(source, contains("label: '云盘'"));
    expect(source, contains('DownloadTaskPageView.tabLocalImport'));
    expect(source, contains('DownloadTaskPageView.tabDownloaded'));
    expect(source, contains('context.router.push(const gr.CloudDriveView())'));
  });

  test('personal page shows recent playback before the library sections', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final recentControllerIndex = source.indexOf('final recentPlaybackController = RecentPlaybackController.to;');
    final recentStripIndex = source.indexOf('child: _RecentPlaybackStrip(');
    final squareRecentStripIndex = source.indexOf('child: _RecentPlaybackStrip(', recentStripIndex + 1);
    final recentHeaderIndex = source.indexOf("'最近播放'");
    final playlistHeaderIndex = source.indexOf("'我的歌单'");
    final squarePlaylistHeaderIndex = source.indexOf("'我的歌单'", playlistHeaderIndex + 1);

    expect(recentControllerIndex, isNonNegative);
    expect(recentStripIndex, isNonNegative);
    expect(squareRecentStripIndex, isNonNegative);
    expect(recentHeaderIndex, isNonNegative);
    expect(playlistHeaderIndex, isNonNegative);
    expect(squarePlaylistHeaderIndex, isNonNegative);
    expect(recentStripIndex, lessThan(playlistHeaderIndex));
    expect(squareRecentStripIndex, lessThan(squarePlaylistHeaderIndex));
    expect(source, contains("playListName: '最近播放'"));
    expect(source, isNot(contains('watchCurrentSong')));
  });

  test('download task page can open a focused local library tab', () {
    final source = File('lib/ui/pages/download/download_task_page_view.dart').readAsStringSync();

    expect(source, contains('static const int tabDownloaded = 2;'));
    expect(source, contains('static const int tabLocalImport = 3;'));
    expect(source, contains('final int initialTabIndex;'));
    expect(source, contains('initialIndex: widget.initialTabIndex'));
  });
}
