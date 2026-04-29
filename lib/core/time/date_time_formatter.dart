import 'package:date_format/date_format.dart';

class DateTimeFormatter {
  const DateTimeFormatter._();

  static String durationStamp(int milliseconds) {
    final seconds = (milliseconds / 1000).truncate();
    final minutes = (seconds / 60).truncate();

    final minutesStr = (minutes % 60).toString().padLeft(2, '0');
    final secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  static String commentTime(int time) {
    if (time <= 0) return '';
    return formatDate(
      DateTime.fromMillisecondsSinceEpoch(time),
      [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn],
    );
  }
}
