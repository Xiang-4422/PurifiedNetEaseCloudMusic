# 网易云音乐 Dart SDK

Dart client package for NetEase Cloud Music APIs used by Purified NetEase Cloud Music.

The package owns:

- request client, cookies, encryption, and login refresh
- endpoint mixins under `lib/src/endpoints`
- NetEase API DTOs under `lib/src/models`
- the public API barrel `lib/netease_music_api.dart`
- a generated raw API manifest that covers every upstream module

The main app should import only:

```dart
import 'package:netease_music_api/netease_music_api.dart';
```

Raw API usage:

```dart
final api = NeteaseMusicApi();
final data = await api.requestModule('album_new', {'limit': 30});
final same = await api.albumNew({'limit': 30});
```

Existing typed APIs are preserved. If a generated raw method has the same name
as a typed method, call `requestModule('<module_name>', query)` to force the raw
module.

Regenerate the upstream module manifest after updating `third_party/api-enhanced`:

```shell
node packages/netease_music_api/tool/generate_api_enhanced_modules.js
node packages/netease_music_api/tool/generate_api_enhanced_modules.js --check
```

The generator formats generated Dart files before writing them back. `--check`
verifies generated files are up to date without writing them.

Upstream protocol reference is tracked in the repository submodule:

- `third_party/api-enhanced`
- https://github.com/NeteaseCloudMusicApiEnhanced/api-enhanced
- https://neteasecloudmusicapienhanced.js.org/#/
