# 02. 本地缓存与表结构设计

## 1. 文档目标

本文档固定项目当前本地缓存分层、`Drift` 表职责、ID 规范和账号作用域数据读写规则。

后续涉及缓存、本地优先或账号隔离的改动，默认先满足本文档约束。

## 2. 当前结论

项目已经移除自有业务 `snapshot` 持久化架构。业务数据来源收敛为：

```text
Drift 本地数据库 + 网络刷新
```

`Hive` 只保留设置、会话和轻量视觉缓存。`app_cache_entries` 可保存刷新时间、TTL marker 或短期 payload，但不再保存 playlist/user 的业务事实副本。

Flutter 框架的 `AsyncSnapshot` 不属于本项目业务架构，不在移除范围内。

## 3. 存储分层

### 3.1 Hive

允许保存：

- 当前登录会话。
- 设置项。
- 轻量 session。
- 图片取色等视觉缓存。

禁止作为事实源保存：

- 喜欢歌曲。
- 用户歌单。
- 歌单详情。
- 歌单歌曲列表。
- 云盘列表。
- 播放恢复队列。
- 下载任务。
- 本地资源索引。

### 3.2 Drift 全局实体表

全局实体只存一份，不按用户复制正文数据：

- `tracks`
- `track_lyrics_entries`
- `track_artist_refs`
- `playlists`
- `playlist_track_refs`
- `albums`
- `artists`

这些表描述内容本身，不描述某个用户是否拥有、订阅或喜欢。

### 3.3 Drift 用户作用域表

用户相关关系显式带 `user_id`：

- `user_profiles`
- `user_track_list_refs`
- `user_playlist_list_refs`
- `user_playlist_states`
- `user_radio_subscriptions`
- `user_radio_programs`
- `user_sync_markers`

规则：

- 用户歌单列表通过 `user_playlist_list_refs + playlists` 组装。
- 用户歌曲列表通过 `user_track_list_refs + tracks` 组装。
- 歌单订阅态保存在 `user_playlist_states`。
- 刷新时间保存在 `user_sync_markers` 或明确的 cache marker 中。

### 3.4 Drift 资源、恢复和过程表

- `playback_restore_entries`：播放恢复状态。
- `local_resource_entries`：音频、封面、歌词等本地文件索引。
- `download_tasks`：下载过程状态。
- `app_cache_entries`：通用短期缓存和刷新 marker。

规则：

- `local_resource_entries` 是本地文件可用性的事实源。
- `download_tasks` 只描述下载过程，不代表最终资源一定可播放。
- `playback_restore_entries` 保存播放恢复数据，不再使用 snapshot 命名。
- `app_cache_entries` 不保存 playlist/user 业务事实。

## 4. ID 规范

- 正式本地库写入统一使用 `sourceKey:sourceId`。
- 网易云实体使用 `netease:<id>`。
- 旧纯数字 ID 只允许作为兼容输入。
- `tracks.track_id`、`playlists.playlist_id`、`albums.album_id`、`artists.artist_id` 均为规范化实体 ID。
- 关系表优先关联规范化实体 ID。
- 只有确实需要兼容远程接口输入时，才额外保留 source/raw id。

## 5. 关键读写路径

### 5.1 歌单详情

本地读取：

```text
playlists + playlist_track_refs + tracks
```

写入规则：

- 远程歌单元信息写入 `playlists`。
- 歌单曲目顺序写入 `playlist_track_refs`。
- 曲目详情写入 `tracks`。
- 页面展示始终按 `playlist_track_refs.sort_order` 组装。

当前页面策略：

- 本地完整：直接展示，不自动联网。
- 本地为空：远程首屏 30 首快速显示，再拉完整歌单。
- 本地 partial：展示本地已有歌曲，同时自动拉完整歌单补全。
- 下拉刷新：直接拉完整歌单。
- 远程完整请求成功后批量保存到本地；即使远程返回曲目数量少，也按一次完整刷新成功处理。

### 5.2 用户歌单列表

本地读取：

```text
user_playlist_list_refs + playlists
```

写入规则：

- `playlists` 保存歌单摘要和公共元信息。
- `user_playlist_list_refs` 保存用户列表归属、顺序和列表类型。
- 不再维护独立的用户歌单摘要 snapshot 表。

### 5.3 用户歌曲列表

本地读取：

```text
user_track_list_refs + tracks
```

`list_kind` 表示列表语义，例如喜欢、日推、FM、云盘等。歌曲正文仍只保存在 `tracks`。

### 5.4 播放恢复

播放恢复使用 restore/session 语义：

- 领域实体：`PlaybackRestoreState`。
- data source：`PlaybackRestoreDataSource`。
- Drift 表：`playback_restore_entries`。
- 协调器：`PlaybackRestoreCoordinator`。

播放恢复不是业务列表缓存，不再使用自有 snapshot 命名。

### 5.5 下载和本地资源

下载流程使用两类表：

- `download_tasks` 保存下载过程。
- `local_resource_entries` 保存最终可用资源。

播放地址选择优先级：

```text
本地导入文件 > 离线缓存文件 > 远程播放地址
```

## 6. AppCache 使用规则

`app_cache_entries` 可以用于：

- 热搜、探索页等短期 payload。
- 刷新时间 marker。
- 不适合进入正式实体表的轻量临时数据。

禁止用于：

- 歌单详情事实。
- 歌单 trackIds 事实。
- 用户歌单摘要事实。
- 播放恢复队列事实。

如果一个数据会被多个页面长期复用，或者需要账号隔离、排序、搜索、离线展示，应进入明确的 Drift 实体表或关系表。

## 7. 账号作用域规则

- 播放历史、搜索历史、下载资源默认不跟账号隔离。
- 用户资料、喜欢歌曲、用户歌单、云盘、推荐、播客订阅等按账号语义隔离。
- 切换账号时，不允许跨账号串读 `user_*` 表数据。
- 用户作用域刷新 marker 必须带 `user_id` 和业务 `scope`。

## 8. 数据库版本

当前 schema version：`7`。

项目当前仍采用破坏式重建策略，不承诺跨版本保留旧本地数据。升级 schema 时需要同步更新：

- `lib/data/music_data/sources/local/app_database_schema.dart`
- `lib/data/music_data/sources/local/drift_database.dart`
- 生成文件 `lib/data/music_data/sources/local/drift_database.g.dart`
- 本文档

## 9. 新增缓存前检查

新增本地缓存前先判断：

1. 是否是长期业务事实？是则进入 Drift 实体表或关系表。
2. 是否与账号有关？是则必须显式带 `user_id`。
3. 是否只是刷新时间？是则用 marker。
4. 是否只是短期页面 payload？可以用 `app_cache_entries`。
5. 是否只是 UI 视觉结果？可以用 Hive 轻量缓存。

不要再新增自有业务 `Snapshot` / `snapshot` 命名。
