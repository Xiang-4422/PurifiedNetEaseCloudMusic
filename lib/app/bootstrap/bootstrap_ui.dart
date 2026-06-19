import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

/// Initializes platform UI options that must be fixed before the first frame.
Future<void> initializeBootstrapUi() async {
  debugPaintSizeEnabled = false;
  debugProfileBuildsEnabled = kDebugMode && const bool.fromEnvironment('profile_flutter_builds');
  debugProfilePaintsEnabled = kDebugMode && const bool.fromEnvironment('profile_flutter_paints');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await FlutterDisplayMode.setHighRefreshRate();
}
