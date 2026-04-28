import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/netease_radio_remote_data_source.dart';
import 'package:bujuan/domain/entities/radio_data.dart';

class RadioRepository {
  RadioRepository({
    required UserScopedDataSource userScopedDataSource,
    NeteaseRadioRemoteDataSource? remoteDataSource,
  })  : _remoteDataSource =
            remoteDataSource ?? const NeteaseRadioRemoteDataSource(),
        _userScopedDataSource = userScopedDataSource;

  final NeteaseRadioRemoteDataSource _remoteDataSource;
  final UserScopedDataSource _userScopedDataSource;

  Future<List<RadioSummaryData>> loadCachedSubscribedRadios(String userId) {
    return _userScopedDataSource.loadSubscribedRadios(userId);
  }

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

class DjRadioPage {
  const DjRadioPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<RadioSummaryData> items;
  final bool hasMore;
  final int nextOffset;
}

class DjProgramPage {
  const DjProgramPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<RadioProgramData> items;
  final bool hasMore;
  final int nextOffset;
}
