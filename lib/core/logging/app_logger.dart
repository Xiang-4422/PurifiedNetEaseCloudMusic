import 'package:flutter/foundation.dart';

/// 应用调试日志工具。
class AppLogger {
  static const _separator = '=';
  static const _split =
      '$_separator$_separator$_separator$_separator$_separator$_separator$_separator$_separator$_separator';
  static var _title = 'Yl-Log';
  static var _isDebug = true;
  static var _limitLength = 800;
  static var _startLine = '$_split$_title$_split';
  static var _endLine = '$_split$_separator$_separator$_separator$_split';

  const AppLogger._();

  /// 初始化日志标题、调试开关和单段输出长度。
  static void init({String? title, required bool isDebug, int? limitLength}) {
    _title = title ?? '';
    _isDebug = isDebug;
    _limitLength = limitLength ?? _limitLength;
    _startLine = '$_split$_title$_split';
    final endLineStr = StringBuffer();
    final cnCharReg = RegExp('[\u4e00-\u9fa5]');
    for (var i = 0; i < _startLine.length; i++) {
      if (cnCharReg.stringMatch(_startLine[i]) != null) {
        endLineStr.write(_separator);
      }
      endLineStr.write(_separator);
    }
    _endLine = endLineStr.toString();
  }

  /// 在调试模式输出日志。
  static void d(dynamic obj) {
    if (_isDebug) {
      _log(obj.toString());
    }
  }

  /// 强制输出日志。
  static void v(dynamic obj) {
    _log(obj.toString());
  }

  static void _log(String msg) {
    debugPrint(_startLine);
    _logEmptyLine();
    if (msg.length < _limitLength) {
      debugPrint(msg);
    } else {
      segmentationLog(msg);
    }
    _logEmptyLine();
    debugPrint(_endLine);
  }

  /// 将长日志分段输出，避免单次 debugPrint 被截断。
  static void segmentationLog(String msg) {
    final outStr = StringBuffer();
    for (var index = 0; index < msg.length; index++) {
      outStr.write(msg[index]);
      if (index % _limitLength == 0 && index != 0) {
        debugPrint(outStr.toString());
        outStr.clear();
        final lastIndex = index + 1;
        if (msg.length - lastIndex < _limitLength) {
          final remainderStr = msg.substring(lastIndex, msg.length);
          debugPrint(remainderStr);
          break;
        }
      }
    }
  }

  static void _logEmptyLine() {
    debugPrint('');
  }
}
