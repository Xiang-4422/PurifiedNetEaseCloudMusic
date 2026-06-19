import 'package:bujuan/core/entities/radio_data.dart';

import '../dao/radio_dao.dart';
import 'user_scoped_data_source.dart';

/// Drift 实现的用户电台数据源。
class DriftUserRadioDataSource implements UserRadioDataSource {
  /// 创建 Drift 用户电台数据源。
  const DriftUserRadioDataSource({
    required RadioDao dao,
  }) : _dao = dao;

  final RadioDao _dao;

  @override
  Future<List<RadioSummaryData>> loadSubscribedRadios(String userId) {
    return _dao.loadSubscribedRadios(userId);
  }

  @override
  Future<void> replaceSubscribedRadios(
    String userId,
    List<RadioSummaryData> items,
  ) {
    return _dao.replaceSubscribedRadios(userId, items);
  }

  @override
  Future<void> appendSubscribedRadios(
    String userId,
    List<RadioSummaryData> items, {
    required int startOrder,
  }) {
    return _dao.appendSubscribedRadios(
      userId,
      items,
      startOrder: startOrder,
    );
  }

  @override
  Future<List<RadioProgramData>> loadPrograms(
    String userId,
    String radioId, {
    required bool asc,
  }) {
    return _dao.loadPrograms(
      userId,
      radioId,
      asc: asc,
    );
  }

  @override
  Future<void> replacePrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
  }) {
    return _dao.replacePrograms(
      userId,
      radioId,
      asc: asc,
      items: items,
    );
  }

  @override
  Future<void> appendPrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
    required int startOrder,
  }) {
    return _dao.appendPrograms(
      userId,
      radioId,
      asc: asc,
      items: items,
      startOrder: startOrder,
    );
  }
}
