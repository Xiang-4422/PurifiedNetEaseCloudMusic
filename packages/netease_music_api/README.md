# netease_music_api

Dart client package for NetEase Cloud Music APIs used by Purified NetEase Cloud Music.

The package owns:

- request client, cookies, encryption, and login refresh
- endpoint mixins under `lib/src/endpoints`
- NetEase API DTOs under `lib/src/models`
- the public API barrel `lib/netease_music_api.dart`

The main app should import only:

```dart
import 'package:netease_music_api/netease_music_api.dart';
```

Upstream protocol reference is tracked in the repository submodule:

- `third_party/api-enhanced`
- https://github.com/NeteaseCloudMusicApiEnhanced/api-enhanced
- https://neteasecloudmusicapienhanced.js.org/#/
