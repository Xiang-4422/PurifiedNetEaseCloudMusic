import 'dart:io';

import 'package:bujuan/core/diagnostics/performance_metric.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPerformanceMetrics', () {
    test('keeps required goal metrics stable', () {
      expect(AppPerformanceMetrics.all.map((metric) => metric.key), [
        'cold_start_interactive',
        'cached_playlist_open',
        'track_switch',
        'search_first_results',
        'mini_player_feedback',
      ]);

      for (final metric in AppPerformanceMetrics.all) {
        expect(metric.eventName, isNotEmpty, reason: metric.key);
        expect(metric.label, isNotEmpty, reason: metric.key);
        expect(metric.targetMs, greaterThan(0), reason: metric.key);
        expect(metric.description, isNotEmpty, reason: metric.key);
      }
    });

    test('uses unique keys and event names', () {
      final keys = AppPerformanceMetrics.all.map((metric) => metric.key).toList();
      final events = AppPerformanceMetrics.all.map((metric) => metric.eventName).toList();

      expect(keys.toSet(), hasLength(keys.length));
      expect(events.toSet(), hasLength(events.length));
    });

    test('documents every core metric in the refactor route', () {
      final doc = File('docs/重构路线.md').readAsStringSync();

      for (final metric in AppPerformanceMetrics.all) {
        expect(doc, contains(metric.key), reason: metric.key);
        expect(doc, contains(metric.label), reason: metric.key);
        expect(doc, contains(metric.eventName), reason: metric.key);
      }
    });

    test('wires key metrics to runtime paths', () {
      expect(
        File('lib/main.dart').readAsStringSync(),
        contains('AppPerformanceMetrics.coldStartInteractive'),
      );
      expect(
        File('lib/ui/pages/playlist/playlist_page_view.dart').readAsStringSync(),
        contains('AppPerformanceMetrics.cachedPlaylistOpen'),
      );
      expect(
        File('lib/features/playback/application/playback_switch_coordinator.dart').readAsStringSync(),
        contains('AppPerformanceMetrics.trackSwitch'),
      );
      expect(
        File('lib/features/search/search_panel_controller.dart').readAsStringSync(),
        contains('AppPerformanceMetrics.searchFirstResults'),
      );
      expect(
        File('lib/features/playback/player_controller.dart').readAsStringSync(),
        contains('AppPerformanceMetrics.miniPlayerFeedback'),
      );
    });
  });
}
