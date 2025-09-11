import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:palette_generator/palette_generator.dart';

import 'images.dart';

class OtherUtils {
  OtherUtils._();

  static Future<PaletteGenerator> getImageColorPalette(String? url) async {
    ImageProvider imageProvider;
    if (url == null) {
      imageProvider = const ExtendedAssetImageProvider(placeholderImage);
    } else {
      if (url.startsWith('http')) {
        imageProvider = CachedNetworkImageProvider('$url?param=500y500', headers: const {'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36 Edg/117.0.2045.35'});
      } else {
        imageProvider = ExtendedFileImageProvider(File(url.split('?').first));
      }
    }
    return await PaletteGenerator.fromImageProvider(imageProvider, size: const Size(300, 300));
  }

  static Future<Color> getImageColor(String? url, {bool getLightColor = false}) async {
    return OtherUtils.getImageColorPalette(url).then((paletteGenerator) {
      if (getLightColor) {
        return paletteGenerator.lightMutedColor?.color
            ?? paletteGenerator.lightVibrantColor?.color
            ?? paletteGenerator.dominantColor?.color
            ?? Colors.white;
      } else {
        return paletteGenerator.darkMutedColor?.color
            ?? paletteGenerator.darkVibrantColor?.color
            ?? paletteGenerator.dominantColor?.color
            ?? Colors.black;
      }
    });
  }

  static String getTimeStamp(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  static String formatDate2Str(int time) {
    if (time <= 0) return '';
    return formatDate(DateTime.fromMillisecondsSinceEpoch(time), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]);
  }

  /// 最短边，逻辑宽度大于600，判定为平板
  static bool isPad(){
    double deviceShortestSideLength = MediaQueryData.fromView(PlatformDispatcher.instance.implicitView!).size.shortestSide;
    return  deviceShortestSideLength >= 600;
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
  static showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  static showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: Lottie.asset(
                'assets/lottie/empty_status.json',
                width: 750 / 4,
                height: 750 / 4,
                fit: BoxFit.fitWidth,
                // filterQuality: FilterQuality.low,
              ),
            ));
  }
}
