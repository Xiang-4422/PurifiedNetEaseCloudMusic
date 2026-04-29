import 'package:bujuan/domain/entities/radio_data.dart';
import 'package:bujuan/data/netease/api/src/api/dj/bean.dart';

/// 网易云电台 mapper。
class NeteaseRadioMapper {
  /// 禁止实例化网易云电台 mapper。
  const NeteaseRadioMapper._();

  /// 将网易云电台模型转换为领域电台摘要。
  static RadioSummaryData fromRadio(DjRadio radio) {
    return RadioSummaryData(
      id: radio.id,
      name: radio.name,
      coverUrl: radio.picUrl,
      lastProgramName: radio.lastProgramName ?? '',
    );
  }

  /// 将网易云电台列表转换为领域电台摘要列表。
  static List<RadioSummaryData> fromRadioList(List<DjRadio> radios) {
    return radios.map(fromRadio).toList();
  }

  /// 将网易云电台节目模型转换为领域节目数据。
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

  /// 将网易云电台节目列表转换为领域节目数据列表。
  static List<RadioProgramData> fromProgramList(List<DjProgram> programs) {
    return programs.map(fromProgram).toList();
  }
}
