import 'dart:io';

import 'package:bujuan/features/playlist/playlist_open_performance.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CachedPlaylistOpenSnapshot', () {
    test('stays independent from playlist page ui state', () {
      final source = File(
        'lib/features/playlist/playlist_open_performance.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('ui/pages/playlist')));
      expect(source, isNot(contains('PlaylistPageLoadState')));
      expect(source, contains('required String state'));
    });

    test('formats complete local detail with stable fields', () {
      final snapshot = CachedPlaylistOpenSnapshot.local(
        state: PlaylistLocalDetailState.complete,
        songs: 30,
        hasMetadata: true,
        expectedTracks: 30,
      );

      expect(
        snapshot.toLogDetails(),
        'source=local result=complete songs=30 state=complete hasMetadata=true expected=30',
      );
    });

    test('treats partial local detail as a playable first display', () {
      final snapshot = CachedPlaylistOpenSnapshot.local(
        state: PlaylistLocalDetailState.partial,
        songs: 30,
        hasMetadata: true,
        expectedTracks: 100,
      );

      expect(
        snapshot.toLogDetails(),
        'source=local result=partial songs=30 state=partial hasMetadata=true expected=100',
      );
    });

    test('records metadata only cache hits before remote fallback', () {
      final snapshot = CachedPlaylistOpenSnapshot.local(
        state: PlaylistLocalDetailState.empty,
        songs: 0,
        hasMetadata: true,
        expectedTracks: 42,
      );

      expect(
        snapshot.toLogDetails(),
        'source=local result=metadata_only songs=0 state=empty hasMetadata=true expected=42',
      );
    });

    test('records remote fallback states without importing page state enums', () {
      expect(
        CachedPlaylistOpenSnapshot.remote(
          songs: 12,
          state: 'showingPartial',
          hasMetadata: true,
          expectedTracks: 100,
        ).toLogDetails(),
        'source=remote result=partial songs=12 state=showingPartial hasMetadata=true expected=100',
      );
      expect(
        CachedPlaylistOpenSnapshot.remote(
          songs: 0,
          state: 'loadFailedEmpty',
          hasMetadata: false,
        ).toLogDetails(),
        'source=remote result=error songs=0 state=loadFailedEmpty hasMetadata=false',
      );
    });
  });
}
