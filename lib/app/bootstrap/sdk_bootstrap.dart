import 'package:bujuan/data/music_data/sources/netease/netease_remote_bootstrap.dart';

/// Initializes SDK-level services before repositories are constructed.
Future<void> initializeSdk({required bool debug}) {
  return NeteaseRemoteBootstrap.initialize(debug: debug);
}
