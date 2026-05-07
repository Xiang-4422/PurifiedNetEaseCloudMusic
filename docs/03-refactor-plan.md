# 03. 重构计划与进度

## 1. 文档目标

本文档记录当前重构进度、剩余整理项和验收方式。它不是长期大而全路线图，重点服务接下来能落地的工程整理。

## 2. 当前原则

- 不推倒重来。
- 不继续追加低价值分层。
- 普通页面优先保持 `Page/View + Controller -> Repository`。
- 只有存在真实业务逻辑、状态机、后台协调或外部 SDK 边界时才保留 service/usecase/port。
- 每轮整理尽量小提交、可验证、可回滚。
- 文档必须描述当前代码事实，不能继续保留已删除架构作为目标。

## 3. 已完成事项

### 3.1 架构瘦身

- 删除歌单详情的薄 service/usecase/action。
- 删除搜索、探索、用户首页的空壳 application service。
- 删除 feature controller factory。
- 删除只做转发的 playback/shell/settings/comment/theme port。
- 放宽 presentation 依赖 repository 和 `PlayerController` 的规则。
- 保留 playback 内部真实协调组件。

### 3.2 Snapshot 移除

- 删除 playlist/user 的自有业务 snapshot 持久化。
- 歌单详情改为从 `playlists + playlist_track_refs + tracks` 组装。
- 用户歌单列表改为从 `user_playlist_list_refs + playlists` 组装。
- 播放恢复保留功能，但改为 restore/session 语义。
- Drift schema 升到 `7`，播放恢复表为 `playback_restore_entries`。

### 3.3 PlayListPageView 加载链路

- 改为本地优先。
- 本地完整时不自动联网。
- 本地为空时首屏远程 30 首快速显示，再拉完整歌单。
- 本地 partial 时自动补全完整歌单。
- 下拉刷新直接拉完整歌单。
- 远程完整结果成功后再保存到本地 DB，避免半页数据覆盖完整缓存。
- 背景色首次使用纯黑，再以 300ms 过渡到封面取色结果。

### 3.4 UI 与目录整理

- 设置页加入缓存分析和清理入口。
- 删除空目录和历史常量薄包装。
- `cache_analysis_service.dart`、`playlist_artwork_color_service.dart` 移出低价值 application 目录。
- 歌词解析器迁入 playback feature。
- `SongItem`、`UniversalListTile`、`Header` 拆到通用 widget。
- 歌单 widget 文件只保留歌单卡片相关组件。

## 4. 当前状态

当前仓库不再以“补齐 application/usecase 层”为目标。后续主要工作是继续删掉无效代码、拆小明显过大的页面文件、收紧少数仍混杂的目录。

架构测试应守住硬边界，而不是要求所有 feature 都有相同层级。

## 5. 剩余整理项

### 5.1 低风险立即项

- 删除 `ExplorePage` 中未使用的 `AutoSizeSliverPersistentHeader`。
- 从 `personal_page.dart` 拆出 `RecommendedPlaylistsPageView`。
- 从 `personal_page.dart` 拆出 `QuickStartCard`。
- 从 `bottom_panel_view.dart` 拆出 `BottomPanelHeaderView`。
- 继续检查 `widget/` 中只被单个 feature 使用的组件，移回对应 feature。

### 5.2 目录归属项

- 将 `common/constants/key.dart` 迁到 `core/storage/cache_keys.dart` 或等价位置。
- 将 `common/constants/images.dart`、`common/constants/icon.dart` 迁到 `app/assets/` 或更明确的资源常量目录。
- 逐步减少 `common`，禁止新增业务逻辑。

### 5.3 中风险项

- 拆分 `lib/core/database/drift_database.dart` 的表定义，按 playback/library/user/download/cache 归类。
- 继续缩小 `UserScopedDataSource` 和 `UserDao` 的接口宽度。
- 梳理 `RequestRepository` 对网易云 SDK 内部扩展的依赖方向。
- 评估 domain entity 内的 JSON 编解码是否需要迁到 data mapper。

### 5.4 暂不主动处理

这些文件体量较大，但不建议为了整理而拆：

- `playlist_repository.dart`
- `playlist_page_view.dart`
- `player_controller.dart`

只有在具体功能或缺陷修复需要时，再按行为边界拆分。

## 6. 验收方式

文档或目录整理后至少执行：

```bash
git diff --check
```

涉及 Dart 代码时执行：

```bash
flutter analyze
```

涉及架构边界时执行：

```bash
flutter test test/architecture
```

涉及具体 feature 时补跑对应测试目录。

## 7. 提交约定

提交格式沿用历史：

- `修复：...`
- `优化：...`
- `重构：...`
- `文档：...`

一个问题尽量一个提交。若某次整理只是文档同步，可单独提交 `文档：更新项目架构说明`。
