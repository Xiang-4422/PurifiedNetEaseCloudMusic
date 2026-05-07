# 01. 技术架构设计

## 1. 文档目标

本文档固定项目当前技术架构、目录边界和后续演进规则。后续重构默认遵守两条原则：

- 基于当前仓库真实结构渐进演进。
- 优先删除低价值转发层，不为了“分层完整”继续制造抽象。

当前目标是一个第三方网易云客户端形态的本地优先音乐应用：

- 支持网易云远程数据、本地媒体库、离线缓存和无网络可用。
- UI 和播放器优先消费本地数据。
- 网络请求主要承担刷新、补全和同步职责。

## 2. 当前架构结论

项目已经从“固定 application/usecase/port/factory 分层”收敛为更直接的 feature-first 结构：

```text
lib/
  app/        应用启动、依赖装配和根路由
  core/       通用基础设施和跨 feature 共享实体，不包含业务 feature 逻辑
  data/       本地 data source、DAO、网易云远程协议和 mapper
  features/   页面、controller、repository、feature 内部 service
  ui/         页面、通用 widget、主题、布局工具和展示反馈服务
```

普通业务链路默认如下：

```text
Page/View + Controller -> Repository -> Local DB / Resource Index / Remote Source
```

保留的例外：

- playback 内部仍允许保留必要的 application/service/coordinator，因为它需要隔离 `audio_service`、`just_audio`、后台播放、恢复态和下载协调。
- 下载内部仍允许保留 queue/file/resource/recovery 等组件，因为它们有真实状态机和文件生命周期。
- playback 的 Flutter UI 协作对象保留在 `features/playback` 根下；不能回到纯 `features/playback/application`。

已经删除或不再作为默认方向的结构：

- 空壳 `ApplicationService` / `UseCase`。
- 页面 controller factory。
- 只做转发的 playback/shell/settings/comment/theme port。
- `app/theme`、`app/layout`、`app/services` 和 `app/presentation_adapters` 混合展示目录。
- 自有业务 `snapshot` 持久化架构。

## 3. 硬边界

这些边界仍然需要通过代码和架构测试守住：

- `core / data` 不依赖 Flutter、GetX、页面 controller 或全局容器。
- `core/entities` 保持纯 Dart，不 import data source、DAO、SDK DTO、Flutter 或 GetX。
- `Repository` 不依赖 UI、GetX、`BuildContext`、Widget。
- presentation 可以依赖 feature repository 和全局 `PlayerController`，但不能直接访问：
  - Drift DAO
  - Drift data source
  - `data/netease` remote data source
  - `NeteaseMusicApi`
- `audio_service`、`just_audio`、`MediaItem` 只留在 playback 内部适配层。
- 网易云协议细节只留在 `data/netease` 及其 mapper 内。
- `CacheBox.instance` 不应继续扩散到业务层；新增轻量缓存需要通过明确 store 或 repository 包装。

## 4. 数据流

### 4.1 本地优先

页面默认流程：

1. 先读取本地 Drift 数据库或本地资源索引。
2. 有本地数据时立即展示。
3. 需要刷新时再请求网络。
4. 网络成功后回写本地，再由 repository 重新组装页面数据。
5. 网络失败时，如果本地已有数据，页面继续展示旧数据。

手动刷新代表用户主动要求最新数据，可以绕过 TTL，直接请求远程并回写本地。

### 4.2 PlayListPageView

歌单详情页当前采用更明确的加载策略：

- 进入页面先读本地 DB。
- 本地完整时直接展示，不自动联网。
- 本地为空时，远程先拉首屏 30 首用于快速显示，再拉完整歌单。
- 本地歌曲数小于 `expectedTrackCount` 时，展示本地已有歌曲，同时自动补全完整歌单。
- 下拉刷新直接拉完整歌单。
- 远程完整请求成功后才把远程歌曲批量保存到本地 DB；如果远程返回数量少，也视为一次成功的完整刷新，后续由用户手动刷新更新。

这条策略的目的不是做分页缓存，而是让页面尽快可见，同时避免半份远程分页把本地完整数据截断。

### 4.3 播放链路

- 页面播放命令可以直接调用 `PlayerController`。
- 页面传递 `PlaybackQueueItem`，不直接构造 `MediaItem`。
- `PlayerController` 是播放 UI 状态和命令入口。
- `PlaybackService`、`PlaybackQueueService`、`PlaybackRestoreCoordinator`、`AudioServiceHandler` 等内部组件负责播放源解析、队列切换、后台播放和恢复态。

### 4.4 搜索、探索和用户首页

- `SearchPanelController` 直接依赖 `SearchRepository`，在 controller 内处理热搜 TTL、多类型搜索和 `LoadState`。
- `ExplorePageController` 直接依赖 `ExploreRepository` 和必要的 feature repository。
- `RecommendationController` 直接依赖 `UserRepository`，本地首页数据作为 user feature 的本地数据读取结果。

不再为了这些页面新增只有一层转发的 application service。

## 5. 数据所有权

### 5.1 Hive

`Hive` 只保留：

- 登录态。
- 设置项。
- 离线模式开关。
- 轻量 session 和视觉缓存，例如图片取色结果。

禁止把业务事实写入 Hive，例如喜欢歌曲、用户歌单、歌单详情、云盘列表、播放恢复队列等。

### 5.2 Drift

`Drift` 是业务事实来源：

- `tracks`
- `track_lyrics_entries`
- `playlists`
- `playlist_track_refs`
- `albums`
- `artists`
- `user_profiles`
- `user_track_list_refs`
- `user_playlist_list_refs`
- `user_playlist_states`
- `user_radio_subscriptions`
- `user_radio_programs`
- `user_sync_markers`
- `playback_restore_entries`
- `local_resource_entries`
- `download_tasks`
- `app_cache_entries`

### 5.3 AppCache

`app_cache_entries` 只用于刷新时间、轻量 TTL 记录或不适合进入正式实体表的短期 payload。它不是业务事实主来源，不再保存 playlist/user 的自有 snapshot。

### 5.4 内存缓存

内存缓存只用于短期性能优化和请求去重，不作为事实来源。

## 6. 目录规则

### 6.1 feature 内部

feature 可以按实际复杂度选择简单结构：

```text
features/<feature>/
  presentation/   页面和页面内 widget
  <controller>.dart
  <repository>.dart
  <feature_service>.dart   仅在有真实业务逻辑时保留
```

不要为了形式强制创建 `application/`、`usecase/`、`port/`、`factory/`。

### 6.2 通用 widget

`lib/widget` 只放跨 feature 复用且不依赖具体业务仓库的组件。只服务单个 feature 的 widget 应放回对应 feature。

当前已从歌单 widget 中拆出的通用组件：

- `music_list_tile.dart`
- `section_header.dart`

### 6.3 common

`common` 不再新增业务逻辑。已有内容逐步迁到更明确的位置：

- app 级主题、资源常量进入 `app/`。
- core 基础能力进入 `core/`。
- feature 专属逻辑进入对应 `features/`。

## 7. 技术选型

保留并继续使用：

- `Flutter`
- `GetX`
- `auto_route`
- `Dio`
- `Drift`
- `Hive`
- `just_audio + audio_service`

当前不迁移状态管理框架。未来如果迁移 Riverpod 或其他方案，只替换绑定和 controller 创建方式，不改变 repository/data/core entities 边界。

## 8. ID 规则

- 新写入正式本地库的领域 ID 统一使用 `sourceKey:sourceId`。
- 当前网易云数据默认使用 `netease:<id>`。
- 旧纯数字 ID 只允许作为兼容输入，不允许作为新写入格式。
- 播放队列、本地资源索引、歌词索引、下载记录统一使用领域 ID。

## 9. 架构测试方向

架构测试只守真正边界：

- `core/data` 纯净。
- presentation 不直接访问 remote data source、DAO、Drift data source。
- `audio_service` 和 `MediaItem` 不泄漏到普通页面。
- 不新增只有一行转发的 `*UseCase` / `*ApplicationService`。
- 不恢复已删除的自有业务 snapshot 架构。

架构测试不再要求固定分层齐全，也不再禁止 presentation 依赖 repository 或 `PlayerController`。
