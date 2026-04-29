import 'package:flutter/widgets.dart';

class SettingsNavigationPort {
  const SettingsNavigationPort({
    required this.openLocalSongs,
    required this.openCoverFlowDemo,
  });

  final void Function(BuildContext context) openLocalSongs;
  final void Function(BuildContext context) openCoverFlowDemo;
}
