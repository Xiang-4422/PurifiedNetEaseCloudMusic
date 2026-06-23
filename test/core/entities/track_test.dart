import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Track', () {
    test('resolves album and artist ids from explicit fields first', () {
      const track = Track(
        id: 'netease:1',
        sourceType: SourceType.netease,
        sourceId: '1',
        title: 'Track',
        albumId: 'explicit-album',
        artistIds: ['explicit-artist'],
        metadata: {
          'albumId': 'legacy-album',
          'artistIds': ['legacy-artist'],
        },
      );

      expect(track.resolvedAlbumId, 'explicit-album');
      expect(track.resolvedArtistIds, ['explicit-artist']);
    });

    test('resolves legacy metadata ids when explicit fields are empty', () {
      const track = Track(
        id: 'netease:1',
        sourceType: SourceType.netease,
        sourceId: '1',
        title: 'Track',
        metadata: {
          'albumId': 20,
          'artistIds': [10, '11', ''],
        },
      );

      expect(track.resolvedAlbumId, '20');
      expect(track.resolvedArtistIds, ['10', '11']);
    });
  });
}
