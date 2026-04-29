import 'package:date_format/date_format.dart';

/// 时间格式化工具。
class DateTimeFormatter {
  /// 禁止实例化时间格式化工具类。
  const DateTimeFormatter._();

  /// 将毫秒时长格式化为 `mm:ss`。
  static String durationStamp(int milliseconds) {
    final seconds = (milliseconds / 1000).truncate();
    final minutes = (seconds / 60).truncate();

    final minutesStr = (minutes % 60).toString().padLeft(2, '0');
    final secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  /// 将评论时间戳格式化为年月日时分。
  static String commentTime(int time) {
    if (time <= 0) return '';
    return formatDate(
      DateTime.fromMillisecondsSinceEpoch(time),
      [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn],
    );
  }
}
