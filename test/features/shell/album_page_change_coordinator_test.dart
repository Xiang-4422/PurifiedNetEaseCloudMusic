import 'package:bujuan/features/shell/album_page_change_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlbumPageChangeCoordinator', () {
    test('records page changes without playing until commit', () async {
      final coordinator = AlbumPageChangeCoordinator();
      final playedIndexes = <int>[];

      coordinator.recordPageChange(2, isProgrammatic: false);

      expect(playedIndexes, isEmpty);

      final committed = await coordinator.commit(
        currentIndex: 0,
        queueLength: 4,
        settledPage: 2,
        playIndex: (index) async => playedIndexes.add(index),
      );

      expect(committed, isTrue);
      expect(playedIndexes, [2]);
    });

    test('ignores programmatic page changes', () async {
      final coordinator = AlbumPageChangeCoordinator();
      final playedIndexes = <int>[];

      coordinator.recordPageChange(1, isProgrammatic: true);

      final committed = await coordinator.commit(
        currentIndex: 0,
        queueLength: 3,
        settledPage: 1,
        playIndex: (index) async => playedIndexes.add(index),
      );

      expect(committed, isFalse);
      expect(playedIndexes, isEmpty);
    });

    test('waits until page is settled before committing', () async {
      final coordinator = AlbumPageChangeCoordinator();
      final playedIndexes = <int>[];

      coordinator.recordPageChange(2, isProgrammatic: false);

      final firstCommit = await coordinator.commit(
        currentIndex: 0,
        queueLength: 4,
        settledPage: 1.5,
        playIndex: (index) async => playedIndexes.add(index),
      );
      final secondCommit = await coordinator.commit(
        currentIndex: 0,
        queueLength: 4,
        settledPage: 2.0,
        playIndex: (index) async => playedIndexes.add(index),
      );

      expect(firstCommit, isFalse);
      expect(secondCommit, isTrue);
      expect(playedIndexes, [2]);
    });
  });
}
