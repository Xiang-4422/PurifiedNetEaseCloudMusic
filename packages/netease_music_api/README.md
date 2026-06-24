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
final collisionSafe = await api.rawSongDetail({'ids': '1'});
```

Existing typed APIs are preserved. If a generated raw method has the same name
as a typed method, call the generated `rawXxx` alias or
`requestModule('<module_name>', query)` to force the raw module.

Regenerate the upstream module manifest after updating `third_party/api-enhanced`:

```shell
node packages/netease_music_api/tool/generate_api_enhanced_modules.js
node packages/netease_music_api/tool/generate_api_enhanced_modules.js --check
node packages/netease_music_api/tool/api_enhanced_coverage_report.js
node packages/netease_music_api/tool/api_enhanced_coverage_report.js --json
node packages/netease_music_api/tool/api_enhanced_coverage_report.js --markdown
node packages/netease_music_api/tool/api_enhanced_coverage_report.js --check-differences-doc=docs/网易云接口开发包.md
node packages/netease_music_api/tool/api_enhanced_coverage_report.js --write-differences-doc=docs/网易云接口开发包.md
```

The generator formats generated Dart files before writing them back and records
the upstream version plus submodule commit in the generated manifest. `--check`
verifies generated files are up to date without writing them.

The coverage report checks that normal upstream modules have Node oracle
fixtures and that every special module is Node-oracle-covered or explicitly
limited. It also reports the tracked submodule commit, dirty state, upstream
module file count, generated manifest upstream version/commit, and generated
manifest differences so upstream refreshes are auditable from one command.
The report also verifies that the package barrel keeps exporting both the
typed SDK facade and the raw api-enhanced dispatcher, and that `NeteaseMusicApi`
continues to mix in the typed endpoint APIs plus `ApiEnhancedRaw`. It exposes
raw convenience methods that are shadowed by typed facade methods and verifies
that every module also has a collision-safe `rawXxx` alias. Runtime option
limitations, such as unsupported PAC proxy URLs, are also included in
`sdkDifferences`. Use `--json` when an automation or follow-up goal needs the
full machine-readable report, `--markdown` when reviewing the current baseline,
and `--write-differences-doc=docs/网易云接口开发包.md` or
`--check-differences-doc=docs/网易云接口开发包.md` to keep the Chinese SDK
differences section synchronized with the report.

Upstream protocol reference is tracked in the repository submodule:

- `third_party/api-enhanced`
- https://github.com/NeteaseCloudMusicApiEnhanced/api-enhanced
- https://neteasecloudmusicapienhanced.js.org/#/
