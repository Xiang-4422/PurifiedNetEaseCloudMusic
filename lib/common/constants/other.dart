import 'dart:ui';

import 'package:bujuan/app/theme/image_color_service.dart';
import 'package:bujuan/app/ui/dialog_service.dart';
import 'package:bujuan/app/ui/toast_service.dart';
import 'package:bujuan/core/time/date_time_formatter.dart';
import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// 历史兼容入口。
///
/// 新代码不要继续从这里取工具函数，应直接依赖 app/core 下的明确服务。
class OtherUtils {
  OtherUtils._();

  static String normalizeImageUrl(String? url) {
    return ImageUrlNormalizer.normalize(url);
  }

  static Future<PaletteGenerator> getImageColorPalette(String? url) {
    return ImageColorService.palette(url);
  }

  static Future<Color> getImageColor(
    String? url, {
    bool getLightColor = false,
  }) {
    return ImageColorService.dominantColor(
      url,
      getLightColor: getLightColor,
    );
  }

  static Color? peekCachedImageColor(
    String? url, {
    bool getLightColor = false,
  }) {
    return ImageColorService.peekCachedColor(
      url,
      getLightColor: getLightColor,
    );
  }

  static Future<void> prewarmImageColors(
    Iterable<String?> urls, {
    bool getLightColor = false,
  }) {
    return ImageColorService.prewarm(
      urls,
      getLightColor: getLightColor,
    );
  }

  static String getTimeStamp(int milliseconds) {
    return DateTimeFormatter.durationStamp(milliseconds);
  }

  static String formatDate2Str(int time) {
    return DateTimeFormatter.commentTime(time);
  }

  /// 最短边，逻辑宽度大于 600，判定为平板。
  static bool isPad() {
    final implicitView = PlatformDispatcher.instance.implicitView;
    if (implicitView == null) {
      return false;
    }
    final deviceShortestSideLength =
        MediaQueryData.fromView(implicitView).size.shortestSide;
    return deviceShortestSideLength >= 600;
  }
}

class PaletteColorData {
  PaletteColor? light;
  PaletteColor? light1;
  PaletteColor? dark;
  PaletteColor? main;
  PaletteColor? main1;

  PaletteColorData({this.light, this.dark, this.main, this.light1, this.main1});
}

class WidgetUtil {
  static void showToast(String message) {
    ToastService.show(message);
  }

  static void showLoadingDialog(BuildContext context) {
    DialogService.showLoading(context);
  }
}
