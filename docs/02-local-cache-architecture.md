# 02. 本地缓存与表结构设计

## 1. 文档目标

本文档用于固定当前项目的本地缓存分层、`Drift` 表职责、ID 规范，以及用户作用域数据的读写规则。

后续涉及缓存、离线、本地优先或账号隔离的改动，默认都要先满足本文档约束。

## 2. 设计目标

当前本地缓存架构目标固定为：

- 全局内容实体只存一份，不按用户复制多份正文数据
- 用户相关数据按 `user_id` 隔离，不允许跨账号串读
- `local_resource_entries` 是音频、封面、歌词的唯一本地资源事实源
- 页面默认采用“本地优先 + 后台刷新”
- `Hive` 只承接会话、设置和轻量视觉缓存，不再承接业务列表缓存或账号事实数据
- 业务列表 TTL 缓存统一进入 Drift `app_cache_entries`
- `Repository` 负责远端数据回写本地，页面不直接依赖远端响应作为事实源

## 3. 存储分层

### 3.1 Hive

`Hive` 只保留以下职责：

- 当前登录会话
- 设置项
- 离线模式开关
- 轻量视觉缓存，例如图片取色

禁止再把以下数据写入 `Hive` 作为事实源：

- 喜欢歌曲
- 日推
- FM
- 云盘
- 用户歌单
- 推荐歌单
- 歌单订阅态
- 电台订阅与节目列表
- 热搜、探索页、歌单详情、云盘等业务列表缓存

### 3.2 Drift 全局实体表

全局实体表承接“内容事实”，默认不带 `user_id`：

- `tracks`
- `track_lyrics_entries`
- `playlists`
- `playlist_track_refs`
- `albums`
- `artists`

这些表只表示“内容本身是什么”，不表示“哪个用户拥有什么”。

### 3.3 Drift 本地资源与过程表

本地资源与下载过程单独建表，不混入内容实体：

- `playback_restore_snapshots`
- `local_resource_entries`
- `download_tasks`
- `app_cache_entries`

规则：

- `playback_restore_snapshots` 是播放恢复快照的事实源
- `local_resource_entries` 是音频、封面、歌词本地文件的唯一事实源
- `download_tasks` 只表示手动下载过程，不表示最终资源结果
- `app_cache_entries` 承接通用业务 JSON 缓存，按 `cache_key`、`payload_json`、`updated_at_ms` 存储
- `tracks` 不再保存本地路径、下载状态、资源来源等字段

### 3.4 Drift 用户作用域表

用户作用域表承接“用户关系、用户状态、用户快照”，必须显式带 `user_id`：

- `user_profiles`
- `user_track_list_refs`
- `user_playlist_list_refs`
- `user_playlist_snapshots`
- `user_playlist_states`
- `user_radio_subscriptions`
- `user_radio_programs`
- `user_sync_markers`

## 4. ID 规范

### 4.1 统一规则

- 新写入正式本地库的领域 ID，统一使用 `sourceKey:sourceId`
- 当前网易云数据默认使用 `netease:<id>`
- 旧纯数字 ID 只允许作为兼容输入，不允许作为新的正式存储格式

### 4.2 表字段语义

- `tracks.track_id`、`playlists.playlist_id`、`albums.album_id`、`artists.artist_id` 均为规范化后的实体 ID
- `user_track_list_refs.track_id` 存规范化后的实体 ID
- `user_playlist_list_refs.playlist_id` 与 `user_playlist_states.playlist_id` 存规范化后的实体 ID
- `user_playlist_snapshots.playlist_id` 存规范化后的实体 ID
- `user_playlist_snapshots.source_id` 保留远端原始输入 ID，仅用于 UI 输出和兼容跳转

规则：

- 关系表优先关联实体 ID
- 只有确实需要保留原始接口 ID 的地方，才额外存 `source_id`
- 禁止再混用“同一张表里部分行是 raw id、部分行是 entity id”的写法

## 5. 表职责

### 5.1 全局实体表

#### `tracks`

- 歌曲主实体
- 承接搜索、本地播放、远端补全、云盘/FM/日推回写后的统一歌曲数据
- 不承接本地资源路径、下载状态和资源来源

#### `playlists`

- 歌单主实体
- 承接歌单详情页的公共元数据
- 不承接“某个用户的歌单列表入口”

#### `playlist_track_refs`

- 歌单与歌曲的公共关系
- 用于歌单详情页本地装配

### 5.2 用户作用域表

#### `user_profiles`

- 当前用户资料快照
- 用于用户资料页和首页个人信息本地秒开

#### `user_track_list_refs`

- 用户歌曲列表关系表
- `list_kind` 固定为：
  - `liked`
  - `daily_recommend`
  - `fm`
  - `cloud`
- 只存：
  - `user_id`
  - `list_kind`
  - `track_id`
  - `sort_order`
  - `updated_at_ms`

设计说明：

- 这是“有序关系表”，不是歌曲快照宽表
- 主键采用 `(user_id, list_kind, sort_order)`，允许同一首歌在同一列表中重复出现
- `(user_id, list_kind, track_id)` 只做查询索引，不承载唯一性语义

#### `user_playlist_list_refs`

- 用户歌单列表关系表
- `list_kind` 固定为：
  - `liked_collection`
  - `user_playlists`
  - `recommended`

设计说明：

- 这张表只负责“某个用户的某个歌单列表里有哪些歌单，以及顺序是什么”
- 不直接存标题、封面、描述等摘要字段

#### `user_playlist_snapshots`

- 用户歌单列表用到的最小歌单摘要快照
- 只服务于用户歌单列表、推荐歌单列表、搜索补充

设计说明：

- 这张表不是用户关系表
- 这张表也不是公共歌单事实表
- 当某个歌单已经有正式详情进入 `playlists` 时，`playlists` 仍然是公共详情事实源

#### `user_playlist_states`

- 用户对歌单的私有状态
- 当前仅承接 `is_subscribed`

规则：

- 歌单详情页的订阅态只能从这里读取
- `PlaylistSnapshotData` 不再保存 `isSubscribed`

#### `user_radio_subscriptions`

- 用户电台订阅列表快照
- 只表示当前用户订阅了哪些电台以及顺序

#### `user_radio_programs`

- 用户电台节目列表快照
- 以 `(user_id, radio_id, asc)` 为列表作用域
- 当前不进入全局内容实体库

#### `user_sync_markers`

- 用户作用域刷新时间标记
- 用于替代旧用户态 `Hive` 时间戳

## 6. 关键读路径

### 6.1 用户资料

读取路径：

`UserSessionController / UserProfileController -> UserScopedDataSource.loadProfile -> user_profiles`

页面规则：

- 先显示本地资料
- 再后台刷新远端并回写

### 6.2 喜欢 / 日推 / FM / 云盘

统一读取路径：

`user_track_list_refs -> tracks -> 内存重排 -> PlaybackQueueItem`

规则：

- 先查当前用户列表关系和顺序
- 再批量查全局 `tracks`
- 不允许从旧 `Hive` 用户 key 读首屏数据

### 6.2.1 通用业务缓存

读取路径：

`Repository -> CacheStore -> AppCacheDataSource -> app_cache_entries`

规则：

- `SearchCacheStore`、`ExploreCacheStore`、`PlaylistCacheStore`、`CloudCacheStore`、`RadioCacheStore`、`UserProfileCacheStore` 不再读取 `CacheBox.instance`
- TTL 判断基于 `app_cache_entries.updated_at_ms`
- 缓存内容统一保存为 JSON 字符串
- 这类缓存只能服务首屏与短时刷新判断，不能替代正式媒体库和用户作用域表

### 6.3 用户歌单 / 推荐歌单 / 我喜欢的音乐

统一读取路径：

`user_playlist_list_refs -> user_playlist_snapshots`

规则：

- 用户歌单列表读取自己的关系与快照
- 歌单详情页仍走公共 `playlists + playlist_track_refs + tracks`
- 搜索歌单时可以把当前用户歌单列表作为补充来源，但必须按 `playlist_id` 去重

### 6.4 歌单详情

读取路径拆成两部分：

- 公共歌单内容：`playlists + playlist_track_refs + tracks`
- 用户订阅态：`user_playlist_states`

规则：

- 禁止再从页面快照中读取 `isSubscribed`
- 公共内容与用户状态必须分开建模

### 6.5 电台

读取路径：

- 订阅列表：`user_radio_subscriptions`
- 节目列表：`user_radio_programs`

规则：

- 当前电台只做用户快照
- 不进入全局正式实体表

### 6.6 本地资源

统一读取路径：

`tracks -> local_resource_entries -> TrackResourceBundle / LocalSongEntry`

规则：

- 播放音频先查 `kind=audio`
- 显示封面先查 `kind=artwork`
- 读取歌词先查 `kind=lyrics`
- 命中本地文件后统一更新 `last_accessed_at_ms`
- `本地歌曲` 页只按音频资源 `origin` 分类，不再读 `tracks` 上的本地状态字段

## 7. 关键写路径

### 7.1 喜欢歌曲

- 远端返回 liked ids 后，只写 `user_track_list_refs(list_kind=liked)`
- 喜欢/取消喜欢单曲成功后，必须同步更新 `user_track_list_refs`
- 不允许只改内存状态

### 7.2 日推 / FM / 云盘

统一写法：

- 歌曲实体写入全局 `tracks`
- 列表关系写入 `user_track_list_refs`
- `offset=0` 时整体替换该用户该列表
- 分页时按 `sort_order` 追加

### 7.3 用户歌单 / 推荐歌单

统一写法：

- 关系写入 `user_playlist_list_refs`
- 摘要写入 `user_playlist_snapshots`
- 不再把这类列表入口直接写进全局 `playlists`

### 7.4 歌单详情与订阅态

- 歌单详情远端刷新后，公共信息写 `playlists + playlist_track_refs + tracks`
- 若当前请求携带用户上下文，订阅态写 `user_playlist_states`
- 订阅/退订歌单成功后，必须立刻写穿 `user_playlist_states`

### 7.5 电台

- 订阅列表写 `user_radio_subscriptions`
- 节目列表写 `user_radio_programs`
- 不为电台单独建立无作用域全局缓存 key

### 7.6 本地资源与下载

- 手动下载成功后写 `local_resource_entries`，并删除对应 `download_tasks` 成功记录
- 播放缓存只写 `local_resource_entries`，不写 `download_tasks`
- 本地导入写 `tracks` 与 `local_resource_entries`
- 删除本地歌曲时：
  - `managedDownload` / `playbackCache` 删除资源文件、资源索引、歌词缓存
  - `localImport` 删除资源索引、歌词缓存和本地库实体，但不删除用户源文件
- “删除所有缓存”只清 `origin = playbackCache`

## 8. 失效与刷新规则

### 8.1 一般规则

- 页面首次进入：先读本地，再后台刷新
- 手动刷新：强制远端刷新并回写本地
- 远端失败但本地有旧数据时，继续显示旧数据

### 8.2 歌单详情失效

歌单增删曲成功后，必须同时失效：

- `PLAYLIST_SNAPSHOT_*`
- `PLAYLIST_SONGS_*`
- `playlist_track_refs` 对应歌单关系
- 对应刷新时间戳

目的：

- 禁止页面继续使用旧曲目列表

### 8.3 用户刷新时间

用户态刷新时间统一走 `user_sync_markers`，不再落到用户 `Hive` key。

## 9. 查询策略

### 9.1 关系优先

用户列表默认采用“两段式关系查找”：

1. 先查关系表，拿到 ID 与顺序
2. 再批量查实体表或快照表
3. 在内存中按 `sort_order` 重排

适用场景：

- 喜欢列表
- 日推
- FM
- 云盘
- 用户歌单

### 9.2 何时使用 SQL Join

只有在以下场景才优先用数据库侧关联查询：

- 需要数据库侧过滤用户状态
- 需要避免明显的 N+1
- 需要一条查询同时判断关系存在性

默认不要为了“形式上更像关系型数据库”而把所有读取都改成复杂 join。

## 10. 开发约束

后续开发必须遵守以下规则：

- 新的账号相关缓存，优先考虑是否应该进入用户作用域表
- 不允许新增无 `user_id` 的用户事实缓存 key
- 不允许把用户态字段混入全局实体表
- 不允许把 `isSubscribed`、`liked` 这类用户状态塞回公共快照
- 不允许新增“关系 + 摘要 + 状态”混在一张表里的宽表
- 新增列表类表时，必须先定义：
  - 列表作用域
  - ID 语义
  - 顺序唯一性
  - 刷新与失效策略

## 11. 当前边界与假设

- 当前只支持一个激活登录账号，但允许本地长期保留多个 `user_id` 快照
- 开发期允许破坏性 schema 迁移；发布前必须补齐正式版本到正式版本之间的非破坏迁移策略
- 电台仍保持“用户快照模型”，暂不纳入全局正式内容实体库
- 云盘/FM/日推歌曲允许回写全局 `tracks`，账号隔离依赖 `user_track_list_refs`

### 11.1 Drift schema 迁移治理

- 详细治理规范见 [`05-drift-migration-governance.md`](./05-drift-migration-governance.md)
- 每次提升 Drift `schemaVersion`，必须同步记录表结构变更、数据归属变化和是否允许清表重建
- 开发期仍可 destructive reset，但只能作为本地开发策略，不能替代发布版本迁移方案
- 发布前必须为正式版本到正式版本的升级补齐 migration plan，至少覆盖新增列默认值、表拆分、索引变更和缓存表清理策略
- `app_cache_entries` 属于可丢弃业务缓存，迁移失败时可以按 cache key 或整表清理；媒体库、用户作用域关系、下载任务和资源索引不能用缓存清理策略处理
- schema 变更必须能从文档追溯到表所有者：媒体库归 `LibraryRepository`，用户作用域归 `UserRepository`，播放恢复归 playback application，下载任务归 `DownloadRepository`

## 12. 相关实现入口

- 数据库定义：[`lib/core/database/drift_database.dart`](../lib/core/database/drift_database.dart)
- 用户作用域数据源：[`lib/data/local/user_scoped_data_source.dart`](../lib/data/local/user_scoped_data_source.dart)
- 用户作用域 Drift 实现：[`lib/data/local/drift_user_scoped_data_source.dart`](../lib/data/local/drift_user_scoped_data_source.dart)
- 用户链路：[`lib/features/user/user_repository.dart`](../lib/features/user/user_repository.dart)
- 歌单链路：[`lib/features/playlist/playlist_repository.dart`](../lib/features/playlist/playlist_repository.dart)
- 云盘链路：[`lib/features/cloud/cloud_repository.dart`](../lib/features/cloud/cloud_repository.dart)
- 电台链路：[`lib/features/radio/radio_repository.dart`](../lib/features/radio/radio_repository.dart)

## 13. 逐表设计

### 13.1 `tracks`

用途：

- 全局歌曲实体表
- 为播放、搜索、歌单详情、专辑详情、歌手详情以及用户列表装配提供统一歌曲事实

Fields：

- `track_id`：规范化后的歌曲实体 ID
- `source_type`：来源类型
- `source_id`：来源侧原始 ID
- `title`：歌曲标题
- `artist_search_text`：歌手搜索文本
- `artist_names_json`：歌手列表 JSON
- `album_title`：专辑名
- `duration_ms`：时长
- `artwork_url`：远端封面 URL
- `remote_url`：远端播放地址
- `lyric_key`：歌词索引键
- `availability`：歌曲可用性状态
- `metadata_json`：补充元数据 JSON

Key Design：

- `PK: (track_id)`
- `IDX: title`
- `IDX: artist_search_text`
- `IDX: album_title`

Field-Key Relation：

- `track_id` 组成主键，是整张表每一行的唯一身份
- `title`、`artist_search_text`、`album_title` 参与普通索引，用于搜索和筛选
- 其余字段都是普通数据字段，不参与 key
- 不承接本地资源路径、下载状态、资源来源，也不承接 `liked`、`in_cloud`、`is_recommended` 这类用户私有语义

关联关系：

- 被 `playlist_track_refs` 关联
- 被 `user_track_list_refs` 关联

典型读路径：

- 单曲搜索
- 歌单详情歌曲装配
- 喜欢 / 日推 / FM / 云盘列表二段式装配

典型写路径与失效：

- 远端歌曲详情、搜索补全、云盘/FM/日推回写都可以更新本表
- 本地资源新增、命中和删除不直接写本表
- 本表不因为账号切换而清空

### 13.2 `track_lyrics_entries`

用途：

- 歌词内容持久化表

Fields：

- `track_id`：对应歌曲实体 ID
- `main`：主歌词正文
- `translated`：翻译歌词正文

Key Design：

- `PK: (track_id)`

Field-Key Relation：

- `track_id` 同时是字段和主键，表示一首歌最多对应一条歌词记录
- `main`、`translated` 只是内容字段，不参与 key
- 不承接播放态和页面态

关联关系：

- 通过歌曲实体 ID 关联 `tracks`

典型读路径：

- 播放页歌词显示

典型写路径与失效：

- 歌词远端拉取成功后写入
- 歌词失效按歌曲维度处理，不按用户维度处理

### 13.3 `playlists`

用途：

- 全局歌单实体表
- 承接歌单详情页需要的公共歌单元数据

Fields：

- `playlist_id`：规范化后的歌单实体 ID
- `source_type`：来源类型
- `source_id`：来源侧原始 ID
- `title`：歌单标题
- `description`：歌单描述
- `cover_url`：歌单封面 URL
- `track_count`：歌单曲目数

Key Design：

- `PK: (playlist_id)`
- `IDX: title`

Field-Key Relation：

- `playlist_id` 组成主键，是歌单实体在本地库里的统一身份
- `title` 参与普通索引，用于按标题搜索歌单
- `source_type`、`source_id`、`description`、`cover_url`、`track_count` 都是普通字段，不参与 key
- 不保存订阅态等用户私有状态

关联关系：

- 被 `playlist_track_refs` 关联
- 被 `user_playlist_states`、`user_playlist_list_refs` 通过实体 ID 引用

典型读路径：

- 歌单详情页公共头部装配
- 本地歌单搜索的公共实体部分

典型写路径与失效：

- 歌单详情远端刷新后写入
- 不能把用户歌单列表入口直接写进本表作为用户事实

### 13.4 `playlist_track_refs`

用途：

- 全局歌单与歌曲关系表
- 表示一个歌单包含哪些歌曲以及顺序

Fields：

- `playlist_id` 是歌单实体 ID
- `track_id` 是歌曲实体 ID
- `order` 表示歌单内顺序，但不是主键的一部分
- `added_at`：关系写入时附带保留的时间信息

Key Design：

- `PK: (playlist_id, track_id)`
- `IDX: (playlist_id, order)`

Field-Key Relation：

- `playlist_id + track_id` 组成主键，表示“某个歌单包含某首歌”这条关系唯一
- `playlist_id + order` 参与普通索引，用于按歌单内顺序读取列表
- `added_at` 是普通字段，不参与 key

关联关系：

- 连接 `playlists` 与 `tracks`

典型读路径：

- 歌单详情页本地歌曲装配

典型写路径与失效：

- 歌单详情远端刷新后整表替换某个歌单的关系
- 歌单增删曲成功后必须清掉该歌单对应关系

### 13.5 `user_profiles`

用途：

- 用户资料快照表

Fields：

- `user_id`：用户 ID
- `nickname` / `signature` / `follows` / `followeds` / `playlist_count` / `avatar_url`：资料快照字段
- `updated_at_ms`：本地最后写入时间

Key Design：

- `PK: (user_id)`

Field-Key Relation：

- `user_id` 组成主键，表示每个用户只有一条资料快照
- 其余字段都是该用户资料内容，不参与 key

关联关系：

- 按 `user_id` 与当前登录态对应

典型读路径：

- 用户资料页
- 首页个人信息

典型写路径与失效：

- `fetchUserDetail` 成功后整行 upsert
- 不因其他用户刷新而覆盖当前用户行

### 13.6 `user_track_list_refs`

用途：

- 用户歌曲列表关系表
- 表示某个用户在某个列表里有哪些歌曲以及顺序

Fields：

- `user_id`：列表所属用户
- `list_kind` 目前固定为 `liked | daily_recommend | fm | cloud`
- `track_id` 是歌曲实体 ID
- `sort_order` 是列表内稳定顺序
- `updated_at_ms`：本地最后写入时间

Key Design：

- `PK: (user_id, list_kind, sort_order)`
- `UNIQUE IDX: (user_id, list_kind, sort_order)`
- `IDX: (user_id, list_kind, track_id)`

Field-Key Relation：

- `user_id + list_kind + sort_order` 组成主键，唯一标识某个用户某个列表里的某个顺序位置
- `user_id + list_kind + track_id` 参与普通索引，用于按歌曲查找关系
- `updated_at_ms` 是普通字段，不参与 key

关联关系：

- 通过 `track_id` 关联 `tracks`

典型读路径：

- 先读关系和顺序
- 再批量读 `tracks`
- 再内存重排装配页面和 `PlaybackQueueItem`

典型写路径与失效：

- `fetchLikedSongIds`、`fetchTodayRecommendSongs`、`fetchFmSongs`、`fetchCloudSongs` 写入
- `offset=0` 时整体替换该用户该列表
- 分页时按起始顺序追加
- 喜欢/取消喜欢成功后必须同步更新对应关系

### 13.7 `user_playlist_list_refs`

用途：

- 用户歌单列表关系表
- 表示某个用户的歌单列表里有哪些歌单以及顺序

Fields：

- `user_id`：列表所属用户
- `list_kind` 目前固定为 `liked_collection | user_playlists | recommended`
- `playlist_id` 是规范化后的歌单实体 ID
- `sort_order` 是列表内稳定顺序
- `updated_at_ms`：本地最后写入时间

Key Design：

- `PK: (user_id, list_kind, playlist_id)`
- `UNIQUE IDX: (user_id, list_kind, sort_order)`

Field-Key Relation：

- `user_id + list_kind + playlist_id` 组成主键，唯一标识某个用户某个列表里的一首歌单关系
- `user_id + list_kind + sort_order` 参与唯一索引，保证同一列表的顺序不重复
- `updated_at_ms` 是普通字段，不参与 key

关联关系：

- 与 `user_playlist_snapshots` 按 `playlist_id` 关联
- 与 `playlists` 按 `playlist_id` 保持同一 ID 语义

典型读路径：

- 用户歌单列表
- 推荐歌单列表
- 搜索时的用户歌单补充来源

典型写路径与失效：

- `fetchUserPlaylists`、`fetchRecommendedPlaylists` 写入
- `offset=0` 时整体替换该用户该列表
- 不直接存标题、封面、描述

### 13.8 `user_playlist_snapshots`

用途：

- 用户歌单列表的最小摘要快照表

Fields：

- `playlist_id` 是规范化后的歌单实体 ID
- `source_id` 保留原始接口 ID
- `title`、`cover_url`、`track_count`、`description` 只用于列表摘要显示
- `updated_at_ms`：本地最后写入时间

Key Design：

- `PK: (playlist_id)`
- `IDX: title`

Field-Key Relation：

- `playlist_id` 组成主键，表示一条歌单摘要快照
- `title` 参与普通索引，用于按标题匹配快照
- `source_id`、`cover_url`、`track_count`、`description`、`updated_at_ms` 都是普通字段

关联关系：

- 与 `user_playlist_list_refs` 按 `playlist_id` 关联

典型读路径：

- 用户歌单列表摘要装配
- 推荐歌单列表摘要装配
- 搜索时补足用户歌单标题匹配

典型写路径与失效：

- 与 `user_playlist_list_refs` 同步写入
- 它不是公共详情事实源，不能替代 `playlists`

### 13.9 `user_playlist_states`

用途：

- 用户对歌单的私有状态表

Fields：

- `user_id`：用户 ID
- `playlist_id`：规范化后的歌单实体 ID
- `is_subscribed`：当前用户是否订阅该歌单
- `playlist_id` 必须为规范化后的歌单实体 ID
- `updated_at_ms`：本地最后写入时间

Key Design：

- `PK: (user_id, playlist_id)`

Field-Key Relation：

- `user_id + playlist_id` 组成主键，唯一标识某个用户对某个歌单的状态
- `is_subscribed` 和 `updated_at_ms` 都是普通字段，不参与 key

关联关系：

- 与 `playlists`、`user_playlist_list_refs` 通过同一 `playlist_id` 语义关联

典型读路径：

- 歌单详情页订阅态读取

典型写路径与失效：

- 歌单详情远端刷新时可同步写入
- 订阅/退订歌单成功后必须立即写穿
- 不允许把这类状态回塞到公共快照或 `Hive`

### 13.10 `user_radio_subscriptions`

用途：

- 用户电台订阅列表快照表

Fields：

- `user_id`：用户 ID
- `radio_id` 为当前电台标识
- `sort_order`：当前用户订阅列表顺序
- `name`：电台名称
- `cover_url`：电台封面 URL
- `last_program_name`：最近节目名称
- `updated_at_ms`：本地最后写入时间

Key Design：

- `PK: (user_id, radio_id)`
- `UNIQUE IDX: (user_id, sort_order)`

Field-Key Relation：

- `user_id + radio_id` 组成主键，唯一标识某个用户的一条电台订阅
- `user_id + sort_order` 参与唯一索引，保证订阅列表顺序不重复
- `name`、`cover_url`、`last_program_name`、`updated_at_ms` 都是普通字段

关联关系：

- 与 `user_radio_programs` 通过 `(user_id, radio_id)` 形成父子列表作用域

典型读路径：

- 电台订阅列表

典型写路径与失效：

- 订阅列表远端刷新时整表替换或分页追加
- 当前不进入全局内容实体库

### 13.11 `user_radio_programs`

用途：

- 用户电台节目列表快照表

Fields：

- `user_id`：用户 ID
- `radio_id`：所属电台 ID
- `asc`：节目排序方向
- `program_id`：节目标识
- `sort_order`：当前方向下的列表顺序
- `main_track_id`：主轨道 ID
- `title`：节目标题
- `cover_url`：节目封面 URL
- `artist_name`：节目作者名
- `album_title`：节目专辑名
- `duration_ms`：节目时长
- `updated_at_ms`：本地最后写入时间

Key Design：

- `PK: (user_id, radio_id, asc, program_id)`
- `UNIQUE IDX: (user_id, radio_id, asc, sort_order)`

Field-Key Relation：

- `user_id + radio_id + asc + program_id` 组成主键，唯一标识某个方向下的一条节目记录
- `user_id + radio_id + asc + sort_order` 参与唯一索引，保证节目列表顺序不重复
- `main_track_id`、`title`、`cover_url`、`artist_name`、`album_title`、`duration_ms`、`updated_at_ms` 都是普通字段

关联关系：

- 按 `(user_id, radio_id)` 从属于 `user_radio_subscriptions`

典型读路径：

- 电台节目列表

典型写路径与失效：

- 节目列表远端刷新时按 `(user_id, radio_id, asc)` 整体替换
- 分页时按 `sort_order` 追加
- 当前不进入全局搜索语料

### 13.12 `user_sync_markers`

用途：

- 用户作用域刷新时间与同步标记表

Fields：

- `user_id`：用户 ID
- `marker_key`：某条用户作用域链路的刷新标记
- `updated_at_ms`：本地最后一次成功刷新时间

Key Design：

- `PK: (user_id, marker_key)`
- `IDX: (user_id, marker_key)`

Field-Key Relation：

- `user_id + marker_key` 组成主键，唯一标识一个用户的一条刷新标记
- 同一组字段还参与普通索引，便于按用户和标记读取
- `updated_at_ms` 是普通字段，不参与 key

关联关系：

- 与具体实体表没有外键关系
- 但与用户列表和页面刷新策略一一对应

典型读路径：

- 首页用户数据是否需要刷新
- 云盘、电台、歌单订阅态是否需要刷新

典型写路径与失效：

- 远端同步成功后更新对应 marker
- 业务需要强制重刷时删除对应 marker

### 13.13 `albums`

用途：

- 全局专辑实体表
- 承接专辑详情页和本地搜索需要的公共专辑元数据

Fields：

- `album_id`：规范化后的专辑实体 ID
- `source_type`：来源类型
- `source_id`：来源侧原始 ID
- `title`：专辑标题
- `artist_search_text`：歌手搜索文本
- `artist_names_json`：歌手列表 JSON
- `artwork_url`：专辑封面 URL
- `description`：专辑描述
- `track_count`：专辑曲目数
- `publish_time`：发布时间

Key Design：

- `PK: (album_id)`
- `IDX: title`
- `IDX: artist_search_text`

Field-Key Relation：

- `album_id` 组成主键，是专辑实体在本地库里的唯一身份
- `title` 和 `artist_search_text` 参与普通索引，用于按标题和歌手搜索
- 其余字段都是普通元数据字段，不参与 key

关联关系：

- 当前没有单独的专辑关系表
- 通过专辑详情链路与 `tracks` 在业务层装配关联

典型读路径：

- 专辑详情页头部与曲目信息装配
- 本地专辑搜索

典型写路径与失效：

- 专辑详情远端刷新后写入
- 不承接用户私有状态

### 13.14 `artists`

用途：

- 全局歌手实体表
- 承接歌手详情页和本地搜索需要的公共歌手元数据

Fields：

- `artist_id`：规范化后的歌手实体 ID
- `source_type`：来源类型
- `source_id`：来源侧原始 ID
- `name`：歌手名称
- `artwork_url`：歌手封面 URL
- `description`：歌手描述

Key Design：

- `PK: (artist_id)`
- `IDX: name`

Field-Key Relation：

- `artist_id` 组成主键，是歌手实体在本地库里的唯一身份
- `name` 参与普通索引，用于按名称搜索歌手
- `source_type`、`source_id`、`artwork_url`、`description` 都是普通字段

关联关系：

- 当前没有单独的歌手关系表
- 通过歌手详情链路与 `tracks`、`albums` 在业务层装配关联

典型读路径：

- 歌手详情页头部与作品列表装配
- 本地歌手搜索

典型写路径与失效：

- 歌手详情远端刷新后写入
- 不承接用户私有状态

### 13.15 `download_tasks`

用途：

- 下载任务状态表
- 只承接手动下载过程中的进度与失败原因

Fields：

- `track_id`：对应歌曲实体 ID
- `status`：下载任务状态
- `updated_at_ms`：任务最近更新时间
- `progress`：下载进度
- `temporary_path`：当前下载临时文件路径
- `failure_reason`：失败原因

Key Design：

- `PK: (track_id)`
- `IDX: (status, updated_at_ms)`

Field-Key Relation：

- `track_id` 组成主键，表示一首歌在当前库里只有一条下载任务记录
- `status + updated_at_ms` 参与普通索引，用于按任务状态和更新时间读取下载列表
- `progress`、`temporary_path`、`failure_reason` 都是普通字段

关联关系：

- 通过 `track_id` 关联 `tracks`
- 与 `local_resource_entries` 在资源落地后形成业务协同，但没有直接外键

典型读路径：

- 下载列表
- 失败重试与中断恢复

典型写路径与失效：

- 下载启动、进度更新、失败时写入
- 下载成功后立即删除任务行，不长期保留成功结果态

### 13.16 `local_resource_entries`

用途：

- 本地资源索引表
- 记录某首歌的某种本地资源文件路径

Fields：

- `track_id`：对应歌曲实体 ID
- `kind`：资源类型
- `path`：本地文件路径
- `origin`：资源来源
- `size_bytes`：资源文件大小
- `created_at_ms`：资源创建时间
- `last_accessed_at_ms`：最近命中时间

Key Design：

- `PK: (track_id, kind)`
- `IDX: (origin, kind)`

Field-Key Relation：

- `track_id + kind` 组成主键，唯一标识某首歌的某一种本地资源
- `origin + kind` 参与普通索引，用于本地歌曲分类和批量清理
- `path`、`size_bytes`、`created_at_ms`、`last_accessed_at_ms` 都是普通字段，不参与 key

关联关系：

- 通过 `track_id` 关联 `tracks`
- 与 `download_tasks` 在下载落地后形成业务协同，但没有直接外键

典型读路径：

- 播放前选择本地资源
- 页面封面、歌词、本地可用性判断
- 本地歌曲页按音频资源来源装配 `LocalSongEntry`

典型写路径与失效：

- 下载完成、播放缓存完成、本地导入完成后写入
- 本地文件命中时更新 `last_accessed_at_ms`
- 删除本地歌曲或清空缓存时按 `(track_id, kind)` 或 `origin` 删除

### 13.17 `playback_restore_snapshots`

用途：

- 播放恢复快照表
- 用于应用重启后恢复播放队列和播放位置

Fields：

- `id`：快照主键
- `updated_at_ms`：快照更新时间
- `playback_mode` / `repeat_mode`：播放模式与循环模式
- `queue_json`：播放队列快照
- `current_song_id`：当前歌曲实体 ID
- `playlist_name` / `playlist_header`：恢复时展示用的列表信息
- `position_ms`：恢复播放位置

Key Design：

- `PK: (id)`

Field-Key Relation：

- `id` 组成主键，唯一标识一条播放恢复快照
- `updated_at_ms`、`playback_mode`、`repeat_mode`、`queue_json`、`current_song_id`、`playlist_name`、`playlist_header`、`position_ms` 都是普通字段

关联关系：

- `current_song_id` 在语义上关联 `tracks.track_id`
- 其余字段主要服务播放恢复，不与其他表形成正式关系

典型读路径：

- 应用启动后的播放恢复

典型写路径与失效：

- 播放状态变化后按策略覆盖写入
- 新快照覆盖旧快照，不按账号隔离
