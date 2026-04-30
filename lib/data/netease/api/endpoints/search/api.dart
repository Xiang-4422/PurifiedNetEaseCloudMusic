import 'package:dio/dio.dart';

import '../../client/dio_ext.dart';
import '../../client/netease_handler.dart';
import '../../models/search/bean.dart';

/// 搜索、热搜和搜索建议相关接口。
mixin ApiSearch {
  Uri _searchUrl(bool cloudSearch) => cloudSearch
      ? joinUri('/weapi/cloudsearch/pc')
      : joinUri('/weapi/search/get');

  /// 构建单曲搜索请求元数据。
  DioMetaData searchSongDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 1, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 搜索类型 1: 单曲
  Future<SearchSongWrapX> searchSong(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchSongDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchSongWrapX.fromJson(value.data);
    });
  }

  /// 构建专辑搜索请求元数据。
  DioMetaData searchAlbumDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 10, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 搜索类型  10: 专辑
  Future<SearchAlbumsWrapX> searchAlbum(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchAlbumDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchAlbumsWrapX.fromJson(value.data);
    });
  }

  /// 构建歌手搜索请求元数据。
  DioMetaData searchArtistsDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 100, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 搜索类型 100: 歌手
  Future<SearchArtistsWrapX> searchArtists(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchArtistsDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchArtistsWrapX.fromJson(value.data);
    });
  }

  /// 构建歌单搜索请求元数据。
  DioMetaData searchPlaylistDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 1000, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 搜索类型 1000: 歌单
  Future<SearchPlaylistWrapX> searchPlaylist(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchPlaylistDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchPlaylistWrapX.fromJson(value.data);
    });
  }

  /// 构建用户搜索请求元数据。
  DioMetaData searchUserDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 1002, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 1002: 用户
  Future<SearchUserWrapX> searchUser(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchUserDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchUserWrapX.fromJson(value.data);
    });
  }

  /// 构建 MV 搜索请求元数据。
  DioMetaData searchMvDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 1004, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 1004: MV
  Future<SearchMvWrapX> searchMv(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchMvDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchMvWrapX.fromJson(value.data);
    });
  }

  /// 构建歌词搜索请求元数据。
  DioMetaData searchLyricsDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 1006, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 1006: 歌词
  Future<SearchLyricsWrapX> searchLyrics(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchLyricsDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchLyricsWrapX.fromJson(value.data);
    });
  }

  /// 构建播客搜索请求元数据。
  DioMetaData searchDjradioDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 1009, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 1009: 电台
  Future<SearchDjradioWrapX> searchDjradio(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchDjradioDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchDjradioWrapX.fromJson(value.data);
    });
  }

  /// 构建视频搜索请求元数据。
  DioMetaData searchVideoDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 1014, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 1014: 视频
  Future<SearchVideoWrapX> searchVideo(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchVideoDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchVideoWrapX.fromJson(value.data);
    });
  }

  /// 构建综合搜索请求元数据。
  DioMetaData searchComplexDioMetaData(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    var params = {'s': keyword, 'type': 1018, 'limit': limit, 'offset': offset};
    return DioMetaData(_searchUrl(cloudSearch),
        data: params, options: joinOptions());
  }

  /// [type] 1018:综合
  Future<SearchComplexWrapX> searchComplex(String keyword,
      {bool cloudSearch = false, int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(searchComplexDioMetaData(keyword,
            cloudSearch: cloudSearch, offset: offset, limit: limit))
        .then((Response value) {
      return SearchComplexWrapX.fromJson(value.data);
    });
  }

  /// 构建默认搜索关键词请求元数据。
  DioMetaData searchDefaultKeyDioMetaData() {
    return DioMetaData(
        Uri.parse(
            'http://interface3.music.163.com/eapi/search/defaultkeyword/get'),
        data: {},
        options: joinOptions(
            encryptType: EncryptType.EApi,
            eApiUrl: '/api/search/defaultkeyword/get'));
  }

  /// 默认搜索关键词
  Future<SearchKeyWrap> searchDefaultKey() {
    return Https.dioProxy
        .postUri(searchDefaultKeyDioMetaData())
        .then((Response value) {
      return SearchKeyWrap.fromJson(value.data);
    });
  }

  /// 构建简略热搜词请求元数据。
  DioMetaData searchHotKeyDioMetaData() {
    return DioMetaData(joinUri('/weapi/search/hot'),
        data: {'type': 1111},
        options: joinOptions(userAgent: UserAgent.Mobile));
  }

  /// 热搜列表(简略)
  Future<SearchKeyWrapX> searchHotKey() {
    return Https.dioProxy
        .postUri(searchHotKeyDioMetaData())
        .then((Response value) {
      return SearchKeyWrapX.fromJson(value.data);
    });
  }

  /// 构建详细热搜词请求元数据。
  DioMetaData searchHotKeyDetailedDioMetaData() {
    return DioMetaData(joinUri('/weapi/hotsearchlist/get'),
        data: {}, options: joinOptions());
  }

  /// 热搜列表(详细)
  Future<SearchKeyDetailedWrap> searchHotKeyDetailed() {
    return Https.dioProxy
        .postUri(searchHotKeyDetailedDioMetaData())
        .then((Response value) {
      return SearchKeyDetailedWrap.fromJson(value.data);
    });
  }

  /// 构建搜索建议请求元数据。
  DioMetaData searchSuggestDioMetaData(String keyword,
      {String type = 'mobile'}) {
    var params = {'s': keyword};
    return DioMetaData(
        joinUri(
            '/weapi/search/suggest/${type == 'mobile' ? 'keyword' : 'web'}'),
        data: params,
        options: joinOptions());
  }

  /// 搜索建议(联想)
  /// [type] : 'mobile': 返回移动端数据  'web': web
  Future<SearchSuggestWrapX> searchSuggest(String keyword,
      {String type = 'mobile'}) {
    return Https.dioProxy
        .postUri(searchSuggestDioMetaData(keyword, type: type))
        .then((Response value) {
      return SearchSuggestWrapX.fromJson(value.data);
    });
  }

  /// 构建多重匹配搜索请求元数据。
  DioMetaData searchMultiMatchDioMetaData(String keyword) {
    var params = {'s': keyword, 'type': '1'};
    return DioMetaData(joinUri('/weapi/search/suggest/multimatch'),
        data: params, options: joinOptions());
  }

  /// 搜索多重匹配
  Future<SearchMultiMatchWrapX> searchMultiMatch(String keyword) {
    return Https.dioProxy
        .postUri(searchMultiMatchDioMetaData(keyword))
        .then((Response value) {
      return SearchMultiMatchWrapX.fromJson(value.data);
    });
  }
}
