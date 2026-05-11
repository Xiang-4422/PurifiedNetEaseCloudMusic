import 'package:bujuan/data/music_data/sources/netease/api/client/netease_handler.dart';
import 'package:bujuan/data/music_data/sources/netease/api/endpoints/play/api.dart';
import 'package:bujuan/data/music_data/sources/netease/api/endpoints/uncategorized/api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Netease API upstream sync', () {
    late _TestNeteaseApi api;

    setUp(() {
      api = _TestNeteaseApi();
    });

    test('daily recommendation songs supports upstream afresh parameter', () {
      final metaData = api.recommendSongListDioMetaData(afresh: true);

      expect(metaData.uri.path, '/api/v3/discovery/recommend/songs');
      expect(metaData.data, {'afresh': true});
      expect(metaData.options!.extra!['cookies'], {'os': 'ios'});
    });

    test('gray song copyright recommendation uses upstream eapi endpoint', () {
      final metaData = api.songCopyrightRecommendationDioMetaData(id: '123');

      expect(metaData.uri.path, '/api/song/copyright/rcmd');
      expect(metaData.data, {'songid': '123'});
      expect(metaData.options!.extra!['encryptType'], EncryptType.EApi);
      expect(metaData.options!.extra!['eApiUrl'], '/api/song/copyright/rcmd');
    });

    test('song creators uses upstream endpoint and payload name', () {
      final metaData = api.songCreatorsDioMetaData('456');

      expect(metaData.uri.path, '/api/song/creators');
      expect(metaData.data, {'songId': '456'});
    });

    test('radio sport uses upstream default bpm', () {
      final metaData = api.radioSportDioMetaData();

      expect(metaData.uri.path, '/api/radio/sport/get');
      expect(metaData.data, {'bpm': 50});
    });

    test('sati endpoints match upstream paths and fixed parameters', () {
      expect(api.satiTagListDioMetaData().uri.path, '/api/voice/sati/tag/list');
      expect(api.satiTagListDioMetaData().data, {});

      final listMetaData = api.satiResourceListDioMetaData('rain');
      expect(listMetaData.uri.path, '/api/voice/sati/resource/list');
      expect(listMetaData.data, {'tag': 'rain', 'firstQuery': false});

      final moreMetaData = api.satiResourceListMoreDioMetaData('resource-1');
      expect(moreMetaData.uri.path, '/api/voice/sati/resource/list/more/v1');
      expect(moreMetaData.data, {'id': 'resource-1'});

      final subMetaData = api.satiResourceSubDioMetaData('resource-1', cancel: true);
      expect(subMetaData.uri.path, '/api/voice/sati/resource/sub');
      expect(subMetaData.data, {'id': 'resource-1', 'cancel': true});

      expect(api.satiResourceSubListDioMetaData().uri.path, '/api/voice/sati/resource/sub/list');
      expect(api.satiResourceSubListDioMetaData().data, {});

      final timeSceneMetaData = api.satiTimeSceneResourcesDioMetaData();
      expect(timeSceneMetaData.uri.path, '/api/voice/sati/timescene/resources/get');
      expect(timeSceneMetaData.data, {'firstQuery': false});
    });
  });
}

class _TestNeteaseApi with ApiPlay, ApiUncategorized {}
