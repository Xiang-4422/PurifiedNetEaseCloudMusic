# 01. 技术架构设计

## 1. 文档目标

本文档用于固定本项目的技术架构、工程目录、边界规则和演进方向。

后续所有重构默认遵守两条原则：

- 基于当前仓库真实结构渐进演进
- 优先修复职责边界，不以更换框架为首要目标

当前架构目标已经固定为：

- 面向第三方网易云客户端的本地优先音乐应用
- 支持网易云远程数据、本地媒体库、离线缓存与无网络可用
- 所有功能优先以本地数据为事实来源

## 2. 当前仓库现状

当前项目功能完整，但职责分布仍然交叉：

- [`lib/features/shell/shell_controller.dart`](../lib/features/shell/shell_controller.dart) 同时承担壳层 UI 状态、播放入口和部分业务编排
- [`lib/features/playback/player_controller.dart`](../lib/features/playback/player_controller.dart) 与 [`lib/features/playback/application/audio_service_handler.dart`](../lib/features/playback/application/audio_service_handler.dart) 已形成播放链路，`MediaItem` 适配限定在播放 application/service 层
- [`lib/features/user/user_controller.dart`](../lib/features/user/user_controller.dart) 同时承担用户状态、推荐内容、喜欢歌曲、FM、心动模式等职责
- 页面已并入对应 feature 的 `presentation` 目录，仍需继续缩小页面内用例逻辑，例如：
  - [`lib/features/auth/presentation/login_page_view.dart`](../lib/features/auth/presentation/login_page_view.dart)
  - [`lib/features/playlist/presentation/playlist_page_view.dart`](../lib/features/playlist/presentation/playlist_page_view.dart)
  - [`lib/features/cloud/presentation/cloud_drive_view.dart`](../lib/features/cloud/presentation/cloud_drive_view.dart)
  - [`lib/features/search/presentation/top_panel_view.dart`](../lib/features/search/presentation/top_panel_view.dart)
- 旧 `request_widget` 已移除，请求执行权已从页面和通用组件回收到 feature controller 与 repository

结论：

- 当前问题不是基础设施选型本身错误
- 当前问题是职责落点不清晰
- 当前数据流仍带有“远程接口为中心”的历史惯性，不满足本地优先与离线目标

## 3. 目标与关键决策

### 3.1 产品目标

- 支持本地扫描、本地播放与离线播放
- 支持无网络时继续浏览本地库、播放已缓存内容、查看历史数据
- 支持将网易云远程内容同步到本地媒体库，供 UI 和播放器统一消费

### 3.2 当前确认的关键决策

以下决策作为当前阶段默认前提，变更前必须先更新本文档：

- 本地数据库目标选型：`Drift`
- 搜索策略：本地优先，远程补充并回写
- 本地音乐源是正式目标能力，不是附属功能
- 离线下载是核心能力，不是可选增强
- 现阶段保留 `GetX`，依赖装配统一通过应用级 binding 管理
- 后期迁移 `Riverpod` 时只替换 binding/provider 与 controller 创建方式
- `domain / data / repository` 不依赖 `GetX`、`Rx` 或全局容器读取
- `Hive` 只保留设置、登录态和轻量缓存；正式媒体库与用户作用域数据进入 `Drift`
- 数据库升级允许破坏式重建，不保留历史本地数据搬运逻辑

### 3.3 当前确认的产品偏好

- 切换账号时，播放历史、搜索历史、下载内容都不跟账号走
- 缓存与下载明确区分，下载内容在 UI 上需要明确标记
- 离线能力采用手动开关，而不是只做自动降级
- 搜索结果采用单一结果流，本地优先命中，远程再补充刷新
- 本地音乐源是重要能力，但产品入口暂不与在线内容并列为双主入口
- 下载内容在正常内容流中可见，不只停留在独立下载页

补充：

- “单一结果流”只表示同一类结果不再拆成本地分区和在线分区
- 不等于取消现有 `单曲 / 歌单 / 专辑 / 歌手` 分类视图
- 用户资料页采用本地快照优先，页面先显示本地数据，再后台刷新
- 播客列表与节目列表先缓存元数据和节目基础信息，不先缓存完整播放资源
- 云盘数据先按账号保存本地快照，不作为强本地事实源
- 评论不进入正式本地库，只保留页面级状态和必要刷新

## 4. 总体架构

### 4.1 架构风格

本项目采用：

`Local-First + Netease-Remote + Feature-Oriented + Gradual Refactor`

含义：

- 本地媒体库是应用主数据入口
- 网易云远程数据和本地扫描是当前唯一需要承接的两类内容来源
- 业务代码按 feature 组织
- 在模块内保持展示层、状态层、数据访问层的清晰边界
- 在保留现有运行能力的前提下渐进重构

### 4.2 核心数据流

后续默认数据流如下：

`UI / Controller -> Repository / Service -> Local Library -> Netease / Local -> Remote`

规则：

- UI 优先读取本地数据库或本地缓存，不直接依赖远程响应
- 远程接口、扫描器、下载器负责写入本地库，而不是直接成为页面数据源
- 播放器优先消费统一媒体实体与本地可播放地址
- 远程请求主要承担同步、补全和刷新职责

### 4.3 本地优先规则

- 列表页、搜索页、歌单页优先展示本地库已有数据
- 网络可用时后台同步并刷新本地库
- 离线模式下只要本地库和缓存存在，应用仍可工作
- 播放逻辑优先选择本地文件，其次选择可用远程播放地址
- 搜索类入口至少支持“本地命中即返回，远程作为补充和回写来源”
- 现有分类视图可以保留，但每个分类的数据入口都应逐步切到统一 repository / library 路径

### 4.4 数据所有权

后续数据默认按以下边界存放：

- `Hive`
  - 登录态
  - 设置项
  - 离线模式开关
  - 极轻量配置缓存
- 正式本地媒体库
  - 歌曲
  - 歌词
  - 歌单及歌单关系
  - 播放恢复快照
  - 播放历史
  - 最近播放
  - 下载任务过程记录
  - 离线资源索引
- 内存缓存
  - 仅作过渡层或短时性能优化
  - 不作为事实来源

账号相关补充：

- 播放历史、搜索历史、下载记录默认不跟账号隔离
- 用户歌单、喜欢歌曲、云盘、推荐数据仍按账号语义同步和展示
- 用户资料快照、播客订阅列表、云盘元数据按账号隔离存放

### 4.5 同步策略

- 页面首次进入：先读本地，再后台同步并回写本地
- 下拉刷新：强制远程同步并回写本地
- 搜索：先查本地，未命中或需要补充时查远程并回写
- 播放：优先本地文件，其次离线缓存，最后远程地址
- 无网络：禁止主动远程同步，仅依赖本地库和缓存继续工作

### 4.5.1 页面首屏数据规则

- 高价值页面默认采用“本地快照优先 + 后台刷新”
- 只有本地完全没有可用数据时，页面才允许进入首屏 loading
- 页面不得在 `build` 期间直接构造新的远程请求 future，首屏数据必须由 controller 或 repository 统一驱动
- 手动刷新始终强制远程拉取，并在成功后回写本地
- 远程刷新失败时，如果本地已有旧数据，页面应继续显示旧数据而不是回退到空态

高价值页面包括：

- 我的喜欢
- 我的歌单
- 歌单详情
- 专辑详情
- 歌手详情
- 首页推荐歌单与每日推荐
- 用户资料
- 云盘
- 播客订阅列表与节目列表

### 4.5.2 自动刷新策略

- 歌单详情、专辑详情、歌手详情：进入页面时先显示本地，再后台刷新；本地快照默认按天级别看待
- 用户资料、我的喜欢、我的歌单：进入页面时先显示本地，再后台刷新；本地快照默认按分钟到小时级别看待
- 推荐歌单、每日推荐、云盘、播客：进入页面时如果有本地快照则立即显示，并始终后台刷新
- 评论与楼中楼评论：不进入正式本地库，只保留页面态或短期缓存，不要求本地秒开

### 4.5.3 图片资源优先级

- 页面和组件显示封面时，优先级必须统一为：
  - 本地封面文件路径
  - 本地资源索引中可用的封面路径
  - 远程封面 URL
- 取色逻辑也必须遵循同样的优先级，不能在本地封面已经存在时仍优先对远程 URL 取色
- 高价值页面不得因为远程封面未加载完成而阻塞首屏文本和列表内容显示

### 4.6 离线模式边界

- 离线模式是用户手动开启的显式模式
- 离线模式开启后，`LibraryRepository` 只返回本地媒体库数据，并阻断新的远程兜底读取
- 离线模式下的 UI 不应继续暴露明显依赖在线数据的入口
- 如果暂时没有本地等价能力，需要明确提示当前仅使用本地数据
- 离线模式状态必须通过独立存储入口管理，不能散落在页面层

### 4.7 统一 ID 规范

- 新增领域 ID 必须使用 `sourceKey:sourceId`
- 旧纯数字远程 ID 只允许作为兼容输入，不再作为新写入格式
- 播放队列、本地库索引、歌词索引、下载记录统一使用领域 ID

## 5. 技术选型

### 5.1 保留并继续使用

- `Flutter`
  - 继续作为唯一 UI 框架
- `GetX`
  - 现阶段保留，用于页面状态、Controller 和应用级 Binding
  - `Rx`、`GetxController`、`Get.find` 只允许出现在 `features/*/presentation`、controller、binding、route 层
  - 不进入 `domain / data / repository`
- `auto_route`
  - 继续作为路由方案
- `Dio`
  - 继续作为网络层基础客户端
- `Hive`
  - 继续作为轻量本地存储
  - 不再承担完整媒体库职责
- `just_audio + audio_service`
  - 继续作为音频播放底层方案

### 5.2 新增并逐步落地

- 结构化本地数据库
  - 目标选型：`Drift`
  - 用于曲库索引、歌单关系、本地扫描结果、下载状态、离线文件索引、播放历史、搜索缓存

## 6. 核心抽象

### 6.1 Repository

- 页面与大部分 Controller 不再直接访问 `NeteaseMusicApi`
- 数据访问统一经由 `Repository`
- `Repository` 负责组合本地库、轻缓存、远程源与领域转换
- `Repository` 的长期职责中心是应用能力，而不是单一接口能力
- `Repository` 不再向 UI 暴露 `DioMetaData` 等远程请求描述

### 6.1.1 页面状态边界

- 页面只消费 `LoadState` / `PagedState`
- 页面负责渲染 loading、empty、error 和列表 UI
- controller 负责首次加载、刷新、分页和游标推进
- 通用组件不再执行请求、不再解析 JSON、不再管理分页参数

### 6.2 Mapper

- 所有 `Song2`、`CloudSongItem`、歌单详情等到 `MediaItem` 的转换统一收口
- 页面和零散组件中禁止重复拼装 `MediaItem`
- 平台 Bean 到领域实体的转换统一收口到 `data/mappers`
- 专辑页、歌手页、推荐歌曲等展示链路优先消费统一实体，不再让页面直接依赖网易云 `Album`、`Artist`、`Song2`

### 6.3 Shell 协调层

- 首页壳层 UI 状态与业务入口分离
- `ShellController` 的长期目标是拆薄
- 壳层状态独立为 `features/shell/controller`
- 页面不应直接驱动 `audioHandler`，也不应继续通过 `ShellController` 充当播放代理；播放主链路统一经由 `PlayerController` 暴露入口
- `PlayerController` 不再直接初始化底层播放器实例，音频服务生命周期统一收口到 `PlaybackService`
- 漫游模式续队列、喜欢歌曲播放和模式初始化等队列编排优先下沉到 `PlaybackService`，控制器只保留状态与交互协作
- `AudioServiceHandler` 不再直接反向依赖 `PlayerController`，上层状态同步改为通过 `PlaybackService` 显式绑定回调
- `AudioServiceHandler` 不再直接读取 `SettingsController` 或 `UserController`，底层所需偏好和交互入口统一通过 `PlaybackService` 注入
- 播放模式、重复模式、当前歌单名等展示态收口为 `PlaybackSessionState`
- 播放恢复信息开始收口为 `PlaybackRestoreState`，当前项、歌单元信息、队列、模式和进度不再继续以散落 key 分别理解
- 当前队列、当前歌曲、当前索引和当前进度收口为 `PlaybackRuntimeState`
- 歌词行、当前歌词索引和翻译歌词标记开始收口为 `PlaybackLyricState`，避免歌词解析结果继续散落在控制器兼容字段中
- 播放恢复态已回收到 `PlaybackRestoreDataSource`，歌词内容改由媒体库承接
- 播放恢复态的读写主入口已切到 `PlaybackRepository`，控制器和底层 handler 不再直接操作存储实现
- 播放恢复态已从 `LocalLibraryDataSource` 拆出，改由独立的 `PlaybackRestoreDataSource` 承接
- 播放恢复态已接入 `Drift` 的 `playback_restore_snapshots`，不再以 `Hive` 作为事实源
- 持久化层已新增独立的恢复态记录模型与 codec，数据库实现优先复用该记录格式而不是直接存业务对象
- 数据库层已补 `AppDatabaseSchema`，并明确恢复快照、资源索引、下载任务是优先进入正式数据库的三类记录
- 资源索引与下载任务也已直接接入独立数据库数据源接口，当前过渡实现统一经过 `AppDatabase`
- `DriftAppDatabase` 已落地并接管 `PlaybackRestoreDataSource`、`LocalResourceIndexDataSource`、`DownloadTaskDataSource` 和 `LocalLibraryDataSource`，播放恢复态、本地资源索引、下载任务以及媒体库中的 `Track / Lyrics / Playlist / Album / Artist` 已开始使用 `Drift` 作为正式数据库入口
- `Track` 已改为结构化列落库，不再依赖 `payloadJson` 反序列化作为主读取路径；后续媒体库查询优先继续沿这个方向补齐
- `Playlist / Album / Artist` 也已改为结构化列落库，媒体库本体不再依赖 `payloadJson` 作为主持久化格式
- 歌单与歌曲关系已拆到独立关系表，`PlaylistEntity.trackRefs` 不再整包压进单列 JSON 作为唯一事实来源
- Drift 数据库已补针对标题、歌手搜索文本、歌单关系和下载状态的查询索引，媒体库搜索与下载列表不再完全依赖全表扫描
- 下载主链路已开始直接落到 `DownloadRepository`，负责音频文件、封面文件、歌词文件的实际落盘与状态回写，不再只保留任务状态模型
- 下载任务当前不做断点续传；应用启动时会把遗留任务分开处理：
  - `downloading` 收敛为中断失败
  - `queued` 自动重新入队
- 同一时间的下载执行会按统一队列串行调度，避免多个任务并发写文件导致状态失真
- 下载任务在进入真实下载前会持久化目标文件路径，确保取消、异常退出和启动恢复时都能清理临时文件
- 本地扫描已开始自动识别同目录的歌词与封面文件，导入后会直接补齐本地资源索引
- 播放恢复态采用单一快照格式，正式本地库和恢复逻辑共享该结构
- 壳层与主播放面板已开始消费统一播放状态对象，后续页面迁移优先复用这些状态而不是继续增加散落 getter
- 底部播放面板的队列列表、头部信息、当前歌曲封面和进度读取已优先改用 `PlaybackRuntimeState`，旧运行态字段开始退回兼容入口
- `PlayerController` 内部逻辑已优先读取 `sessionState / runtimeState / lyricState`，旧 `curPlaying* / curPlay* / lyrics*` 字段逐步退为页面兼容镜像
- `ShellController` 中直接暴露旧运行态与歌词态的兼容 getter 已移除，壳层统一改经 `PlaybackSessionState / PlaybackRuntimeState / PlaybackLyricState` 读取播放状态
- `PlayerController` 中旧 `curPlaying* / curPlay* / lyrics*` 兼容字段已移除，播放控制器与页面层统一开始以播放状态对象为唯一事实源
- 页面层对 `curPlayListName / curPlayListNameHeader / isPlayingLikedSongs` 的依赖已切到 `PlaybackSessionState`，会话态兼容字段开始退出壳层和控制器
- 当前播放歌曲的下载与删除下载入口已收口到 `PlayerController`，并通过 `DownloadRepository` 回写本地资源后再同步当前 `MediaItem`
- 下载任务已经接入独立页面入口，设置页和当前播放面板都能直接触发下载管理、删除下载和失败重试动作
- 本地歌曲管理页已按 `全部 / 缓存 / 已下载 / 本地导入` 展示本地资源，已下载状态由 `local_resource_entries` 表达
- `download_tasks` 只承接 `queued / downloading / failed` 等下载过程状态，下载成功后以资源索引作为事实源
- 本地歌曲管理页已支持删除自动播放缓存和删除具体本地资源，下载记录清理与真实文件删除不再混成同一个动作
- 歌单、专辑等复用 `SongItem` 的音乐列表已接入统一下载动作，列表页不再直接依赖下载仓库
- 歌单页和专辑页已补“下载全部”入口，批量下载统一经 `PlayerController -> DownloadRepository` 入队，不再让页面自己组织下载任务
- 当前播放面板和歌单列表项对 `queued / downloading` 状态已支持直接取消下载，不再只展示不可操作的进行中图标
- 下载任务数据源已经支持监听 Drift 下载表，任务进度与失败状态可自动反映到上层，不再依赖手动刷新轮询

### 6.4 Netease 与 Local Source

- 当前只保留两个内容来源：
  - `NeteaseMusicSource`
  - `LocalMusicSource`
- 不再围绕“未来其他远程源”设计 registry 或扩展模板
- repository 直接依赖这两个来源，不再通过额外分发层再转一次
- `LocalMusicSource` 的职责不仅是扫描文件，还包括提供统一 `Track`、本地搜索和可播放地址

### 6.5 Local Library

- UI、播放控制器、搜索优先从本地媒体库读取
- 同步器和下载器通过媒体库接口写入数据
- `LibraryRepository` 默认按“先本地、后远程、再回写”组织读取路径

当前状态：

- `DriftAppDatabase` 已接管 `LocalLibraryDataSource`、`PlaybackRestoreDataSource`、`LocalResourceIndexDataSource`、`DownloadTaskDataSource` 和 `UserScopedDataSource`
- 不再保留共享内存版本地库作为运行时兜底
- 开发期仍允许破坏性 schema 迁移；发布前必须补齐非破坏升级策略

### 6.6 Sync / Download

- `Sync` 负责将远程源数据写入本地库
- `Download` 负责离线音频、歌词、封面等资源管理
- 不允许在页面或普通 Controller 中临时拼接同步逻辑
- 下载相关能力默认视为核心链路，需要和播放优先级、离线模式一起设计

## 7. 领域模型与资源模型

### 7.1 领域模型

后续不再以 `MediaItem` 作为应用全局核心模型。

`MediaItem` 的定位：

- 播放层适配模型
- 用于 `audio_service` 和播放队列

应用层长期核心实体包括：

- `Track`
- `TrackLyrics`
- `AlbumEntity`
- `ArtistEntity`
- `PlaylistEntity`
- `PlaylistTrackRef`
- `PlaybackQueue`
- `DownloadTask`
- `SourceAccount`

`Track` 是内容实体，至少应具备：

- 应用内主键
- `sourceType`
- `sourceId`
- 标题
- 作者列表
- 专辑
- 时长
- 封面地址
- 远程播放地址
- 歌词引用
- 可用性状态
- 补充 metadata

本地音频、封面、歌词路径不再写回 `Track`。这些资源统一由 `local_resource_entries` 记录，并通过 `TrackWithResources / TrackResourceBundle` 向播放和展示链路补齐。

### 7.2 资源管理模型

为避免音频、歌词、封面各走一套临时逻辑，后续统一按资源模型处理。

资源分类固定为：

- 音频资源
- 歌词资源
- 封面资源

每类资源都必须明确：

- 来源：远程源返回、本地扫描发现、下载器生成
- 本地索引：在本地媒体库或等效索引中记录状态和路径
- 文件存储：写入应用管理的本地目录，而不是只依赖运行时缓存
- 消费优先级：本地文件优先，运行时缓存其次，远程地址兜底

#### 音频资源

- `local_resource_entries(kind=audio)` 表示本地可直接播放的文件路径
- `LocalResourceEntry.origin` 表示本地资源来自本地导入、受管下载、播放缓存或封面缓存
- `Track.remoteUrl` 仅作为远程兜底播放地址
- `DownloadTask` 负责记录下载过程态，下载成功后的最终资源状态进入 `local_resource_entries`
- 播放优先级固定为：本地音频资源 > 离线缓存文件 > 远程播放地址
- 下载系统需要把音频文件路径写入资源索引，并让上层通过 `TrackWithResources` 消费

原因：

- 播放器只需要关心当前是否存在本地可播放文件
- 统一由资源索引承载本地可用性，才能让本地扫描、本地下载、远程在线播放走同一条播放入口，同时避免把资源状态混回内容实体

#### 歌词资源

- 歌词实体统一使用 `TrackLyrics`
- 歌词缓存和歌词文件都需要映射回 `Track.lyricKey`
- 显示优先级固定为：本地歌词记录 > 本地歌词文件 > 远程歌词请求
- 离线模式下不再为歌词发起新的远程请求

原因：

- 歌词不是简单展示文案，而是和播放进度强绑定
- 如果歌词来源散落在 controller、缓存 key 和页面之间，后续很难稳定支持离线播放与恢复

#### 封面资源

- 远程封面地址仍记录在 `Track.artworkUrl`、`AlbumEntity.artworkUrl`、`PlaylistEntity.coverUrl`
- 封面文件下载后，需要在本地资源索引中记录本地路径
- 显示优先级固定为：本地封面文件 > 图片组件已有缓存 > 远程 URL
- 离线模式下，如果没有本地封面文件或运行时缓存，不再主动请求远程封面

当前阶段补充：

- 已新增独立本地资源索引入口，开始统一记录音频、封面、歌词三类本地资源路径
- `Track` 继续承载内容事实，资源索引负责记录各类本地文件的稳定落点
- `LibraryRepository` 需要优先汇总轨道实体与资源索引，再向上层暴露统一的 `TrackWithResources` 视图

原因：

- 封面不只是 UI 装饰，播放器背景取色和页面氛围都依赖它
- 如果封面完全依赖运行时网络图片缓存，离线模式会出现“歌曲能播但封面和主题失效”的体验断层

### 7.3 下载与离线文件生命周期

后续需要统一明确：

- 音频、歌词、封面资源的目录结构与命名规则
- “缓存资源”和“明确下载保存”的区别
- 文件失效、账号切换、资源删除时的清理策略
- 本地文件记录丢失或远程资源失效时的回退策略

当前默认偏好：

- 缓存资源允许被系统自动清理
- 下载资源默认不自动清理，除非用户主动删除
- 下载资源在正常内容流中可见，并带明确的已下载标记
- 下载记录属于全局资产，不因切换账号而删除
- 如来源账号能力失效，已下载的本地资源仍保持可播放，远程同步能力按当前账号重新判断

## 8. 工程目录

### 8.1 目标工程结构

```text
lib/
  app/
    bootstrap/
    routing/
  core/
    database/
    network/
    playback/
    storage/
  domain/
    entities/
  data/
    local/
    mappers/
    netease/
  features/
    album/
      presentation/
    artist/
      presentation/
    auth/
      presentation/
    cloud/
      presentation/
    comment/
      presentation/
    download/
      presentation/
    explore/
      presentation/
    library/
    local_media/
    playback/
      application/
      presentation/
    playlist/
      presentation/
    radio/
      presentation/
    search/
      presentation/
    settings/
      presentation/
    shell/
      presentation/
    user/
      presentation/
  routes/
  widget/
  common/
```

### 8.2 目标目录职责

- `app`
  - 启动流程、路由装配、依赖注入、主题和应用级配置
- `core`
  - 网络、存储、数据库、播放器、下载、同步等基础设施
- `domain`
  - 统一实体与稳定业务模型
- `data`
  - 本地数据库实现、网易云远程实现、仓库实现、领域映射
- `features`
  - 业务功能模块，页面、controller、application service 和 feature repository 按模块内聚
  - `presentation` 只放页面、局部组件和展示 controller
  - `application` 只放 feature 内部编排与平台适配入口
- `widget`
  - 跨页面复用的通用 UI 组件和滚动行为
- `common`
  - 历史兼容目录，仅保留常量、歌词解析和少量旧基础能力；不再承载网易云远程层

### 8.3 当前目录职责与保留原因

当前仓库处于“旧结构仍承担主流程，新结构逐步接管能力入口”的迁移阶段。

#### 顶层目录

- `android / ios`
  - 平台工程、原生配置、插件集成与打包入口
- `assets`
  - 图片、动画、字体和其他静态资源
- `docs`
  - 架构设计、重构计划、注释规范等长期规则文档
- `test`
  - 单测、集成测试、回归验证脚本

#### `lib` 一级目录

- `lib/main.dart`
  - 仅保留应用启动入口
- `lib/app`
  - 应用级初始化、路由和后续应用外壳入口
- `lib/common`
  - 历史公共能力目录，当前保留常量、歌词解析和少量旧基础代码
- `lib/core`
  - 稳定基础设施能力，当前包含 `database / network / storage / playback codec`
- `lib/data`
  - 数据层实现细节，当前已包含 `local / netease`，远程平台代码统一归位到 `data/netease`
  - `features/**` 不再直接 import `NeteaseMusicApi` 或 `netease_api.dart`
- `lib/domain`
  - 统一领域实体
- `lib/features`
  - 正式业务模块目录，页面入口已并入 `features/*/presentation`
- `lib/generated / lib/generator`
  - 生成代码和生成相关逻辑
- `lib/features/*/presentation`
  - feature 页面和页面内组合组件
- `lib/routes`
  - 当前路由声明与生成入口
- `lib/widget`
  - 通用 UI 组件和滚动辅助能力，`common` 中的共享 UI 已开始迁入这里或对应 feature

目录边界：

- 不再新增全局页面目录
- 新页面默认进入对应 feature 的 `presentation`
- 共享展示组件进入 `widget`，业务组件留在 feature 内

### 8.4 当前到目标目录的映射

- `lib/common`
  - 逐步拆到 `core / data / widget / features`
- `lib/features/*/presentation`
  - 当前作为唯一页面层，模块内稳定复用组件继续留在对应 feature
- `lib/routes`
  - 保留 `auto_route` 声明与生成结果，不再额外拆第三套路由目录
- `lib/widget`
  - 作为共享 UI 的主要落点继续保留
- `lib/features/*`
  - 默认采用扁平结构，只有同一模块下同时存在多类职责文件时，才新增 `controller` 等子目录

### 8.5 为什么采用这种结构

- `app / core / domain / data / features / pages / widget / common` 已足够表达当前工程的职责边界
- 这样分是为了避免继续用“页面目录 + 全局 controller”组织复杂应用，同时不把目录预留得比当前实现更大
- 当前不做一次性目录大搬迁，因为先搬目录再拆职责，容易造成“文件位置变了，但耦合关系没变”
- `features` 先收能力入口而不是先迁页面，是因为数据入口最容易产生跨模块副作用，先收数据入口收益最大
- 默认不新增 `repository` 子目录，是为了避免轻量模块因为预留结构过多而增加路径深度

## 9. 边界规则

### 9.1 页面层

页面层只负责：

- 布局展示
- 用户交互
- 状态订阅
- 路由触发

页面层禁止直接承担：

- 接口编排
- 登录轮询
- 本地缓存读写策略
- 本地数据库读写策略
- `MediaItem` 拼装
- 分页参数管理
- 业务流程协调

补充：

- 搜索页默认展示单一结果流，不强制拆成本地分区和远程分区
- 下载资源在正常页面流中应保持可见，并通过状态标记表达离线可用

### 9.2 Controller

Controller 负责：

- 页面状态
- 视图所需的可观察数据
- 调用业务入口

Controller 禁止继续膨胀为：

- API 封装层
- 缓存实现层
- 本地数据库实现层
- 多模块总控层

### 9.3 Repository

Repository 负责：

- 调用远程源
- 访问本地缓存与本地数据库
- 合并远程和本地数据
- 输出面向业务的结果

默认优先级：

- 先读本地
- 再决定是否同步远程
- 最后将结果写回本地

### 9.4 Mapper

- 统一提供模型映射能力
- 禁止在页面和零散组件中重复定义映射逻辑

### 9.5 Source

源适配器负责：

- 适配某个远程平台或本地扫描结果
- 输出统一领域数据
- 隐藏平台差异

源适配器禁止：

- 直接参与页面展示逻辑
- 直接维护 UI 状态
- 直接决定本地库读写策略

### 9.6 基础设施

`NeteaseMusicApi`、`Hive Box`、播放器底层实例属于基础设施。

规则：

- 不允许在页面中直接随意获取
- 不允许成为每个 Controller 的默认直连依赖
- 后续新增数据库实例、下载器、文件扫描器同样属于基础设施

## 10. 渐进执行策略

默认执行策略：

1. 优先改单条业务链路，不一次性重写整块页面
2. 优先建立统一入口，再逐步替换旧调用方
3. 优先把本地优先跑通，再补齐正式数据库实现
4. 优先把网易云远程层与本地能力的边界理顺，再继续清理旧平台直连
5. 每轮只扩大一个风险面，例如只改搜索、只改播放、只改本地库

当前推荐执行顺序：

1. 搜索剩余几栏接入统一入口
2. 清理播放链路残余平台直连
3. 引入 `Drift` 并落地正式本地库实现
4. 实现 `LocalMusicSource`
5. 推进下载与离线体系
6. 再处理更彻底的目录迁移和服务层拆分

## 11. 优先收口的职责线

### 11.1 Shell 壳层

重点文件：

- [`lib/features/shell/shell_controller.dart`](../lib/features/shell/shell_controller.dart)
- [`lib/features/shell/presentation/app_home_page_view.dart`](../lib/features/shell/presentation/app_home_page_view.dart)
- [`lib/features/shell/presentation/app_body_page_view.dart`](../lib/features/shell/presentation/app_body_page_view.dart)

目标：

- 壳层 UI 状态独立
- 播放业务入口和内容加载入口移出壳层

### 11.2 Playback 播放链路

重点文件：

- [`lib/features/playback/player_controller.dart`](../lib/features/playback/player_controller.dart)
- [`lib/core/playback/audio_service_handler.dart`](../lib/core/playback/audio_service_handler.dart)

目标：

- 控制器只负责暴露状态
- 播放用例和队列切换逻辑沉到 service / repository

### 11.3 User Content 内容数据线

重点文件：

- [`lib/features/user/user_controller.dart`](../lib/features/user/user_controller.dart)
- [`lib/features/playlist/presentation/playlist_page_view.dart`](../lib/features/playlist/presentation/playlist_page_view.dart)
- [`lib/features/cloud/presentation/cloud_drive_view.dart`](../lib/features/cloud/presentation/cloud_drive_view.dart)
- [`lib/features/auth/presentation/login_page_view.dart`](../lib/features/auth/presentation/login_page_view.dart)

目标：

- 页面不再承载用例逻辑
- 数据获取统一经由 repository

## 12. 当前阶段不做的事

- 不立即迁移到 `Riverpod`
- 不引入额外服务定位器
- 不替换 `auto_route`
- 不替换 `Dio`
- 不立即替换 `Hive`
- 不在当前阶段直接接入第二个远程音乐源

这些事项只有在本地优先数据流和统一实体稳定后才允许重新评估。

## 13. 文档维护规则

如果后续发生以下任一事项，必须更新本文档：

- 确定新的模块边界
- 调整目录结构方案
- 替换核心技术方案
- 增加新的架构约束

更新原则：

- 先更新文档，再推进后续阶段性重构
- 架构边界、目录职责、核心模型、资源规则、技术决策变化时，优先更新本文档
- 阶段状态、完成项、风险和下一步以 [`03-refactor-plan.md`](./03-refactor-plan.md) 为主
- 本地缓存、表结构、账号作用域和 ID 规则以 [`02-local-cache-architecture.md`](./02-local-cache-architecture.md) 为主
- 新核心能力落地且同时影响架构边界与阶段进度时，相关文档都要更新
