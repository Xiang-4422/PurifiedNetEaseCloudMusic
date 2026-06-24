import 'package:bujuan/features/music_detail/local_first_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalFirstDetailController', () {
    test('loads initial detail from local cache and marks background refresh', () async {
      final controller = LocalFirstDetailController<String>(
        loadLocalDetail: ({required id, required likedSongIds}) async => 'local:$id:${likedSongIds.join(',')}',
        fetchRemoteDetail: ({required id, required likedSongIds}) async => 'remote:$id',
        likedSongIds: () => const [2, 1, 2],
      );

      final initialData = await controller.loadInitialDetail('detail-1');

      expect(initialData.localDetail, 'local:detail-1:1,2');
      expect(initialData.hasLocalDetail, isTrue);
      expect(initialData.shouldRefreshInBackground, isTrue);
    });

    test('treats local cache errors as empty local detail', () async {
      final controller = LocalFirstDetailController<String>(
        loadLocalDetail: ({required id, required likedSongIds}) async {
          throw StateError('broken cache');
        },
        fetchRemoteDetail: ({required id, required likedSongIds}) async => 'remote:$id',
        likedSongIds: () => const [1],
      );

      final initialData = await controller.loadInitialDetail('detail-1');

      expect(initialData.localDetail, isNull);
      expect(initialData.hasLocalDetail, isFalse);
      expect(initialData.shouldRefreshInBackground, isFalse);
    });

    test('passes normalized liked song ids to remote fetch', () async {
      final controller = LocalFirstDetailController<String>(
        loadLocalDetail: ({required id, required likedSongIds}) async => null,
        fetchRemoteDetail: ({required id, required likedSongIds}) async {
          return '$id:${likedSongIds.join(',')}';
        },
        likedSongIds: () => const [3, 1, 3, 2],
      );

      await expectLater(
        controller.fetchDetail('detail-1'),
        completion('detail-1:1,2,3'),
      );
    });
  });
}
