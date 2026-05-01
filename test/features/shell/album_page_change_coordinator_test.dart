import 'package:bujuan/features/shell/album_page_change_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlbumPageChangeCoordinator', () {
    test('commits user page changes immediately', () async {
      final coordinator = AlbumPageChangeCoordinator();
      final playedIndexes = <int>[];

      final committed = await coordinator.commitPageChange(
        index: 2,
        isProgrammatic: false,
        currentIndex: 0,
        queueLength: 4,
        playIndex: (index) async => playedIndexes.add(index),
      );

      expect(committed, isTrue);
      expect(playedIndexes, [2]);
    });

    test('ignores programmatic page changes', () async {
      final coordinator = AlbumPageChangeCoordinator();
      final playedIndexes = <int>[];

      final committed = await coordinator.commitPageChange(
        index: 1,
        isProgrammatic: true,
        currentIndex: 0,
        queueLength: 3,
        playIndex: (index) async => playedIndexes.add(index),
      );

      expect(committed, isFalse);
      expect(playedIndexes, isEmpty);
    });

    test('ignores invalid or current indexes', () async {
      final coordinator = AlbumPageChangeCoordinator();
      final playedIndexes = <int>[];

      final invalidCommit = await coordinator.commitPageChange(
        index: 4,
        isProgrammatic: false,
        currentIndex: 0,
        queueLength: 4,
        playIndex: (index) async => playedIndexes.add(index),
      );
      final currentCommit = await coordinator.commitPageChange(
        index: 0,
        isProgrammatic: false,
        currentIndex: 0,
        queueLength: 4,
        playIndex: (index) async => playedIndexes.add(index),
      );

      expect(invalidCommit, isFalse);
      expect(currentCommit, isFalse);
      expect(playedIndexes, isEmpty);
    });
  });
}
