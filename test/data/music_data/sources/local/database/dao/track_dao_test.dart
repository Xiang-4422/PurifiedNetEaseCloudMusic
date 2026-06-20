import 'dart:convert';

import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/track_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as drift_db;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrackDao', () {
    late drift_db.BujuanDriftDatabase database;
    late TrackDao dao;

    setUp(() {
      database = drift_db.BujuanDriftDatabase.connect(NativeDatabase.memory());
      dao = TrackDao(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('persists album and artist source ids from explicit track fields', () async {
      await dao.saveTracks([
        _track(
          albumId: 'album-1',
          artistIds: const ['artist-1', 'artist-2'],
          metadata: const {'custom': 'keep'},
        ),
      ]);

      final track = await dao.getTrack('netease:1');
      final albumTracks = await dao.getTracksByAlbumId('album-1');
      final artistTracks = await dao.getTracksByArtistId('artist-2');
      final row = await database.select(database.tracks).getSingle();
      final metadata = jsonDecode(row.metadataJson) as Map<String, dynamic>;

      expect(track?.albumId, 'album-1');
      expect(track?.artistIds, ['artist-1', 'artist-2']);
      expect(track?.metadata, {'custom': 'keep'});
      expect(albumTracks.map((item) => item.id), ['netease:1']);
      expect(artistTracks.map((item) => item.id), ['netease:1']);
      expect(row.albumSourceId, 'album-1');
      expect(metadata.containsKey('albumId'), isFalse);
      expect(metadata.containsKey('artistIds'), isFalse);
    });

    test('migrates legacy metadata ids into explicit track fields', () async {
      await dao.saveTracks([
        _track(
          metadata: const {
            'albumId': 'legacy-album',
            'artistIds': ['legacy-artist'],
            'custom': 'keep',
          },
        ),
      ]);

      final track = await dao.getTrack('netease:1');
      final albumTracks = await dao.getTracksByAlbumId('legacy-album');
      final artistTracks = await dao.getTracksByArtistId('legacy-artist');

      expect(track?.albumId, 'legacy-album');
      expect(track?.artistIds, ['legacy-artist']);
      expect(track?.metadata, {'custom': 'keep'});
      expect(albumTracks.map((item) => item.id), ['netease:1']);
      expect(artistTracks.map((item) => item.id), ['netease:1']);
    });
  });
}

Track _track({
  String? albumId,
  List<String> artistIds = const [],
  Map<String, Object?> metadata = const {},
}) {
  return Track(
    id: 'netease:1',
    sourceType: SourceType.netease,
    sourceId: '1',
    title: 'Track',
    artistNames: const ['Artist'],
    albumTitle: 'Album',
    albumId: albumId,
    artistIds: artistIds,
    metadata: metadata,
  );
}
