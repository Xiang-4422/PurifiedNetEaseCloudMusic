import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_radio_mapper.dart';
import 'package:bujuan/domain/entities/radio_data.dart';

/// 播客相关远程访问统一放在 data/netease，避免 feature 继续直连平台 API。
class NeteaseRadioRemoteDataSource {
  /// 创建网易云电台远程数据源。
  const NeteaseRadioRemoteDataSource();

  /// 分页获取已订阅电台。
  Future<({List<RadioSummaryData> items, int itemCount})>
      fetchSubscribedRadios({
    bool total = true,
    required int offset,
    required int limit,
  }) async {
    final wrap = await NeteaseMusicApi().djRadioSubList(
      total: total,
      offset: offset,
      limit: limit,
    );
    final radios = wrap.djRadios;
    return (
      items: NeteaseRadioMapper.fromRadioList(radios),
      itemCount: radios.length,
    );
  }

  /// 分页获取电台节目。
  Future<({List<RadioProgramData> items, int itemCount})> fetchPrograms(
    String radioId, {
    required int offset,
    required int limit,
    required bool asc,
  }) async {
    final wrap = await NeteaseMusicApi().djProgramList(
      radioId,
      offset: offset,
      limit: limit,
      asc: asc,
    );
    final programs = wrap.programs;
    return (
      items: NeteaseRadioMapper.fromProgramList(programs),
      itemCount: programs.length,
    );
  }
}
