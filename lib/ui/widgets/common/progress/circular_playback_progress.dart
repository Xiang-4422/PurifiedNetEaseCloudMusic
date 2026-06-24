import 'dart:math' as math;

import 'package:bujuan/core/time/date_time_formatter.dart';
import 'package:flutter/material.dart';

const _fallbackPlaybackProgressTotal = Duration(seconds: 10);

/// 下载页和播放面板都只需要消费“0 到 1 的进度结果”，绘制细节集中在这里更稳定。
class CircularPlaybackProgress extends StatelessWidget {
  /// 进度值，绘制时会钳制到 0 到 1。
  final double progress;

  /// 圆环线宽。
  final double strokeWidth;

  /// 圆环背景颜色。
  final Color backgroundColor;

  /// 圆环进度颜色。
  final Color progressColor;

  /// 圆环尺寸。
  final double size;

  /// 百分比文本样式，当前绘制器不直接消费。
  final TextStyle? percentageTextStyle;

  /// 创建圆形播放进度组件。
  const CircularPlaybackProgress({
    Key? key,
    required this.progress,
    this.strokeWidth = 8.0,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.size = 100.0,
    this.percentageTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: _normalizedProgress,
          strokeWidth: strokeWidth,
          backgroundColor: backgroundColor,
          progressColor: progressColor,
        ),
      ),
    );
  }

  double get _normalizedProgress {
    return normalizePlaybackProgress(progress);
  }
}

/// 将任意进度值钳制到播放器 UI 可消费的 0 到 1 区间。
double normalizePlaybackProgress(double progress) {
  if (!progress.isFinite) {
    return 0;
  }
  return progress.clamp(0.0, 1.0).toDouble();
}

/// 根据播放位置和总时长计算安全进度比例。
double playbackProgressFraction({
  required Duration position,
  required Duration? total,
}) {
  if (total == null || total <= Duration.zero) {
    return 0;
  }
  final totalMilliseconds = total.inMilliseconds;
  return normalizePlaybackProgress(
    position.inMilliseconds / totalMilliseconds,
  );
}

/// 返回进度条可安全消费的总时长，未知或异常时使用最小占位时长。
Duration safePlaybackProgressTotal(Duration? total) {
  if (total == null || total <= Duration.zero) {
    return _fallbackPlaybackProgressTotal;
  }
  return total;
}

/// 将播放位置钳制到进度条可展示区间。
Duration clampPlaybackProgressPosition({
  required Duration position,
  required Duration total,
}) {
  if (position < Duration.zero) {
    return Duration.zero;
  }
  if (position > total) {
    return total;
  }
  return position;
}

/// 生成播放进度的完整辅助语义标签。
String playbackProgressSemanticsLabel({
  required Duration position,
  required Duration? total,
}) {
  final safeTotal = safePlaybackProgressTotal(total);
  final safePosition = clampPlaybackProgressPosition(
    position: position,
    total: safeTotal,
  );
  final positionLabel = DateTimeFormatter.durationStamp(
    safePosition.inMilliseconds,
  );
  if (total == null || total <= Duration.zero) {
    return '播放进度：$positionLabel / 未知时长';
  }
  final totalLabel = DateTimeFormatter.durationStamp(safeTotal.inMilliseconds);
  return '播放进度：$positionLabel / $totalLabel';
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth || oldDelegate.backgroundColor != backgroundColor || oldDelegate.progressColor != progressColor;
  }
}
