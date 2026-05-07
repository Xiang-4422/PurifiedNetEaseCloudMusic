import 'dart:developer';

/// 歌词解析模块的调试日志开关与输出入口。
class LyricsLog {
  /// 是否启用歌词解析调试日志。
  static var lyricEnableLog = false;

  static const _defaultTag = "LyricReader->";

  /// 输出普通调试日志。
  static logD(Object? obj) {
    _log(_defaultTag, obj);
  }

  /// 输出警告级别调试日志。
  static logW(Object? obj) {
    _log("$_defaultTag♦️WARN♦️->", obj);
  }

  static _log(String tag, Object? obj) {
    if (lyricEnableLog) log(tag + obj.toString());
  }
}
