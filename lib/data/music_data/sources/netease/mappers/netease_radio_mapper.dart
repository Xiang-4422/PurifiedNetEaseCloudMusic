import 'package:bujuan/core/entities/radio_data.dart';
import 'package:netease_music_api/netease_music_api.dart';

/// 网易云电台 mapper。
class NeteaseRadioMapper {
  /// 禁止实例化网易云电台 mapper。
  const NeteaseRadioMapper._();

  /// 将网易云电台模型转换为领域电台摘要。
  static RadioSummaryData fromRadio(DjRadio radio) {
    final radioId = _normalizedRadioId(radio.id);
    return RadioSummaryData(
      id: radioId,
      name: radio.name,
      coverUrl: radio.picUrl,
      lastProgramName: radio.lastProgramName ?? '',
    );
  }

  /// 将网易云电台列表转换为领域电台摘要列表。
  static List<RadioSummaryData> fromRadioList(List<DjRadio> radios) {
    return radios.where((radio) => _normalizedRadioId(radio.id).isNotEmpty).map(fromRadio).toList();
  }

  /// 将网易云电台节目模型转换为领域节目数据。
  static RadioProgramData fromProgram(DjProgram program) {
    final programId = _normalizedProgramId(program.id);
    return RadioProgramData(
      id: programId,
      mainTrackId: _normalizedMainTrackId(program.mainTrackId),
      title: program.mainSong.name ?? '',
      coverUrl: program.coverUrl ?? '',
      artistName: program.dj.nickname ?? '',
      albumTitle: program.mainSong.album?.name ?? '',
      durationMs: program.duration ?? 0,
    );
  }

  /// 将网易云电台节目列表转换为领域节目数据列表。
  static List<RadioProgramData> fromProgramList(List<DjProgram> programs) {
    return programs.where((program) => _normalizedProgramId(program.id).isNotEmpty).map(fromProgram).toList();
  }

  static String _normalizedRadioId(String id) {
    return id.trim();
  }

  static String _normalizedProgramId(String id) {
    return id.trim();
  }

  static String _normalizedMainTrackId(Object? id) {
    return id == null ? '' : '$id'.trim();
  }
}
