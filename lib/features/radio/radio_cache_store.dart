import 'dart:convert';

import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/domain/entities/radio_data.dart';

class RadioCacheStore {
  const RadioCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

  Future<List<RadioSummaryData>?> loadSubscribedRadios() async {
    final payloadJson =
        await _cacheDataSource.loadPayloadJson(_subscribedRadioKey);
    if (payloadJson == null) {
      return null;
    }
    final cachedItems = jsonDecode(payloadJson);
    if (cachedItems is! List) {
      return null;
    }
    return cachedItems
        .map(
          (item) => RadioSummaryData.fromJson(
            Map<String, dynamic>.from(
              (item as Map).map((key, value) => MapEntry('$key', value)),
            ),
          ),
        )
        .toList();
  }

  Future<void> saveSubscribedRadios(List<RadioSummaryData> items) async {
    await _cacheDataSource.save(
      cacheKey: _subscribedRadioKey,
      payloadJson: jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<RadioProgramData>?> loadPrograms(String radioId) async {
    final payloadJson =
        await _cacheDataSource.loadPayloadJson(_programKey(radioId));
    if (payloadJson == null) {
      return null;
    }
    final cachedItems = jsonDecode(payloadJson);
    if (cachedItems is! List) {
      return null;
    }
    return cachedItems
        .map(
          (item) => RadioProgramData.fromJson(
            Map<String, dynamic>.from(
              (item as Map).map((key, value) => MapEntry('$key', value)),
            ),
          ),
        )
        .toList();
  }

  Future<void> savePrograms(
    String radioId,
    List<RadioProgramData> items,
  ) async {
    await _cacheDataSource.save(
      cacheKey: _programKey(radioId),
      payloadJson: jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  static const String _subscribedRadioKey = 'RADIO_SUBSCRIBED_PAGE_1';

  String _programKey(String radioId) => 'RADIO_PROGRAMS_$radioId';
}
