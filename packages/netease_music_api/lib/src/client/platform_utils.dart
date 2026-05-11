import 'dart:io';

import 'package:flutter/foundation.dart';

/// 平台判断工具，统一处理 Web 环境下的 `dart:io` 访问保护。
class PlatformUtils {
  /// 禁止实例化平台工具类。
  const PlatformUtils._();

  /// 当前是否运行在 Web 平台。
  static bool get isWeb => kIsWeb;

  /// 当前是否运行在 Android 平台。
  static bool get isAndroid => isWeb ? false : Platform.isAndroid;

  /// 当前是否运行在 iOS 平台。
  static bool get isIOS => isWeb ? false : Platform.isIOS;

  /// 当前是否运行在 macOS 平台。
  static bool get isMacOS => isWeb ? false : Platform.isMacOS;

  /// 当前是否运行在 Windows 平台。
  static bool get isWindows => isWeb ? false : Platform.isWindows;

  /// 当前是否运行在 Fuchsia 平台。
  static bool get isFuchsia => isWeb ? false : Platform.isFuchsia;

  /// 当前是否运行在 Linux 平台。
  static bool get isLinux => isWeb ? false : Platform.isLinux;
}
