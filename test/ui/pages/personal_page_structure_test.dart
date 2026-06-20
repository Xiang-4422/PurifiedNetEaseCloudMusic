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
}
