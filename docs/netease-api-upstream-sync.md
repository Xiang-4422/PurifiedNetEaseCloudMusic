# Netease API Upstream Sync

本项目的 Dart 网易云 API 基于 `NeteaseCloudMusicApiEnhanced/api-enhanced` 维护。上游源码以 Git submodule 形式固定在：

```text
third_party/api-enhanced
```

## 更新上游源码

首次拉取包含 submodule 的仓库后执行：

```shell
git submodule update --init --recursive
```

同步上游 `main` 最新提交：

```shell
git submodule update --remote third_party/api-enhanced
git status --short
git diff --submodule
```

确认上游变更后，把 submodule 指针和对应 Dart API 改动一起提交。

## Dart API 跟随规则

上游变更的主要入口在 `third_party/api-enhanced/module/*.js`。同步到 Dart 时按这个顺序处理：

1. 对照上游模块请求路径、HTTP 方法、参数默认值和加密方式。
2. 在 `lib/data/music_data/sources/netease/api/endpoints/<domain>/api.dart` 更新或新增接口方法。
3. 在 `lib/data/music_data/sources/netease/api/models/<domain>/bean.dart` 更新 DTO，并重新生成 `*.g.dart`。
4. 如上层需要领域实体，更新 `mappers/` 和 `remote/netease_*_remote_data_source.dart`。
5. 补充对应 repository/controller 测试或 mapper 测试。

不要直接在 feature、controller 或 UI 中调用 submodule 里的 JavaScript 代码；`third_party/api-enhanced` 只作为协议参考和更新来源。

## 建议提交粒度

一次上游同步建议拆成两个提交：

1. `同步：更新 Netease API 上游引用`
2. `适配：同步 Dart 网易云 API <接口名>`

如果只拉取上游代码、尚未适配 Dart API，需要在提交说明里明确“仅更新参考源码，未改 Dart API”。
