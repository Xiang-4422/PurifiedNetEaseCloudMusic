import 'package:dio/dio.dart';

import '../../models/uncategorized/bean.dart';
import '../../client/dio_ext.dart';
import '../../client/netease_handler.dart';
import '../../models/dj/bean.dart';

/// 播客、电台和节目相关接口。
mixin ApiDj {
  /// 构建播客 banner 请求元数据。
  DioMetaData djRadioBannerDioMetaData() {
    return DioMetaData(joinUri('/weapi/djradio/banner/get'),
        data: {}, options: joinOptions(cookies: {'os': 'pc'}));
  }

  /// 电台banner
  Future<BannerListWrap2> djRadioBanner() {
    return Https.dioProxy
        .postUri(djRadioBannerDioMetaData())
        .then((Response value) {
      return BannerListWrap2.fromJson(value.data);
    });
  }

  /// 构建播客分类请求元数据。
  DioMetaData djRadioCategoryDioMetaData() {
    return DioMetaData(joinUri('/weapi/djradio/category/get'),
        data: {}, options: joinOptions());
  }

  /// 电台 - 分类
  Future<DjRadioCategoryWrap> djRadioCategory() {
    return Https.dioProxy
        .postUri(djRadioCategoryDioMetaData())
        .then((Response value) {
      return DjRadioCategoryWrap.fromJson(value.data);
    });
  }

  /// 构建推荐播客分类请求元数据。
  DioMetaData recommendDjRadioCategoryDioMetaData() {
    return DioMetaData(joinUri('/weapi/djradio/home/category/recommend'),
        data: {}, options: joinOptions());
  }

  /// 电台 - 推荐分类
  Future<DjRadioCategoryWrap2> recommendDjRadioCategory() {
    return Https.dioProxy
        .postUri(recommendDjRadioCategoryDioMetaData())
        .then((Response value) {
      return DjRadioCategoryWrap2.fromJson(value.data);
    });
  }

  /// 构建排除热门后的播客分类请求元数据。
  DioMetaData excludeHotDjRadioCategoryDioMetaData() {
    return DioMetaData(joinUri('/weapi/djradio/category/excludehot'),
        data: {}, options: joinOptions());
  }

  /// 电台 - 非热门分类
  Future<DjRadioCategoryWrap3> excludeHotDjRadioCategory() {
    return Https.dioProxy
        .postUri(excludeHotDjRadioCategoryDioMetaData())
        .then((Response value) {
      return DjRadioCategoryWrap3.fromJson(value.data);
    });
  }

  /// 构建指定用户播客列表请求元数据。
  DioMetaData userDjRadioListDioMetaData(String userId) {
    var params = {'userId': userId};
    return DioMetaData(joinUri('/weapi/djradio/get/byuser'),
        data: params, options: joinOptions(cookies: {'os': 'pc'}));
  }

  /// 用户创建的电台
  Future<DjRadioListWrap> userDjRadioList(String userId) {
    return Https.dioProxy
        .postUri(userDjRadioListDioMetaData(userId))
        .then((Response value) {
      return DjRadioListWrap.fromJson(value.data);
    });
  }

  /// 构建今日优选播客列表请求元数据。
  DioMetaData todayPreferredDjRadioListDioMetaData({int page = 0}) {
    var params = {'page': page};
    return DioMetaData(joinUri('/weapi/djradio/home/today/perfered'),
        data: params, options: joinOptions());
  }

  /// 今日优选电台
  /// Preferred perfered = =
  Future<DjRadioListWrap2> todayPreferredDjRadioList({int page = 0}) {
    return Https.dioProxy
        .postUri(todayPreferredDjRadioListDioMetaData(page: page))
        .then((Response value) {
      return DjRadioListWrap2.fromJson(value.data);
    });
  }

  /// 构建推荐播客列表请求元数据。
  DioMetaData recommendDjRadioListDioMetaData() {
    return DioMetaData(joinUri('/weapi/djradio/recommend/v1'),
        data: {}, options: joinOptions());
  }

  /// 精选电台
  Future<DjRadioListWrap> recommendDjRadioList() {
    return Https.dioProxy
        .postUri(recommendDjRadioListDioMetaData())
        .then((Response value) {
      return DjRadioListWrap.fromJson(value.data);
    });
  }

  /// 构建按分类推荐播客列表请求元数据。
  DioMetaData recommendDjRadioListByCategoryDioMetaData(String cateId) {
    var params = {'cateId': cateId};
    return DioMetaData(joinUri('/weapi/djradio/recommend'),
        data: params, options: joinOptions());
  }

  /// 精选电台(分类)
  Future<DjRadioListWrap> recommendDjRadioListByCategory(String cateId) {
    return Https.dioProxy
        .postUri(recommendDjRadioListByCategoryDioMetaData(cateId))
        .then((Response value) {
      return DjRadioListWrap.fromJson(value.data);
    });
  }

  /// 构建热门播客列表请求元数据。
  DioMetaData hotDjRadioListDioMetaData({int offset = 0, int limit = 30}) {
    var params = {'limit': limit, 'offset': offset};
    return DioMetaData(joinUri('/weapi/djradio/hot/v1'),
        data: params, options: joinOptions(cookies: {'os': 'pc'}));
  }

  /// 热门电台
  Future<DjRadioListWrap> hotDjRadioList({int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(hotDjRadioListDioMetaData(offset: offset, limit: limit))
        .then((Response value) {
      return DjRadioListWrap.fromJson(value.data);
    });
  }

  /// 构建指定分类热门播客列表请求元数据。
  DioMetaData hotDjRadioListByCategoryDioMetaData(String cateId,
      {int offset = 0, int limit = 30}) {
    var params = {'cateId': cateId, 'limit': limit, 'offset': offset};
    return DioMetaData(joinUri('/api/djradio/hot'),
        data: params, options: joinOptions());
  }

  /// 热门电台（类别）
  Future<DjRadioListWrap> hotDjRadioListByCategory(String cateId,
      {int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(hotDjRadioListByCategoryDioMetaData(cateId,
            offset: offset, limit: limit))
        .then((Response value) {
      return DjRadioListWrap.fromJson(value.data);
    });
  }

  /// 构建播客排行榜请求元数据。
  DioMetaData djRadioTopListDioMetaData(
      {String type = 'new', int offset = 0, int limit = 100}) {
    var params = {
      'type': type == 'new' ? 0 : 1,
      'limit': limit,
      'offset': offset
    };
    return DioMetaData(joinUri('/api/djradio/toplist'),
        data: params, options: joinOptions());
  }

  /// 新晋电台榜/热门电台榜
  /// [type] 新晋:'new'  热门:'hot'
  Future<DjRadioTopListListWrapX2> djRadioTopList(
      {String type = 'new', int offset = 0, int limit = 100}) {
    return Https.dioProxy
        .postUri(
            djRadioTopListDioMetaData(type: type, offset: offset, limit: limit))
        .then((Response value) {
      return DjRadioTopListListWrapX2.fromJson(value.data);
    });
  }

  /// 构建个性推荐播客请求元数据。
  DioMetaData djRadioPersonalizeDioMetaData({int limit = 6}) {
    var params = {
      'limit': limit,
    };
    return DioMetaData(joinUri('/api/djradio/personalize/rcmd'),
        data: params, options: joinOptions());
  }

  /// 新晋电台榜/热门电台榜
  /// [type] 新晋:'new'  热门:'hot'
  Future<DjRadioListWrap2> djRadioPersonalize({int limit = 6}) {
    return Https.dioProxy
        .postUri(djRadioPersonalizeDioMetaData(limit: limit))
        .then((Response value) {
      return DjRadioListWrap2.fromJson(value.data);
    });
  }

  /// 构建付费精品播客排行榜请求元数据。
  DioMetaData djRadioPayTopListDioMetaData({int limit = 100}) {
    var params = {'limit': limit};
    return DioMetaData(joinUri('/api/djradio/toplist/pay'),
        data: params, options: joinOptions());
  }

  /// 电台 - 付费精品电台
  Future<DjRadioTopListListWrapX> djRadioPayTopList({int limit = 100}) {
    return Https.dioProxy
        .postUri(djRadioPayTopListDioMetaData(limit: limit))
        .then((Response value) {
      return DjRadioTopListListWrapX.fromJson(value.data);
    });
  }

  /// 构建付费礼物播客排行榜请求元数据。
  DioMetaData djRadioPayGiftTopListDioMetaData(
      {int offset = 0, int limit = 30}) {
    var params = {'limit': limit, 'offset': offset};
    return DioMetaData(joinUri('/weapi/djradio/home/paygift/list?_nmclfl=1'),
        data: params, options: joinOptions());
  }

  /// 电台 - 付费精选
  Future<DjRadioTopListListWrapX> djRadioPayGiftTopList(
      {int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(djRadioPayGiftTopListDioMetaData(offset: offset, limit: limit))
        .then((Response value) {
      return DjRadioTopListListWrapX.fromJson(value.data);
    });
  }

  /// 构建播客详情请求元数据。
  DioMetaData djRadioDetailDioMetaData(String radioId) {
    var params = {'id': radioId};
    return DioMetaData(joinUri('/api/djradio/v2/get'),
        data: params, options: joinOptions());
  }

  /// 电台 - 详情
  Future<DjRadioDetail> djRadioDetail(String radioId) {
    return Https.dioProxy
        .postUri(djRadioDetailDioMetaData(radioId))
        .then((Response value) {
      return DjRadioDetail.fromJson(value.data);
    });
  }

  /// 构建播客节目列表请求元数据。
  DioMetaData djProgramListDioMetaData(String radioId,
      {int offset = 0, int limit = 30, bool asc = true}) {
    var params = {
      'radioId': radioId,
      'limit': limit,
      'offset': offset,
      'asc': asc
    };
    return DioMetaData(joinUri('/weapi/dj/program/byradio'),
        data: params, options: joinOptions());
  }

  /// 电台 - 节目列表
  Future<DjProgramListWrap> djProgramList(String radioId,
      {int offset = 0, int limit = 30, bool asc = true}) {
    return Https.dioProxy
        .postUri(djProgramListDioMetaData(radioId,
            offset: offset, limit: limit, asc: asc))
        .then((Response value) {
      return DjProgramListWrap.fromJson(value.data);
    });
  }

  /// 构建节目小时榜请求元数据。
  DioMetaData djProgramHoursTopListDioMetaData({int limit = 100}) {
    var params = {'limit': limit};
    return DioMetaData(joinUri('/api/djprogram/toplist/hours'),
        data: params, options: joinOptions());
  }

  /// 电台 - 24小时节目榜
  Future<DjProgramTopListListWrapX> djProgramHoursTopList({int limit = 100}) {
    return Https.dioProxy
        .postUri(djProgramHoursTopListDioMetaData(limit: limit))
        .then((Response value) {
      return DjProgramTopListListWrapX.fromJson(value.data);
    });
  }

  /// 构建指定用户节目列表请求元数据。
  DioMetaData userDjProgramsListDioMetaData(String userId,
      {int offset = 0, int limit = 30}) {
    var params = {'limit': limit, 'offset': offset};
    return DioMetaData(joinUri('/weapi/dj/program/$userId'),
        data: params, options: joinOptions());
  }

  /// 用户电台节目列表
  Future<DjProgramListWrap> userDjProgramsList(String userId,
      {int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(
            userDjProgramsListDioMetaData(userId, offset: offset, limit: limit))
        .then((Response value) {
      return DjProgramListWrap.fromJson(value.data);
    });
  }

  /// 构建节目排行榜请求元数据。
  DioMetaData djProgramsTopListDioMetaData({int offset = 0, int limit = 100}) {
    var params = {'limit': limit, 'offset': offset};
    return DioMetaData(joinUri('/api/program/toplist/v1'),
        data: params, options: joinOptions());
  }

  /// 电台节目排行榜
  Future<DjProgramTopListListWrap2> djProgramsTopList(
      {int offset = 0, int limit = 100}) {
    return Https.dioProxy
        .postUri(djProgramsTopListDioMetaData(offset: offset, limit: limit))
        .then((Response value) {
      return DjProgramTopListListWrap2.fromJson(value.data);
    });
  }

  /// 构建个性化推荐节目请求元数据。
  DioMetaData personalizedProgramDjListDioMetaData() {
    return DioMetaData(joinUri('/weapi/personalized/djprogram'),
        data: {}, options: joinOptions());
  }

  /// 推荐电台节目
  Future<PersonalizedDjProgramListWrap> personalizedProgramDjList() {
    return Https.dioProxy
        .postUri(personalizedProgramDjListDioMetaData())
        .then((Response value) {
      return PersonalizedDjProgramListWrap.fromJson(value.data);
    });
  }

  /// 构建推荐节目列表请求元数据。
  DioMetaData recommendDjProgramListDioMetaData(
      {String cateId = '', int offset = 0, int limit = 30}) {
    var params = {'cateId': cateId, 'limit': limit, 'offset': offset};
    return DioMetaData(joinUri('/weapi/program/recommend/v1'),
        data: params, options: joinOptions());
  }

  /// 推荐节目
  Future<DjProgramListWrap> recommendDjProgramList(
      {String cateId = '', int offset = 0, int limit = 30}) {
    return Https.dioProxy
        .postUri(recommendDjProgramListDioMetaData(
            cateId: cateId, offset: offset, limit: limit))
        .then((Response value) {
      return DjProgramListWrap.fromJson(value.data);
    });
  }

  /// 构建节目详情请求元数据。
  DioMetaData djProgramDetailDioMetaData(String programId) {
    var params = {'id': programId};
    return DioMetaData(joinUri('/weapi/dj/program/detail'),
        data: params, options: joinOptions());
  }

  /// 节目详情
  Future<DjProgramDetail> djProgramDetail(String programId) {
    return Https.dioProxy
        .postUri(djProgramDetailDioMetaData(programId))
        .then((Response value) {
      return DjProgramDetail.fromJson(value.data);
    });
  }

  /// 构建主播小时榜请求元数据。
  DioMetaData djHoursTopListDioMetaData({int limit = 100}) {
    var params = {'limit': limit};
    return DioMetaData(joinUri('/api/dj/toplist/hours'),
        data: params, options: joinOptions());
  }

  /// 电台 - 24小时主播榜
  Future<DjTopListListWrapX> djHoursTopList({int limit = 100}) {
    return Https.dioProxy
        .postUri(djHoursTopListDioMetaData(limit: limit))
        .then((Response value) {
      return DjTopListListWrapX.fromJson(value.data);
    });
  }

  /// 构建主播新人榜请求元数据。
  DioMetaData djNewcomerTopListDioMetaData({int offset = 0, int limit = 100}) {
    var params = {'limit': limit, 'offset': offset};
    return DioMetaData(joinUri('/api/dj/toplist/newcomer'),
        data: params, options: joinOptions());
  }

  /// 电台 - 新人榜
  Future<DjTopListListWrapX> djNewcomerTopList(
      {int offset = 0, int limit = 100}) {
    return Https.dioProxy
        .postUri(djNewcomerTopListDioMetaData(offset: offset, limit: limit))
        .then((Response value) {
      return DjTopListListWrapX.fromJson(value.data);
    });
  }

  /// 构建主播热门榜请求元数据。
  DioMetaData djPopularTopListDioMetaData({int limit = 100}) {
    var params = {'limit': limit};
    return DioMetaData(joinUri('/api/dj/toplist/popular'),
        data: params, options: joinOptions());
  }

  /// 电台 - 最热主播榜
  Future<DjTopListListWrapX> djPopularTopList({int limit = 100}) {
    return Https.dioProxy
        .postUri(djPopularTopListDioMetaData(limit: limit))
        .then((Response value) {
      return DjTopListListWrapX.fromJson(value.data);
    });
  }
}
