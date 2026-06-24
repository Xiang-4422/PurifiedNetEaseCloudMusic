import 'package:bujuan/data/music_data/sources/netease/netease_song_detail_batch_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('planNeteaseSongDetailBatches', () {
    test('normalizes song id lists before request planning', () {
      expect(
        normalizeNeteaseSongIds(const ['  netease:1  ', ' local:skip ', '   ', '  2  ']),
        ['1', '2'],
      );
    });

    test('normalizes ids and skips blank ids before planning requests', () {
      final batches = planNeteaseSongDetailBatches(
        ids: const ['  netease:1  ', ' local:skip ', '   ', '  2  '],
      );

      expect(batches, [
        ['1', '2'],
      ]);
    });

    test('applies offset and limit after id normalization', () {
      final batches = planNeteaseSongDetailBatches(
        ids: const ['  1  ', '   ', '  2  ', '  3  '],
        offset: 1,
        limit: 1,
      );

      expect(batches, [
        ['2'],
      ]);
    });

    test('chunks requests without depending on returned track count', () {
      final batches = planNeteaseSongDetailBatches(
        ids: const ['1', 'missing', '2', '3', '4'],
        batchSize: 2,
      );

      expect(batches, [
        ['1', 'missing'],
        ['2', '3'],
        ['4'],
      ]);
    });

    test('returns empty batches for blank or out of range requests', () {
      expect(
        planNeteaseSongDetailBatches(ids: const ['   ']),
        isEmpty,
      );
      expect(
        planNeteaseSongDetailBatches(
          ids: const ['1'],
          offset: 1,
        ),
        isEmpty,
      );
      expect(
        planNeteaseSongDetailBatches(
          ids: const ['1'],
          batchSize: 0,
        ),
        isEmpty,
      );
    });
  });
}
