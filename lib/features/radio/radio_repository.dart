import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_radio_remote_data_source.dart';
import 'package:bujuan/domain/entities/radio_data.dart';

/// 电台仓库，聚合用户电台缓存和网易云远程电台数据。
class RadioRepository {
  /// 创建电台仓库。
  RadioRepository({
    required UserScopedDataSource userScopedDataSource,
    NeteaseRadioRemoteDataSource? remoteDataSource,
  })  : _remoteDataSource = remoteDataSource ?? NeteaseRadioRemoteDataSource(),
        _userScopedDataSource = userScopedDataSource;

  final NeteaseRadioRemoteDataSource _remoteDataSource;
  final UserScopedDataSource _userScopedDataSource;

  /// 加载缓存的已订阅电台。
  Future<List<RadioSummaryData>> loadCachedSubscribedRadios(String userId) {
    return _userScopedDataSource.loadSubscribedRadios(userId);
  }

  /// 加载缓存的电台节目。
  Future<List<RadioProgramData>> loadCachedPrograms(
    String userId,
    String radioId, {
    required bool asc,
  }) {
    return _userScopedDataSource.loadPrograms(
      userId,
      radioId,
      asc: asc,
    );
  }

  /// 获取远程已订阅电台并写入用户缓存。
  Future<DjRadioPage> fetchSubscribedRadios({
    required String userId,
    bool total = true,
    required int offset,
    required int limit,
  }) async {
    final result = await _remoteDataSource.fetchSubscribedRadios(
      total: total,
      offset: offset,
      limit: limit,
    );
    if (offset == 0) {
      await _userScopedDataSource.replaceSubscribedRadios(userId, result.items);
    } else {
      await _userScopedDataSource.appendSubscribedRadios(
        userId,
        result.items,
        startOrder: offset,
      );
    }
    return DjRadioPage(
      items: result.items,
      hasMore: result.itemCount >= limit,
      nextOffset: offset + result.itemCount,
    );
  }

  /// 获取远程电台节目并写入用户缓存。
  Future<DjProgramPage> fetchPrograms(
    String userId,
    String radioId, {
    required int offset,
    required int limit,
    required bool asc,
  }) async {
    final result = await _remoteDataSource.fetchPrograms(
      radioId,
      offset: offset,
      limit: limit,
      asc: asc,
    );
    if (offset == 0) {
      await _userScopedDataSource.replacePrograms(
        userId,
        radioId,
        asc: asc,
        items: result.items,
      );
    } else {
      await _userScopedDataSource.appendPrograms(
        userId,
        radioId,
        asc: asc,
        items: result.items,
        startOrder: offset,
      );
    }
    return DjProgramPage(
      items: result.items,
      hasMore: result.itemCount >= limit,
      nextOffset: offset + result.itemCount,
    );
  }
}

/// 电台分页数据。
class DjRadioPage {
  /// 创建电台分页数据。
  const DjRadioPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  /// 电台摘要列表。
  final List<RadioSummaryData> items;

  /// 是否还有下一页。
  final bool hasMore;

  /// 下一页偏移量。
  final int nextOffset;
}

/// 电台节目分页数据。
class DjProgramPage {
  /// 创建电台节目分页数据。
  const DjProgramPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  /// 电台节目列表。
  final List<RadioProgramData> items;

  /// 是否还有下一页。
  final bool hasMore;

  /// 下一页偏移量。
  final int nextOffset;
}
