import 'package:bujuan/data/music_data/sources/netease/netease_remote_bootstrap.dart';
import 'package:netease_music_api/netease_music_api.dart';

/// Initializes SDK-level services before repositories are constructed.
Future<NeteaseMusicApi> initializeSdk({required bool debug}) async {
  await NeteaseRemoteBootstrap.initialize(debug: debug);
  return NeteaseMusicApi();
}
