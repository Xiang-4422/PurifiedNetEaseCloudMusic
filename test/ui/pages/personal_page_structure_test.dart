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

  test('download task page can open a focused local library tab', () {
    final source = File('lib/ui/pages/download/download_task_page_view.dart').readAsStringSync();

    expect(source, contains('static const int tabDownloaded = 2;'));
    expect(source, contains('static const int tabLocalImport = 3;'));
    expect(source, contains('final int initialTabIndex;'));
    expect(source, contains('initialIndex: widget.initialTabIndex'));
  });
}
