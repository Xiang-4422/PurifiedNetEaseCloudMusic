# 技术架构设计

## 1. 文档目标

本文档用于固定本项目后续的技术架构、工程目录架构、边界规则与演进方向。

后续所有重构工作都必须满足两个原则：

- 基于当前仓库真实结构渐进演进
- 优先修复职责边界，不以更换框架为首要目标

同时从本版本开始，架构目标正式升级为：

- 从“适配网易云接口的播放器”演进为“本地优先的多源音乐播放器”
- 支持远程源、本地媒体库、离线缓存与无网络可用
- 所有功能优先以本地数据为应用事实来源

## 2. 当前仓库现状

当前项目已经具备较完整的功能骨架，但职责分布存在明显交叉：

- [`lib/controllers/app_controller.dart`](../lib/controllers/app_controller.dart) 同时承担应用壳层 UI 状态、播放入口、歌单加载入口和一部分业务编排
- [`lib/controllers/player_controller.dart`](../lib/controllers/player_controller.dart) 与 [`lib/common/bujuan_audio_handler.dart`](../lib/common/bujuan_audio_handler.dart) 已形成播放链路，但仍直接依赖缓存、API 和其他 Controller
- [`lib/controllers/user_controller.dart`](../lib/controllers/user_controller.dart) 同时承担用户状态、推荐内容、喜欢歌曲、FM、心动模式数据拉取
- 多个页面包含用例逻辑和数据访问逻辑，例如：
  - [`lib/pages/login/login_page_view.dart`](../lib/pages/login/login_page_view.dart)
  - [`lib/pages/play_list/playlist_page_view.dart`](../lib/pages/play_list/playlist_page_view.dart)
  - [`lib/pages/cloud/cloud_drive_view.dart`](../lib/pages/cloud/cloud_drive_view.dart)
  - [`lib/pages/home/top_panel/top_panel_view.dart`](../lib/pages/home/top_panel/top_panel_view.dart)
- 请求组件不仅负责展示，还承担接口请求、分页与解析逻辑：
  - [`lib/widget/request_widget/request_view.dart`](../lib/widget/request_widget/request_view.dart)
  - [`lib/widget/request_widget/request_loadmore_view.dart`](../lib/widget/request_widget/request_loadmore_view.dart)

结论：

- 当前问题的核心不是基础设施选型错误
- 当前问题的核心是业务职责落点不清晰
- 当前数据流仍然以远程接口为中心，不满足后续多源与离线目标

## 3. 目标升级

本项目后续的正式产品目标为：

- 支持多个音乐源，而不仅限于网易云
- 支持本地扫描、本地播放与离线播放
- 支持网络不可用时继续浏览本地库、播放已缓存内容、查看历史数据
- 支持将远程源内容同步到本地媒体库，供 UI 和播放器统一消费

因此，后续架构设计不再以“某个远程 API 能提供什么”为中心，而以“播放器应用需要什么能力”为中心。

## 4. 架构决策

## 4.1 总体架构风格

本项目后续采用：

`Local-First + Source-Driven + Feature-Oriented + Gradual Refactor`

即：

- 本地媒体库是应用的主数据入口
- 远程音乐源和本地扫描器都作为数据源适配器存在
- 以功能模块划分工程结构
- 在模块内保持展示层、状态层、数据访问层的清晰边界
- 在保留现有运行能力的前提下渐进重构

## 4.2 核心数据流定案

后续所有模块默认遵守以下数据流：

`UI / Controller -> Use Case / Repository -> Local Database -> Source Adapter / Sync -> Remote`

解释：

- UI 优先读取本地数据库或本地缓存，不直接依赖远程响应
- 远程接口、扫描器、下载器负责写入本地库，而不是直接充当页面数据源
- 播放器优先消费统一媒体实体与本地可播放地址
- 远程请求主要承担同步、补全和刷新职责

### 本地优先规则

- 列表页、搜索页、歌单页优先展示本地库已有数据
- 网络可用时后台同步并刷新本地库
- 离线模式下只要本地库和缓存存在，应用仍可工作
- 播放逻辑优先选择本地文件，其次选择可用的远程播放地址

## 4.3 技术架构定案

### 保留并继续使用

#### Flutter

- 继续作为唯一 UI 框架

#### GetX

- 现阶段保留，继续服务已有存量模块
- 不再扩张“大型总控 Controller”写法
- 不作为未来无限扩展的架构核心

说明：

- 当前仓库大量逻辑依赖 `GetX`
- 立即迁移状态管理框架收益低、风险高
- 当前首要问题是职责边界，而不是框架替换

#### GetIt

- 仅保留为基础设施单例容器
- 允许用于底层服务和存储实例
- 不再扩张到页面和业务层的任意依赖获取

#### auto_route

- 继续作为路由方案
- 不进行替换

#### Dio

- 继续作为网络层基础客户端

#### Hive

- 继续作为轻量本地存储
- 主要用于设置、登录态、播放恢复、轻量缓存

限制：

- `Hive` 不再承担完整媒体库职责
- 歌曲、歌单、下载、搜索索引、播放历史等结构化数据后续迁移到独立本地数据库

#### 结构化本地数据库

- 后续新增结构化本地数据库，作为媒体库主存储
- 倾向选型：`Isar`
- 用途包括：
  - 曲库索引
  - 歌单及歌单歌曲关系
  - 本地扫描结果
  - 下载状态
  - 离线文件索引
  - 播放历史和最近播放
  - 搜索缓存与本地搜索入口

在本地数据库正式落地前：

- 允许继续用 `Hive` 做过渡缓存
- 但新增代码必须按“未来会迁移到结构化库”的方式设计接口

#### just_audio + audio_service

- 继续作为音频播放底层方案
- 后续重点是梳理播放业务层，而不是替换底层播放器

### 明确新增的架构层与抽象

#### Repository 层

新增并强制落地：

- 页面与大部分 Controller 不再直接访问 `NeteaseMusicApi`
- 数据访问逻辑统一经由 `Repository`
- `Repository` 负责组合本地库、轻缓存、远程源与领域转换
- `Repository` 的长期职责中心是应用能力，而不是某个接口能力

#### Mapper 层

新增并强制落地：

- 所有 `Song2`、`CloudSongItem`、歌单详情等到 `MediaItem` 的转换，统一收口
- 禁止在页面里重复拼装 `MediaItem`

#### Shell 协调层

新增并强制落地：

- 将首页壳层 UI 状态与业务入口分离
- `AppController` 的长期目标是拆薄，壳层状态独立

#### MusicSource 抽象

后续新增并强制落地：

- 所有远程源、本地扫描源都通过统一 `MusicSource` 或等效协议接入
- 每个源实现自己的能力适配，而不是把源差异泄漏到页面层

源能力示例：

- 获取歌单
- 获取歌曲详情
- 搜索
- 获取歌词
- 获取播放地址
- 同步用户数据
- 授权与登录

注意：

- 不要求每个源都支持全部能力
- 需要允许“部分能力缺失”的实现

当前阶段补充：

- 网易云已经开始通过 `NeteaseMusicSource` 接入统一 source 协议
- 后续新增源必须优先实现 source 适配层，而不是直接把平台 API 暴露给页面或 controller

#### Local Library 抽象

后续新增并强制落地：

- 建立统一本地媒体库接口
- UI、播放控制器、搜索优先从本地媒体库读取
- 同步器和下载器通过媒体库接口写入数据

在本地数据库正式接管前：

- 允许先通过 `LibraryRepository` 收口统一实体读取入口
- 允许通过 `MusicSourceRegistry` 统一管理多源分发，避免 repository 再次直接耦合单一平台实现
- `LibraryRepository` 默认按“先本地、后远程、再回写”组织读取路径，避免未来接入本地库时再整体改业务调用链
- 允许保留一个共享的内存版本地库实现，作为 `Isar` 接入前的过渡层，用于验证本地优先的数据流

#### Sync / Download 抽象

后续新增并强制落地：

- `Sync` 负责将远程源数据写入本地库
- `Download` 负责离线音频、歌词、封面等资源管理
- 不允许在页面或普通 Controller 中临时拼接同步逻辑

## 4.4 领域模型方向

后续不再以 `MediaItem` 作为应用全局核心模型。

`MediaItem` 的定位：

- 播放层适配模型
- 用于 `audio_service` 和播放队列

应用层的长期核心实体应包括：

- `Track`
- `TrackLyrics`
- `AlbumEntity`
- `ArtistEntity`
- `PlaylistEntity`
- `PlaylistTrackRef`
- `PlaybackQueue`
- `DownloadTask`
- `SourceAccount`

其中 `Track` 至少应具备：

- 应用内主键
- `sourceType`
- `sourceId`
- 标题
- 作者列表
- 专辑
- 时长
- 封面地址
- 远程播放地址
- 本地文件路径
- 歌词引用
- 下载状态
- 可用性状态

## 4.5 当前阶段不做的事

- 不立即迁移到 `Riverpod`
- 不替换 `auto_route`
- 不替换 `Dio`
- 不立即替换 `Hive`
- 不进行一次性目录大搬迁
- 不在当前阶段直接接入第二个远程音乐源

这些事项后续只有在本地优先数据流和统一实体已经稳定后才允许重新评估。

## 5. 边界规则

以下规则从本文档落地起生效。

### 5.1 页面层规则

页面层只负责：

- 布局展示
- 用户交互
- 订阅状态
- 路由触发

页面层禁止直接承担：

- 接口编排
- 登录轮询
- 本地缓存读写策略
- 本地数据库读写策略
- `MediaItem` 拼装
- 分页参数管理
- 业务流程协调

### 5.2 Controller 规则

Controller 负责：

- 页面状态
- 视图所需的可观察数据
- 调用业务入口

Controller 禁止继续膨胀为：

- API 封装层
- 缓存实现层
- 本地数据库实现层
- 多模块总控层

### 5.3 Repository 规则

Repository 负责：

- 调用远程源
- 访问本地缓存与本地数据库
- 合并远程和本地数据
- 输出面向业务的结果

Repository 默认优先级：

- 先读本地
- 再决定是否同步远程
- 最后将结果写回本地

### 5.4 Mapper 规则

统一提供模型映射能力，例如：

- `Song2 -> MediaItem`
- `CloudSongItem -> MediaItem`
- `Remote Track -> Track`
- `Local Scan Result -> Track`
- API Bean -> 页面可消费对象

禁止在页面和零散组件中重复定义映射逻辑。

### 5.5 Source 规则

源适配器负责：

- 适配某个远程平台或本地扫描结果
- 输出统一的领域数据
- 隐藏平台差异

源适配器禁止：

- 直接参与页面展示逻辑
- 直接维护 UI 状态
- 直接决定本地库读写策略

### 5.6 基础设施规则

`NeteaseMusicApi`、`Hive Box`、播放器底层实例属于基础设施。

基础设施对象：

- 不允许在页面中直接随意获取
- 不允许成为每个 Controller 的默认直连依赖

后续新增的数据库实例、下载器、文件扫描器同样属于基础设施。

## 6. 目标工程文件架构

当前仓库不做一次性大迁移，但目标目录结构固定如下：

```text
lib/
  app/
    bootstrap/
    di/
    routing/
    theme/
  core/
    network/
    storage/
    database/
    playback/
    sync/
    download/
    utils/
  domain/
    entities/
    repositories/
    sources/
    services/
  features/
    shell/
      presentation/
      controller/
    auth/
      presentation/
      controller/
      repository/
    user/
      presentation/
      controller/
      repository/
    playlist/
      presentation/
      controller/
      repository/
    explore/
      presentation/
      controller/
      repository/
    cloud/
      presentation/
      controller/
      repository/
    playback/
      presentation/
      controller/
      service/
      repository/
    library/
      presentation/
      controller/
      repository/
    local_media/
      presentation/
      controller/
      repository/
    search/
      presentation/
      controller/
      repository/
    download/
      presentation/
      controller/
      repository/
  data/
    local/
    remote/
    sources/
    repositories/
    mappers/
  shared/
    widgets/
    mappers/
    models/
```

## 7. 核心模块职责

### app

- 启动流程
- 路由装配
- 依赖注入
- 主题和应用级配置

### core

- 网络、存储、数据库、播放器、下载、同步等基础设施

### domain

- 统一实体
- 仓库接口
- 源协议
- 领域服务

### data

- 本地数据库实现
- 远程源实现
- 多源适配
- 仓库实现
- 领域映射

### features

- 业务功能模块
- 页面、页面状态、模块级用例

### shared

- 跨 feature 共享的 UI 与轻量工具

## 8. 当前目录到目标目录的映射

### 现有目录

- `lib/common`
- `lib/controllers`
- `lib/pages`
- `lib/routes`
- `lib/widget`

### 目标映射原则

#### `lib/common`

逐步拆分到：

- `lib/core`
- `lib/shared`
- `lib/features/*/repository`

其中：

- 网易云 API 相关最终落到 `data/remote` 或 `data/sources/netease`
- 通用播放器与播放基础设施最终落到 `core/playback`

#### `lib/controllers`

逐步拆分到：

- `lib/features/*/controller`
- `lib/features/playback/service`
- `lib/features/shell/controller`

#### `lib/pages`

逐步拆分到：

- `lib/features/*/presentation`

#### `lib/routes`

逐步并入：

- `lib/app/routing`

#### `lib/widget`

逐步拆分到：

- `lib/shared/widgets`
- 需要保留业务语义的部分移动到对应 `feature/presentation`

## 7. 优先收口的职责线

后续重构优先围绕以下三条业务线进行：

### 7.1 Shell 壳层

重点文件：

- [`lib/controllers/app_controller.dart`](../lib/controllers/app_controller.dart)
- [`lib/pages/home/app_home_page_view.dart`](../lib/pages/home/app_home_page_view.dart)
- [`lib/pages/home/body/app_body_page_view.dart`](../lib/pages/home/body/app_body_page_view.dart)

目标：

- 壳层 UI 状态独立
- 播放业务入口和内容加载入口移出壳层

### 7.2 Playback 播放链路

重点文件：

- [`lib/controllers/player_controller.dart`](../lib/controllers/player_controller.dart)
- [`lib/common/bujuan_audio_handler.dart`](../lib/common/bujuan_audio_handler.dart)

目标：

- 控制器只负责暴露状态
- 播放用例和队列切换逻辑沉到 service/repository

### 7.3 User Content 内容数据线

重点文件：

- [`lib/controllers/user_controller.dart`](../lib/controllers/user_controller.dart)
- [`lib/pages/play_list/playlist_page_view.dart`](../lib/pages/play_list/playlist_page_view.dart)
- [`lib/pages/cloud/cloud_drive_view.dart`](../lib/pages/cloud/cloud_drive_view.dart)
- [`lib/pages/login/login_page_view.dart`](../lib/pages/login/login_page_view.dart)

目标：

- 页面不再承载用例逻辑
- 数据获取统一经由 repository

## 8. 架构执行准则

从本文档生效起，新增代码必须遵守以下准则：

- 不新增新的超大总控 Controller
- 不在页面中新增直接调用 `NeteaseMusicApi` 的代码
- 不在页面中新增直接访问 `Hive Box` 的代码
- 不在页面或零散组件中新增 `MediaItem` 拼装逻辑
- 新增业务逻辑优先落到对应 feature 的 repository 或 service
- 所有结构调整以最小风险迁移为前提

## 9. 文档维护规则

如果后续发生以下任一事项，必须更新本文档：

- 确定新的模块边界
- 调整目录结构方案
- 替换核心技术方案
- 增加新的架构约束

文档更新原则：

- 先更新文档，再推进后续阶段性重构
