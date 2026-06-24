import 'dart:convert';

import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/track_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as drift_db;
import 'package:drift/drift.dart' as drift;
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

    test('normalizes persisted track keys and rejects blank track ids', () async {
      await dao.saveTracks([
        _track(
          id: ' netease:1 ',
          albumId: ' album-1 ',
          artistIds: const [' artist-1 ', ' ', 'artist-1', ' artist-2 '],
          metadata: const {
            'albumId': ' legacy-album ',
            'artistIds': [' legacy-artist '],
            'custom': 'keep',
          },
        ),
        _track(id: '   '),
      ]);
      await dao.saveLyrics(
        ' netease:1 ',
        const TrackLyrics(main: 'main', translated: 'translated'),
      );

      final track = await dao.getTrack(' netease:1 ');
      final byIds = await dao.getTracksByIds(const [' ', ' netease:1 ', 'netease:1']);
      final albumTracks = await dao.getTracksByAlbumId(' album-1 ');
      final artistTracks = await dao.getTracksByArtistId(' artist-2 ');
      final lyrics = await dao.getLyrics(' netease:1 ');
      final trackRows = await database.select(database.tracks).get();
      final artistRefs = await (database.select(database.trackArtistRefs)
            ..orderBy([
              (tbl) => drift.OrderingTerm.asc(tbl.sortOrder),
            ]))
          .get();

      expect(trackRows.map((row) => row.trackId), ['netease:1']);
      expect(trackRows.single.albumSourceId, 'album-1');
      expect(track?.id, 'netease:1');
      expect(track?.albumId, 'album-1');
      expect(track?.artistIds, ['artist-1', 'artist-2']);
      expect(track?.metadata, {'custom': 'keep'});
      expect(byIds.map((item) => item.id), ['netease:1']);
      expect(albumTracks.map((item) => item.id), ['netease:1']);
      expect(artistTracks.map((item) => item.id), ['netease:1']);
      expect(lyrics?.main, 'main');
      expect(lyrics?.translated, 'translated');
      expect(
        artistRefs
            .map(
              (row) => (
                trackId: row.trackId,
                artistSourceId: row.artistSourceId,
                sortOrder: row.sortOrder,
              ),
            )
            .toList(),
        [
          (trackId: 'netease:1', artistSourceId: 'artist-1', sortOrder: 0),
          (trackId: 'netease:1', artistSourceId: 'artist-2', sortOrder: 1),
        ],
      );

      await dao.removeLyrics(' netease:1 ');
      expect(await dao.getLyrics('netease:1'), isNull);

      await dao.removeTrack(' netease:1 ');
      expect(await dao.getTrack('netease:1'), isNull);
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

    test('normalizes album and artist ids at persistence boundary', () async {
      await dao.saveAlbums([
        _album(id: ' album-1 '),
        _album(id: '  '),
      ]);
      await dao.saveArtists([
        _artist(id: ' artist-1 '),
        _artist(id: '  '),
      ]);

      final album = await dao.getAlbum(' album-1 ');
      final artist = await dao.getArtist(' artist-1 ');
      final albumRows = await database.select(database.albums).get();
      final artistRows = await database.select(database.artists).get();

      expect(albumRows.map((row) => row.albumId), ['album-1']);
      expect(artistRows.map((row) => row.artistId), ['artist-1']);
      expect(album?.id, 'album-1');
      expect(artist?.id, 'artist-1');
      expect(await dao.getAlbum('  '), isNull);
      expect(await dao.getArtist('  '), isNull);
    });
  });
}

Track _track({
  String id = 'netease:1',
  String? albumId,
  List<String> artistIds = const [],
  Map<String, Object?> metadata = const {},
}) {
  return Track(
    id: id,
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

AlbumEntity _album({required String id}) {
  return AlbumEntity(
    id: id,
    sourceType: SourceType.netease,
    sourceId: '1',
    title: 'Album',
    artistNames: const ['Artist'],
  );
}

ArtistEntity _artist({required String id}) {
  return ArtistEntity(
    id: id,
    sourceType: SourceType.netease,
    sourceId: '1',
    name: 'Artist',
  );
}
