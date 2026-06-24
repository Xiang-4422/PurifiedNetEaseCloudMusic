import 'package:bujuan/data/music_data/sources/local/database/dao/cache_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as drift_db;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CacheDao', () {
    late drift_db.BujuanDriftDatabase database;
    late CacheDao dao;

    setUp(() {
      database = drift_db.BujuanDriftDatabase.connect(NativeDatabase.memory());
      dao = CacheDao(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('normalizes cache keys before saving, loading, and deleting entries', () async {
      await dao.save(cacheKey: ' SEARCH_HOT_KEYWORDS ', payloadJson: '["a"]');

      final record = await dao.load(' SEARCH_HOT_KEYWORDS ');
      final rows = await database.select(database.appCacheEntries).get();

      expect(record?.cacheKey, 'SEARCH_HOT_KEYWORDS');
      expect(record?.payloadJson, '["a"]');
      expect(rows.map((row) => row.cacheKey), ['SEARCH_HOT_KEYWORDS']);

      await dao.delete(' SEARCH_HOT_KEYWORDS ');

      expect(await dao.load('SEARCH_HOT_KEYWORDS'), isNull);
      expect(await database.select(database.appCacheEntries).get(), isEmpty);
    });

    test('normalizes cache key prefixes before deleting matching entries', () async {
      await dao.save(cacheKey: ' COMMENT_LIST:1 ', payloadJson: '{"page":1}');
      await dao.save(cacheKey: 'COMMENT_LIST:2', payloadJson: '{"page":2}');
      await dao.save(cacheKey: 'FLOOR_COMMENT:1', payloadJson: '{"page":1}');

      await dao.deleteByPrefix(' COMMENT_LIST ');

      final rows = await database.select(database.appCacheEntries).get();
      expect(rows.map((row) => row.cacheKey), ['FLOOR_COMMENT:1']);
    });

    test('ignores blank cache keys and prefixes before touching cache table', () async {
      await dao.save(cacheKey: 'KEEP', payloadJson: '{}');
      await dao.save(cacheKey: '   ', payloadJson: '{"bad":true}');
      await dao.delete('   ');
      await dao.deleteByPrefix('   ');

      expect(await dao.load('   '), isNull);
      final rows = await database.select(database.appCacheEntries).get();
      expect(rows.map((row) => row.cacheKey), ['KEEP']);
    });
  });
}
