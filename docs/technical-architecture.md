# 技术架构设计

## 1. 文档目标

本文档用于固定本项目的技术架构、工程目录、边界规则和演进方向。

后续所有重构默认遵守两条原则：

- 基于当前仓库真实结构渐进演进
- 优先修复职责边界，不以更换框架为首要目标

当前架构目标已经升级为：

- 从“适配网易云接口的播放器”演进为“本地优先的多源音乐播放器”
- 支持远程源、本地媒体库、离线缓存与无网络可用
- 所有功能优先以本地数据为事实来源

## 2. 当前仓库现状

当前项目功能完整，但职责分布仍然交叉：

- [`lib/features/shell/app_controller.dart`](../lib/features/shell/app_controller.dart) 同时承担壳层 UI 状态、播放入口和部分业务编排
- [`lib/features/playback/player_controller.dart`](../lib/features/playback/player_controller.dart) 与 [`lib/core/playback/audio_service_handler.dart`](../lib/core/playback/audio_service_handler.dart) 已形成播放链路，但仍混有缓存、API 和跨控制器依赖
- [`lib/features/user/user_controller.dart`](../lib/features/user/user_controller.dart) 同时承担用户状态、推荐内容、喜欢歌曲、FM、心动模式等职责
- 多个页面仍承载用例逻辑和数据访问逻辑，例如：
  - [`lib/pages/login_page_view.dart`](../lib/pages/login_page_view.dart)
  - [`lib/pages/playlist_page_view.dart`](../lib/pages/playlist_page_view.dart)
  - [`lib/pages/cloud_drive_view.dart`](../lib/pages/cloud_drive_view.dart)
  - [`lib/pages/home/top_panel_view.dart`](../lib/pages/home/top_panel_view.dart)
- 旧 `request_widget` 已移除，请求执行权已从页面和通用组件回收到 feature controller 与 repository

结论：

- 当前问题不是基础设施选型本身错误
- 当前问题是职责落点不清晰
- 当前数据流仍带有“远程接口为中心”的历史惯性，不满足多源与离线目标

## 3. 目标与关键决策

### 3.1 产品目标

- 支持多个音乐源，而不仅限于网易云
- 支持本地扫描、本地播放与离线播放
- 支持无网络时继续浏览本地库、播放已缓存内容、查看历史数据
- 支持将远程源内容同步到本地媒体库，供 UI 和播放器统一消费

### 3.2 当前确认的关键决策

以下决策作为当前阶段默认前提，变更前必须先更新本文档：

- 本地数据库目标选型：`Isar`
- 搜索策略：本地优先，远程补充并回写
- 本地音乐源是正式目标能力，不是附属功能
- 离线下载是核心能力，不是可选增强
- 允许在过渡期保留 `Hive + 正式本地数据库 + 旧页面/新入口` 并存
- 允许分链路渐进迁移，不要求单个页面一次性完成全部改造

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

`Local-First + Source-Driven + Feature-Oriented + Gradual Refactor`

含义：

- 本地媒体库是应用主数据入口
- 远程音乐源和本地扫描器都作为 source adapter 存在
- 业务代码按 feature 组织
- 在模块内保持展示层、状态层、数据访问层的清晰边界
- 在保留现有运行能力的前提下渐进重构

### 4.2 核心数据流

后续默认数据流如下：

`UI / Controller -> Repository / Service -> Local Library -> Source Adapter / Sync -> Remote`

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
  - 播放恢复状态
  - 离线模式开关
  - 极轻量配置缓存
- 正式本地媒体库
  - 歌曲
  - 歌词
  - 歌单及歌单关系
  - 播放历史
  - 最近播放
  - 下载记录
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
  - 现阶段保留，用于已有存量模块
  - 不再扩张“大型总控 Controller”写法
- `GetIt`
  - 仅保留为基础设施单例容器
  - 不再扩张到页面和业务层的任意依赖获取
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
  - 目标选型：`Isar`
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

### 6.3 Shell 协调层

- 首页壳层 UI 状态与业务入口分离
- `AppController` 的长期目标是拆薄
- 壳层状态独立为 `features/shell/controller`
- 页面不应直接驱动 `audioHandler`，也不应继续通过 `AppController` 充当播放代理；播放主链路统一经由 `PlayerController` 暴露入口
- `PlayerController` 不再直接初始化底层播放器实例，音频服务生命周期统一收口到 `PlaybackService`
- 漫游模式续队列、喜欢歌曲播放和模式初始化等队列编排优先下沉到 `PlaybackService`，控制器只保留状态与交互协作
- `AudioServiceHandler` 不再直接反向依赖 `PlayerController`，上层状态同步改为通过 `PlaybackService` 显式绑定回调
- `AudioServiceHandler` 不再直接读取 `SettingsController` 或 `UserController`，底层所需偏好和交互入口统一通过 `PlaybackService` 注入
- 播放模式、重复模式、当前歌单名等展示态开始收口为 `PlaybackSessionState`，旧分散字段暂时保留作为兼容层
- 播放恢复信息开始收口为 `PlaybackRestoreState`，当前项、歌单元信息、队列、模式和进度不再继续以散落 key 分别理解
- 当前队列、当前歌曲、当前索引和当前进度开始收口为 `PlaybackRuntimeState`，旧运行态字段暂时保留作为页面兼容层
- 歌词行、当前歌词索引和翻译歌词标记开始收口为 `PlaybackLyricState`，避免歌词解析结果继续散落在控制器兼容字段中
- `PlaybackStateStore` 只保留播放恢复轻存储的底层实现；歌词内容改由媒体库承接
- 播放恢复态的读写主入口已切到 `PlaybackRepository`，控制器和底层 handler 不再直接操作轻存储
- 播放恢复态已从 `LocalLibraryDataSource` 拆出，改由独立的 `PlaybackRestoreDataSource` 承接
- 播放恢复态会同时写入轻存储快照和恢复态数据源，为后续正式数据库接管保留稳定入口
- 播放恢复态在轻存储中采用单一快照格式，后续迁正式本地库时优先复用该快照结构
- 壳层与主播放面板已开始消费统一播放状态对象，后续页面迁移优先复用这些状态而不是继续增加散落 getter
- 底部播放面板的队列列表、头部信息、当前歌曲封面和进度读取已优先改用 `PlaybackRuntimeState`，旧运行态字段开始退回兼容入口
- `PlayerController` 内部逻辑已优先读取 `sessionState / runtimeState / lyricState`，旧 `curPlaying* / curPlay* / lyrics*` 字段逐步退为页面兼容镜像
- `AppController` 中直接暴露旧运行态与歌词态的兼容 getter 已移除，壳层统一改经 `PlaybackSessionState / PlaybackRuntimeState / PlaybackLyricState` 读取播放状态
- `PlayerController` 中旧 `curPlaying* / curPlay* / lyrics*` 兼容字段已移除，播放控制器与页面层统一开始以播放状态对象为唯一事实源
- 页面层对 `curPlayListName / curPlayListNameHeader / isPlayingLikedSongs` 的依赖已切到 `PlaybackSessionState`，会话态兼容字段开始退出壳层和控制器

### 6.4 MusicSource

- 所有远程源、本地扫描源都通过统一 `MusicSource` 协议接入
- 每个源只负责能力适配，不把平台差异泄漏到页面层
- 不要求每个源支持全部能力，但要允许能力缺失

当前阶段补充：

- 网易云已通过 `NeteaseMusicSource` 接入统一 source 协议
- `LocalMusicSource` 的职责不仅是扫描文件，还包括提供统一 `Track`、本地搜索和可播放地址
- 过渡期的 source、媒体库与应用能力入口应优先通过启动阶段统一注册，避免 repository 在运行时各自 new 出分裂数据视图

### 6.5 Local Library

- UI、播放控制器、搜索优先从本地媒体库读取
- 同步器和下载器通过媒体库接口写入数据
- `LibraryRepository` 默认按“先本地、后远程、再回写”组织读取路径

在正式数据库接管前：

- 允许保留共享的内存版本地库实现，用于验证本地优先数据流
- 当共享内存实现无法覆盖跨重启场景时，应先切到可持久化的过渡实现，再进入正式数据库迁移

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

`Track` 至少应具备：

- 应用内主键
- `sourceType`
- `sourceId`
- 标题
- 作者列表
- 专辑
- 时长
- 封面地址
- 本地封面路径
- 远程播放地址
- 本地文件路径
- 歌词引用
- 本地歌词路径
- 资源来源
- 下载状态
- 下载进度
- 下载失败原因
- 可用性状态

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

- `Track.localPath` 表示本地可直接播放的文件路径
- `Track.resourceOrigin` 表示本地资源来自本地导入还是受管下载
- `Track.remoteUrl` 仅作为远程兜底播放地址
- `Track.downloadProgress` 和 `Track.downloadFailureReason` 记录下载链路的稳定状态
- `DownloadTask` 负责记录下载过程态，`Track` 只承载最终资源状态
- 播放优先级固定为：`localPath > 离线缓存文件 > 远程播放地址`
- 下载系统需要把音频文件路径和下载状态写回 `Track`

原因：

- 播放器只需要关心当前是否存在本地可播放文件
- 统一由 `Track` 承载音频可用性，才能让本地扫描、本地下载、远程在线播放走同一条播放入口

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
- `Track` 继续承载最终资源结果，资源索引负责记录各类本地文件的稳定落点
- `LibraryRepository` 需要优先汇总轨道实体与资源索引，再向上层暴露统一的本地资源视图

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
    sources/
  data/
    local/
    mappers/
    sources/
  features/
    album/
    artist/
    auth/
      controller/
    cloud/
    comment/
    download/
    explore/
      controller/
    library/
    local_media/
    playback/
      controller/
    playlist/
    radio/
    search/
    settings/
    shell/
      controller/
    user/
      controller/
  pages/
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
  - 统一实体、仓库接口、源协议、领域服务
- `data`
  - 本地数据库实现、远程源实现、多源适配、仓库实现、领域映射
- `features`
  - 业务功能模块，默认直接在模块根目录放能力文件，只有角色明显分化时才增加子目录
- `pages`
  - 当前唯一页面层，继续承担 presentation 职责，暂不再新增第二套 presentation 目录
- `widget`
  - 跨页面复用的通用 UI 组件和滚动行为
- `common`
  - 历史兼容目录，仅保留常量、歌词解析和网易云 API 等旧基础能力

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
  - 历史公共能力目录，当前仍包含常量、歌词解析、网易云 API 适配和少量旧基础代码
- `lib/core`
  - 已开始承接稳定基础设施能力，当前已包含 `database / network / storage / playback`
- `lib/data`
  - 数据层实现细节，当前已包含 `local / mappers / sources`
- `lib/domain`
  - 统一领域实体与多源协议
- `lib/features`
  - 正式业务模块目录，当前已开始承接各 feature 的能力入口与核心 controller
- `lib/generated / lib/generator`
  - 生成代码和生成相关逻辑
- `lib/pages`
  - 历史页面和页面内组合组件，当前仍承担主要 UI 结构
- `lib/routes`
  - 当前路由声明与生成入口
- `lib/widget`
  - 通用 UI 组件和滚动辅助能力，`common` 中的共享 UI 已开始迁入这里或对应 feature

保留原因：

- 当前仍有大量旧页面和控制器承担主流程
- 先拆职责、再迁目录，比一次性搬文件更安全

### 8.4 当前到目标目录的映射

- `lib/common`
  - 逐步拆到 `core / data / widget / features`
- 原 `lib/controllers`
  - 已进入移除阶段，职责继续拆到 `features/*/controller`、`features/playback/service`、`features/shell/controller`
- `lib/pages`
  - 当前继续作为唯一页面层，只有在模块内出现稳定复用的局部组件时，才逐步往对应 `feature` 或 `widget` 迁移
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
4. 优先把多源协议跑通，再新增第二个 source
5. 每轮只扩大一个风险面，例如只改搜索、只改播放、只改本地库

当前推荐执行顺序：

1. 搜索剩余几栏接入统一入口
2. 清理播放链路残余平台直连
3. 引入 `Isar` 并落地正式本地库实现
4. 实现 `LocalMusicSource`
5. 推进下载与离线体系
6. 再处理更彻底的目录迁移和服务层拆分

## 11. 优先收口的职责线

### 11.1 Shell 壳层

重点文件：

- [`lib/features/shell/app_controller.dart`](../lib/features/shell/app_controller.dart)
- [`lib/pages/home/app_home_page_view.dart`](../lib/pages/home/app_home_page_view.dart)
- [`lib/pages/home/body/app_body_page_view.dart`](../lib/pages/home/body/app_body_page_view.dart)

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
- [`lib/pages/playlist_page_view.dart`](../lib/pages/playlist_page_view.dart)
- [`lib/pages/cloud_drive_view.dart`](../lib/pages/cloud_drive_view.dart)
- [`lib/pages/login_page_view.dart`](../lib/pages/login_page_view.dart)

目标：

- 页面不再承载用例逻辑
- 数据获取统一经由 repository

## 12. 当前阶段不做的事

- 不立即迁移到 `Riverpod`
- 不替换 `auto_route`
- 不替换 `Dio`
- 不立即替换 `Hive`
- 不进行一次性目录大搬迁
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
- 阶段状态、完成项、风险和下一步以 `refactor-plan.md` 为主
- 新核心能力落地且同时影响架构边界与阶段进度时，两份文档都要更新
