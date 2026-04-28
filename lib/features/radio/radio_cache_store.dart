import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/domain/entities/radio_data.dart';

class RadioCacheStore {
  const RadioCacheStore();

  Future<List<RadioSummaryData>?> loadSubscribedRadios() async {
    final cachedItems = CacheBox.instance.get(_subscribedRadioKey);
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
    await CacheBox.instance.put(
      _subscribedRadioKey,
      items.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<RadioProgramData>?> loadPrograms(String radioId) async {
    final cachedItems = CacheBox.instance.get(_programKey(radioId));
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
    await CacheBox.instance.put(
      _programKey(radioId),
      items.map((item) => item.toJson()).toList(),
    );
  }

  static const String _subscribedRadioKey = 'RADIO_SUBSCRIBED_PAGE_1';

  String _programKey(String radioId) => 'RADIO_PROGRAMS_$radioId';
}
