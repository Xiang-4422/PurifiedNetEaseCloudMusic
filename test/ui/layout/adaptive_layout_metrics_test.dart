import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveLayoutMetrics', () {
    test('detects square-like screens with the shared threshold', () {
      const square = AdaptiveLayoutMetrics(size: Size(600, 600));
      const phone = AdaptiveLayoutMetrics(size: Size(390, 844));

      expect(square.isSquareLike, isTrue);
      expect(phone.isSquareLike, isFalse);
      expect(
        const PersonalHomeLayoutMetrics(Size(600, 600)).isSquareLike,
        square.isSquareLike,
      );
    });

    test('clamps detail hero extent by width and safe height', () {
      const phone = AdaptiveLayoutMetrics(
        size: Size(390, 844),
        viewPadding: EdgeInsets.only(top: 44, bottom: 24),
      );
      const square = AdaptiveLayoutMetrics(size: Size(600, 600));

      expect(phone.heroExtent, lessThanOrEqualTo(390));
      expect(phone.heroExtent, lessThanOrEqualTo(phone.safeContentHeight * .55));
      expect(square.heroExtent, lessThan(600));
      expect(square.heroExtent, greaterThanOrEqualTo(160));
    });

    test('limits playback artwork by available panel height', () {
      const metrics = AdaptiveLayoutMetrics(size: Size(600, 600));

      final artworkExtent = metrics.playbackArtworkExtent(
        availableHeight: 360,
      );

      expect(artworkExtent, lessThan(600));
      expect(artworkExtent, lessThanOrEqualTo(360 * .46));
      expect(artworkExtent, greaterThan(AppDimensions.albumMinSize));
    });

    test('list tile minimum height grows with text scale', () {
      const normal = AdaptiveLayoutMetrics(size: Size(390, 844));
      const largeText = AdaptiveLayoutMetrics(
        size: Size(390, 844),
        textScale: 1.5,
      );

      expect(normal.listTileMinHeight, 52);
      expect(largeText.listTileMinHeight, greaterThan(normal.listTileMinHeight));
    });
  });
}
