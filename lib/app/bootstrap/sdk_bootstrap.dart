import 'package:netease_music_api/netease_music_api.dart';

/// Initializes SDK-level services before repositories are constructed.
Future<NeteaseMusicApi> initializeSdk({required bool debug}) async {
  await NeteaseMusicApi.init(debug: debug);
  return NeteaseMusicApi();
}
