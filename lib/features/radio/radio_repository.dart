import 'package:bujuan/data/netease/netease_radio_remote_data_source.dart';
import 'package:bujuan/features/radio/radio_cache_store.dart';
import 'package:bujuan/features/radio/radio_data.dart';

class RadioRepository {
  RadioRepository({
    NeteaseRadioRemoteDataSource? remoteDataSource,
    RadioCacheStore? cacheStore,
  })  : _remoteDataSource =
            remoteDataSource ?? const NeteaseRadioRemoteDataSource(),
        _cacheStore = cacheStore ?? const RadioCacheStore();

  final NeteaseRadioRemoteDataSource _remoteDataSource;
  final RadioCacheStore _cacheStore;

  Future<List<RadioSummaryData>?> loadCachedSubscribedRadios() {
    return _cacheStore.loadSubscribedRadios();
  }

  Future<List<RadioProgramData>?> loadCachedPrograms(String radioId) {
    return _cacheStore.loadPrograms(radioId);
  }

  Future<DjRadioPage> fetchSubscribedRadios({
    bool total = true,
    required int offset,
    required int limit,
  }) async {
    final result = await _remoteDataSource.fetchSubscribedRadios(
      total: total,
      offset: offset,
      limit: limit,
    );
    if (offset == 0 && result.items.isNotEmpty) {
      await _cacheStore.saveSubscribedRadios(result.items);
    }
    return DjRadioPage(
      items: result.items,
      hasMore: result.itemCount >= limit,
      nextOffset: offset + result.itemCount,
    );
  }

  Future<DjProgramPage> fetchPrograms(
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
    if (offset == 0 && result.items.isNotEmpty) {
      await _cacheStore.savePrograms(radioId, result.items);
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
