import 'package:bujuan/features/radio/radio_data.dart';
import 'package:bujuan/data/netease/api/src/api/dj/bean.dart';

class NeteaseRadioMapper {
  const NeteaseRadioMapper._();

  static RadioSummaryData fromRadio(DjRadio radio) {
    return RadioSummaryData(
      id: radio.id,
      name: radio.name,
      coverUrl: radio.picUrl,
      lastProgramName: radio.lastProgramName ?? '',
    );
  }

  static List<RadioSummaryData> fromRadioList(List<DjRadio> radios) {
    return radios.map(fromRadio).toList();
  }

  static RadioProgramData fromProgram(DjProgram program) {
    return RadioProgramData(
      id: program.id,
      mainTrackId: '${program.mainTrackId}',
      title: program.mainSong.name ?? '',
      coverUrl: program.coverUrl ?? '',
      artistName: program.dj.nickname ?? '',
      albumTitle: program.mainSong.album?.name ?? '',
      durationMs: program.duration ?? 0,
    );
  }

  static List<RadioProgramData> fromProgramList(List<DjProgram> programs) {
    return programs.map(fromProgram).toList();
  }
}
