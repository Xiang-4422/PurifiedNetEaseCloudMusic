import 'package:bujuan/features/user/presentation/personal_home_layout_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PersonalHomeLayoutMetrics', () {
    test('detects square-like screens without matching 16:9 phones', () {
      expect(
        const PersonalHomeLayoutMetrics(Size(600, 600)).isSquareLike,
        isTrue,
      );
      expect(
        const PersonalHomeLayoutMetrics(Size(390, 844)).isSquareLike,
        isFalse,
      );
    });

    test('keeps square quick card within available bounds', () {
      const metrics = PersonalHomeLayoutMetrics(Size(600, 600));
      final size = metrics.squareQuickCardSize(
        maxWidth: 600,
        maxHeight: 360,
      );

      expect(size.width, lessThanOrEqualTo(600));
      expect(size.height, lessThanOrEqualTo(360));
      expect(size.height, greaterThanOrEqualTo(150));
    });
  });
}
