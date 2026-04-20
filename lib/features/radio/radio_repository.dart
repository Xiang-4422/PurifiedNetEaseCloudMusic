import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_radio_mapper.dart';
import 'package:bujuan/features/radio/radio_data.dart';

class RadioRepository {
  Future<DjRadioPage> fetchSubscribedRadios({
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
    return DjRadioPage(
      items: NeteaseRadioMapper.fromRadioList(radios),
      hasMore: radios.length >= limit,
      nextOffset: offset + radios.length,
    );
  }

  Future<DjProgramPage> fetchPrograms(
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
    return DjProgramPage(
      items: NeteaseRadioMapper.fromProgramList(programs),
      hasMore: programs.length >= limit,
      nextOffset: offset + programs.length,
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
