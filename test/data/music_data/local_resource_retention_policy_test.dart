import 'dart:io';

import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_retention_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalResourceRetentionPolicy', () {
    test('normalizes retained local paths and skips removed resources', () async {
      final directory = await Directory.systemTemp.createTemp('resource-retention-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final sharedFile = File('${directory.path}/shared with space.mp3');
      final removedFile = File('${directory.path}/removed.mp3');
      const remoteUrl = 'https://audio.test/cache.mp3';

      final retainedPaths = LocalResourceRetentionPolicy.retainedPathsAfterRemoving(
        [
          _resource(
            trackId: 'remove',
            path: removedFile.path,
            origin: TrackResourceOrigin.playbackCache,
          ),
          _resource(
            trackId: 'keep',
            path: sharedFile.uri.replace(queryParameters: {'token': 'legacy'}).toString(),
            origin: TrackResourceOrigin.managedDownload,
          ),
          _resource(
            trackId: 'remote',
            path: remoteUrl,
            origin: TrackResourceOrigin.managedDownload,
          ),
        ],
        shouldRemove: (resource) => resource.trackId == 'remove',
      );

      expect(retainedPaths, {sharedFile.path});
    });

    test('protects retained local files before deletion', () async {
      final directory = await Directory.systemTemp.createTemp('resource-delete-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final sharedFile = File('${directory.path}/shared.mp3');
      final ownedFile = File('${directory.path}/owned.mp3');
      final retainedPaths = {sharedFile.path};

      expect(
        LocalResourceRetentionPolicy.shouldDeleteResourceFile(
          _resource(
            trackId: 'shared',
            path: sharedFile.uri.toString(),
            origin: TrackResourceOrigin.playbackCache,
          ),
          retainedPaths,
          deleteSourceFiles: true,
        ),
        isFalse,
      );
      expect(
        LocalResourceRetentionPolicy.shouldDeleteResourceFile(
          _resource(
            trackId: 'owned',
            path: ownedFile.path,
            origin: TrackResourceOrigin.playbackCache,
          ),
          retainedPaths,
          deleteSourceFiles: true,
        ),
        isTrue,
      );
      expect(
        LocalResourceRetentionPolicy.shouldDeleteResourceFile(
          _resource(
            trackId: 'remote',
            path: 'https://audio.test/owned.mp3',
            origin: TrackResourceOrigin.playbackCache,
          ),
          retainedPaths,
          deleteSourceFiles: true,
        ),
        isFalse,
      );
      expect(
        LocalResourceRetentionPolicy.shouldDeleteResourceFile(
          _resource(
            trackId: 'owned',
            path: ownedFile.path,
            origin: TrackResourceOrigin.playbackCache,
          ),
          retainedPaths,
          deleteSourceFiles: false,
        ),
        isFalse,
      );
    });
  });
}

LocalResourceEntry _resource({
  required String trackId,
  required String path,
  required TrackResourceOrigin origin,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: trackId,
    kind: LocalResourceKind.audio,
    path: path,
    origin: origin,
    sizeBytes: 0,
    createdAt: now,
    lastAccessedAt: now,
  );
}
