import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';
import 'package:bujuan/features/playlist/playlist_artwork_color_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylistArtworkColorService', () {
    test('resolves mixed-case remote artwork through image cache', () async {
      final imageCacheRepository = _FakeLocalImageCacheRepository({
        'HTTPS://img.test/playlist.jpg': '/cache/playlist.jpg',
      });
      final service = PlaylistArtworkColorService(
        imageCacheRepository: imageCacheRepository,
      );

      final colorPath = await service.resolveColorPath(
        'HTTPS://img.test/playlist.jpg',
      );

      expect(colorPath, '/cache/playlist.jpg');
      expect(imageCacheRepository.resolvedSources, [
        'HTTPS://img.test/playlist.jpg',
      ]);
    });
  });
}

class _FakeLocalImageCacheRepository extends LocalImageCacheRepository {
  _FakeLocalImageCacheRepository(this.paths);

  final Map<String, String> paths;
  final List<String> resolvedSources = [];

  @override
  Future<String> resolveImagePath(String imageUrl) async {
    resolvedSources.add(imageUrl);
    return paths[imageUrl] ?? imageUrl;
  }
}
