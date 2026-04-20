import 'package:bujuan/data/netease/netease_radio_remote_data_source.dart';
import 'package:bujuan/features/radio/radio_data.dart';

class RadioRepository {
  RadioRepository({NeteaseRadioRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? const NeteaseRadioRemoteDataSource();

  final NeteaseRadioRemoteDataSource _remoteDataSource;

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
