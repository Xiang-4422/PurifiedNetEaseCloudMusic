import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:bujuan/core/storage/image_color_cache_store.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:palette_generator/palette_generator.dart';

import 'images.dart';

class OtherUtils {
  OtherUtils._();

  static const ImageColorCacheStore _imageColorCacheStore =
      ImageColorCacheStore();
  static final Map<String, Color> _imageColorMemoryCache = {};
  static final Map<String, Future<Color>> _imageColorPendingLoads = {};

  static const Map<String, String> imageHttpHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36 Edg/117.0.2045.35'
  };

  static String normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty || !url.startsWith('http')) {
      return url ?? '';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.queryParameters.containsKey('param')) {
      return url;
    }
    final nextQueryParameters = Map<String, String>.from(uri.queryParameters)
      ..remove('param');
    return uri
        .replace(
          queryParameters:
              nextQueryParameters.isEmpty ? null : nextQueryParameters,
        )
        .toString();
  }

  static String buildSizedImageUrl(
    String url, {
    String size = '500y500',
  }) {
    return normalizeImageUrl(url);
  }

  static CachedNetworkImageProvider buildCachedImageProvider(
    String url,
  ) {
    final normalizedUrl = normalizeImageUrl(url);
    return CachedNetworkImageProvider(
      normalizedUrl,
      cacheKey: normalizedUrl,
      headers: imageHttpHeaders,
    );
  }

  static Future<PaletteGenerator> getImageColorPalette(String? url) async {
    ImageProvider imageProvider;
    if (url == null) {
      imageProvider = const ExtendedAssetImageProvider(placeholderImage);
    } else {
      final normalizedUrl = normalizeImageUrl(url);
      if (normalizedUrl.startsWith('http')) {
        imageProvider = buildCachedImageProvider(normalizedUrl);
      } else {
        imageProvider =
            ExtendedFileImageProvider(File(normalizedUrl.split('?').first));
      }
    }
    return await PaletteGenerator.fromImageProvider(imageProvider,
        size: const Size(100, 100));
  }

  static Future<Color> getImageColor(String? url,
      {bool getLightColor = false}) async {
    final normalizedUrl = normalizeImageUrl(url);
    final cacheKey = '$normalizedUrl|${getLightColor ? 'light' : 'dark'}';

    final memoryCached = _imageColorMemoryCache[cacheKey];
    if (memoryCached != null) {
      return memoryCached;
    }

    final diskCached = _imageColorCacheStore.load(
      imageUrl: normalizedUrl,
      getLightColor: getLightColor,
    );
    if (diskCached != null) {
      _rememberImageColor(cacheKey, diskCached);
      return diskCached;
    }

    final pending = _imageColorPendingLoads[cacheKey];
    if (pending != null) {
      return pending;
    }

    final future = OtherUtils.getImageColorPalette(normalizedUrl).then((paletteGenerator) async {
      final color = getLightColor
          ? paletteGenerator.lightMutedColor?.color ??
              paletteGenerator.lightVibrantColor?.color ??
              paletteGenerator.dominantColor?.color ??
              Colors.white
          : paletteGenerator.darkMutedColor?.color ??
              paletteGenerator.darkVibrantColor?.color ??
              paletteGenerator.dominantColor?.color ??
              Colors.black;
      _rememberImageColor(cacheKey, color);
      if (normalizedUrl.isNotEmpty) {
        await _imageColorCacheStore.save(
          imageUrl: normalizedUrl,
          getLightColor: getLightColor,
          color: color,
        );
      }
      return color;
    }).whenComplete(() {
      _imageColorPendingLoads.remove(cacheKey);
    });
    _imageColorPendingLoads[cacheKey] = future;
    return future;
  }

  static Future<void> prewarmImageColors(
    Iterable<String?> urls, {
    bool getLightColor = false,
  }) async {
    final normalizedUrls = urls
        .map(normalizeImageUrl)
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList();
    if (normalizedUrls.isEmpty) {
      return;
    }
    await Future.wait(
      normalizedUrls.map(
        (url) => getImageColor(
          url,
          getLightColor: getLightColor,
        ),
      ),
    );
  }

  static void _rememberImageColor(String cacheKey, Color color) {
    if (_imageColorMemoryCache.length > 120) {
      _imageColorMemoryCache.remove(_imageColorMemoryCache.keys.first);
    }
    _imageColorMemoryCache[cacheKey] = color;
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
    return formatDate(DateTime.fromMillisecondsSinceEpoch(time),
        [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]);
  }

  /// 最短边，逻辑宽度大于600，判定为平板
  static bool isPad() {
    double deviceShortestSideLength =
        MediaQueryData.fromView(PlatformDispatcher.instance.implicitView!)
            .size
            .shortestSide;
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
