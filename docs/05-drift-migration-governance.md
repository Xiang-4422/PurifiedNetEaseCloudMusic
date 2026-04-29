# 05. Drift Migration 治理规范

## 1. 文档目标

本文档用于固定 `Drift` schema 演进规则、表归属、缓存清理边界和发布前迁移要求。

当前开发期仍允许 destructive reset，但这只是开发策略，不能作为正式发布版本之间的升级方案。

## 2. 当前 Schema 状态

当前数据库入口：

- 数据库定义：[`lib/core/database/drift_database.dart`](../lib/core/database/drift_database.dart)
- schema version：[`lib/core/database/local_database_config.dart`](../lib/core/database/local_database_config.dart)
- 应用数据库门面：[`lib/core/database/drift_app_database.dart`](../lib/core/database/drift_app_database.dart)

当前 `onUpgrade` 仍执行破坏式重建：

- 删除旧表
- 重新 `createAll`
- 重建查询索引

这只允许在开发期继续存在。进入正式发布前，必须把正式版本到正式版本的升级改为非破坏 migration。

## 3. 表归属

每张表必须有明确 owner，schema bump 时由 owner 同步迁移说明。

| 表 | Owner | 数据性质 |
| --- | --- | --- |
| `tracks` | `LibraryRepository` | 全局媒体实体 |
| `track_lyrics_entries` | playback application / `LibraryRepository` | 歌词事实 |
| `playlists` | `PlaylistRepository` / `LibraryRepository` | 全局歌单实体 |
| `playlist_track_refs` | `PlaylistRepository` / `LibraryRepository` | 歌单歌曲关系 |
| `albums` | `AlbumRepository` / `LibraryRepository` | 全局专辑实体 |
| `artists` | `ArtistRepository` / `LibraryRepository` | 全局歌手实体 |
| `playback_restore_snapshots` | playback application | 播放恢复事实 |
| `local_resource_entries` | `LibraryRepository` / `DownloadRepository` | 本地资源事实 |
| `download_tasks` | `DownloadRepository` | 下载过程态 |
| `app_cache_entries` | feature cache stores | 可丢弃业务缓存 |
| `user_profiles` | `UserRepository` | 用户资料快照 |
| `user_track_list_refs` | `UserRepository` | 用户歌曲列表关系 |
| `user_playlist_list_refs` | `UserRepository` | 用户歌单列表关系 |
| `user_playlist_snapshots` | `UserRepository` | 用户歌单摘要快照 |
| `user_playlist_states` | `UserRepository` | 用户歌单私有状态 |
| `user_radio_subscriptions` | `RadioRepository` | 用户电台订阅快照 |
| `user_radio_programs` | `RadioRepository` | 用户电台节目快照 |
| `user_sync_markers` | `UserRepository` | 用户刷新时间标记 |

## 4. Schema Bump 要求

每次提升 `LocalDatabaseConfig.schemaVersion`，必须同步完成：

- 在本文档新增一条 version 记录
- 说明新增、删除或修改了哪些表和字段
- 说明每个变化的 owner
- 说明是否允许清理旧数据
- 说明 `app_cache_entries` 是否需要按 key 或整表清理
- 说明新字段默认值、旧数据回填策略和索引变更
- 运行 `dart run build_runner build --delete-conflicting-outputs`
- 运行 `dart analyze`
- 运行 `flutter test`

禁止只修改 Drift table 而不更新迁移记录。

## 5. 数据清理边界

可丢弃：

- `app_cache_entries`
- 明确标记为轻量视觉缓存的 Hive 数据

不可按缓存策略直接丢弃：

- `tracks`
- `playlists`
- `playlist_track_refs`
- `albums`
- `artists`
- `track_lyrics_entries`
- `local_resource_entries`
- `download_tasks`
- `playback_restore_snapshots`
- 所有 `user_*` 作用域表

如果正式版本必须丢弃不可丢弃数据，需要在发布说明中明确影响范围，并在 migration plan 中给出兜底恢复策略。

## 6. 缓存表 TTL 与清理

`app_cache_entries` 只服务页面首屏缓存和短时刷新判断，不是媒体库事实源。

规则：

- TTL 由各 cache store 或 repository 决定
- 过期判断基于 `updated_at_ms`
- schema bump 时可以按 cache key 清理特定业务缓存
- 当 payload 格式变化且无法兼容解析时，可以清理对应 key 前缀
- 不允许把用户事实、下载事实或本地资源事实塞进 `app_cache_entries`

## 7. 发布前必须补齐

正式发布前必须完成：

- 把 destructive `onUpgrade` 替换为按版本分支的非破坏 migration
- 为每个历史正式版本定义升级路径
- 为新增非空列补默认值或回填 SQL
- 为表拆分补数据迁移脚本
- 为索引新增和删除补幂等语句
- 为失败迁移定义回滚或兜底提示策略

## 8. Version 记录

### v1

状态：开发期 schema。

策略：

- 允许 destructive reset
- 不承诺历史本地数据迁移
- 当前目标是固定表职责、ID 语义和 owner 归属

已覆盖能力：

- 播放恢复快照
- 本地资源索引
- 下载任务
- 通用业务缓存
- 媒体库实体与歌单关系
- 用户资料、用户列表关系、用户歌单状态、电台快照和同步标记
