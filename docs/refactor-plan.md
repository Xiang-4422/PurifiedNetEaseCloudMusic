# 重构计划与进度

## 1. 文档目标

本文档用于固定本项目的阶段性重构计划、执行顺序、验收标准和进度记录方式。

每次阶段性重构完成后，都必须同步更新：

- 阶段状态
- 已完成事项
- 进行中事项
- 风险与阻塞

## 2. 重构原则

- 优先解决职责边界问题
- 优先低风险、小步快跑
- 重构期间保证现有功能可运行
- 每阶段结束后都需要形成可验证成果
- 所有长期设计都以“第三方网易云客户端 + 本地优先 + 离线可用”为目标

## 3. 阶段总览

| 阶段 | 名称 | 目标 | 状态 |
| --- | --- | --- | --- |
| Phase 0 | 文档定案 | 固定技术架构、工程结构和执行计划 | Done |
| Phase 1 | 基础边界收口 | 停止新债继续扩散，建立 repository 和 mapper 落点 | In Progress |
| Phase 2 | Shell 拆分 | 将 `AppController` 中的壳层状态和业务入口拆开 | In Progress |
| Phase 3 | 统一领域模型 | 建立 `Track`、`PlaylistEntity` 等统一实体，停止以网易云模型直接驱动业务 | In Progress |
| Phase 4 | 本地优先数据层 | 引入结构化本地数据库，建立本地媒体库和同步入口 | Planned |
| Phase 5 | 播放链路重构 | 规范播放器状态、服务层与队列切换逻辑，播放器只消费统一实体 | Planned |
| Phase 6 | 本地媒体与离线 | 打通本地扫描、本地资源管理与离线能力 | Planned |
| Phase 7 | 目录迁移与清理 | 按目标结构完成目录收口和遗留清理 | Planned |

## 4. 总任务清单

### A. 继续收口现有代码到统一入口

- 搜索链路继续收口，逐步摆脱页面对网易云搜索 Bean 的直接依赖
- 播放链路继续收口，清理 `AudioServiceHandler` 中残留的平台直连逻辑
- 统一歌词缓存策略，减少 `PlayerController` 中直接处理缓存 key 的逻辑
- 登录、首页壳层、搜索面板继续移除页面级业务流程
- 清理只做转发的 controller 方法与空壳类
- 继续减少页面中手工拼装 `MediaItem`

### B. 落实本地优先数据层

- 引入正式结构化本地数据库，目标选型为 `Drift`
- 建立 `core/database` 初始化入口、schema version 与迁移策略
- 明确 `Hive` 与本地媒体库的职责边界
- 建立正式 `LocalLibraryDataSource`
- 将过渡实现逐步替换为正式数据库实现
- 让 `LibraryRepository` 统一承接“先本地、后远程、再回写”

### C. 建立本地媒体库模型

- `Track`
- `TrackLyrics`
- `AlbumEntity`
- `ArtistEntity`
- `PlaylistEntity`
- `PlaylistTrackRef`
- `PlaybackQueue`
- `DownloadTask`
- `SourceAccount`
- 播放历史、最近播放、下载记录等本地模型

### D. 网易云远程层与本地媒体能力

- 继续规范 `NeteaseMusicSource`
- 新增并完善 `LocalMusicSource`
- 将网易云 API 从 `common` 迁入明确的数据目录
- 明确 repository 直接依赖网易云与本地能力，不再通过额外分发层中转

### E. 离线与下载能力

- 建立下载任务模型与状态流转
- 缓存音频、歌词、封面资源
- 建立下载目录与文件生命周期策略
- 建立统一资源索引，至少覆盖音频、歌词、封面三类资源
- 明确封面文件的获取、缓存、离线展示与本地索引策略
- 明确播放优先级：本地文件 > 离线缓存 > 远程地址
- 建立离线模式下的展示与播放降级策略

### F. 播放架构专项

- 提取 `PlaybackService` 或等效服务层
- 统一播放队列模型
- 梳理普通歌单、漫游、心动、喜欢歌曲、本地播放等模式
- 规范播放恢复：队列、进度、模式、当前项
- 让 `MediaItem` 逐步退回到最终播放适配层

### G. 工程结构收口

- 逐步弱化旧 `controllers` 与 `pages` 的双轨结构
- 原 `lib/controllers` 已清空并进入移除阶段，主控制器已迁往 `features/*/controller`
- 推进到 `app / core / data / domain / features / pages / widget / common` 目标结构
- 收口 DI 与初始化入口
- 清理 `common` 中残留的业务逻辑与共享 UI 组件

### H. 质量与文档

- 持续执行注释规范
- 每轮重构更新进度文档
- 每轮重构更新技术架构文档中的边界变化
- 每轮改动执行最小范围静态检查

## 5. 执行优先级

当前建议执行顺序：

1. 搜索链路剩余几栏继续接入统一入口
2. 播放链路残余直连逻辑继续清理
3. 引入 `Drift` 与正式本地库实现
4. 落地 `LocalMusicSource`
5. 建立下载与离线体系
6. 推进更彻底的目录迁移与服务层拆分

## 6. 剩余待重构项

### 6.1 播放架构

- 优先级：最高
- 风险：高

剩余内容：

- 收口播放会话状态：当前歌单名、当前模式、是否喜欢歌单播放、当前队列索引
- 收口恢复状态：队列、当前项、进度、模式
- 继续移除 `AudioServiceHandler` 对其他 feature controller 的直接读取
- 让 `PlaybackService` 成为唯一的播放编排入口
- 明确哪些状态属于 controller、service、handler 和 state store

### 6.2 本地数据层

- 优先级：高
- 风险：高

剩余内容：

- 正式引入 `Drift`
- 设计正式 schema
- 将过渡本地媒体库切换到正式数据库实现
- 明确迁移策略
- 让资源索引、播放历史、下载记录和媒体实体都有稳定本地落点

### 6.3 下载与离线

- 优先级：高
- 风险：中高

剩余内容：

- 建立下载执行器
- 建立下载并发、失败重试、取消和任务恢复
- 提供下载列表与管理入口
- 明确下载文件清理策略
- 打通离线模式、资源索引和播放可用性

### 6.4 本地音乐源与离线能力

- 优先级：中高
- 风险：中

剩余内容：

- 完成本地扫描
- 完成本地文件元数据提取
- 让 `LocalMusicSource` 真正进入搜索、展示和播放主链路
- 让网易云远程层与本地层的职责边界稳定下来

### 6.5 用户资料、播客与云盘的本地优先

- 优先级：中
- 风险：中

剩余内容：

- 用户资料页本地快照
- 播客订阅列表本地快照
- 播客节目列表本地快照
- 云盘元数据本地快照
- 明确各自独立的本地 store 和账号隔离规则

### 6.6 工程结构继续收口

- 优先级：中低
- 风险：低

剩余内容：

- 继续缩小 `common`
- 继续理顺 `pages` 与 `features` 的边界
- 继续整理 `widget` 中的历史组件和预留组件

### 6.7 测试与验证

- 优先级：中
- 风险：中

剩余内容：

- 为播放链路建立最小回归清单
- 为 repository 和 mapper 增补单测
- 为本地库读写和下载恢复补充验证路径

## 7. 长期固定项

### 7.1 关键决策

- 本地数据库目标选型：`Drift`
- 搜索策略：本地优先，远程补充并回写
- 本地音乐源是下一阶段核心目标之一
- 离线下载属于核心能力
- 允许一段时间内 `Hive + Drift + 旧页面/新入口` 并存

### 7.2 已确认的设计偏好

- 切换账号时，播放历史、搜索历史、下载内容都不跟账号走
- 缓存与下载明确区分，下载内容需要在 UI 上明确表现
- 离线能力采用手动开关，而不是只做自动降级
- 搜索结果采用单一结果流，本地优先命中，远程再补充刷新
- 本地音乐源是重要能力，但产品入口暂不与在线内容并列为双主入口
- 下载内容在正常内容流中可见，不只在独立下载页出现
- 用户资料页采用本地快照优先，页面先显示本地数据，再后台刷新
- 播客列表与节目列表先缓存元数据和节目基础信息，不先缓存完整播放资源
- 云盘数据先按账号保存本地快照，不作为强本地事实源
- 评论不进入正式本地库，只保留页面级状态和必要刷新

## 8. 状态定义

- `Planned`
  - 尚未形成稳定代码落点
- `In Progress`
  - 已有实际代码落地，但尚未达到阶段验收标准
- `Done`
  - 已达到阶段验收标准，并完成文档同步

## 9. 当前状态

### 已完成

- 架构分析完成
- 技术架构文档已建立
- 重构阶段计划已建立
- 通用请求组件已通过 `RequestRepository` 统一网络访问入口
- 旧 `RequestWidget` / `RequestLoadMoreWidget` 已删除，请求执行权已回收到 feature controller 与 repository
- 播放主链路已开始收口到 `PlayerController`，底部面板、歌单页、专辑页、歌手页、每日推荐、榜单和个人页快捷入口已不再通过页面直接驱动 `audioHandler` 或 `AppController` 播放代理
- `PlaybackService` 已接管底层播放器实例生命周期，`PlayerController` 不再直接初始化 `AudioServiceHandler`
- 漫游模式续队列、喜欢歌曲播放和模式初始化已开始从 `PlayerController` 下沉到 `PlaybackService`
- `AudioServiceHandler` 对 `PlayerController` 的直接反向依赖已移除，上层播放状态通过 `PlaybackService` 显式同步
- `AudioServiceHandler` 对 `SettingsController` 和 `UserController` 的直接读取已移除，底层所需偏好和交互入口统一通过 `PlaybackService` 注入
- 播放模式、重复模式、当前歌单名等会话展示态已开始收口为 `PlaybackSessionState`，为后续恢复状态收口做准备
- 播放恢复信息已开始收口为 `PlaybackRestoreState`，并补上当前播放进度的持久化与恢复入口
- 当前队列、当前歌曲、当前索引和当前进度已开始收口为 `PlaybackRuntimeState`，为后续减少运行态散落字段做准备
- 歌词行、当前歌词索引和翻译歌词标记已开始收口为 `PlaybackLyricState`，歌词页与壳层滚动同步开始脱离旧散落字段
- 播放恢复轻存储已回收到 `PlaybackRestoreDataSource`，歌词内容开始改由媒体库持久化
- 播放恢复态的读写主入口已切到 `PlaybackRepository`，控制器和底层 handler 不再直接依赖轻存储
- 播放恢复态已从 `LocalLibraryDataSource` 拆出，改由独立的 `PlaybackRestoreDataSource` 承接
- 播放恢复态已开始同时写入轻存储快照和恢复态数据源，为后续正式本地数据库接管做准备
- 持久化层已新增恢复态记录模型与 codec，为正式数据库 schema 对接提前固定映射格式
- 数据库层已补统一 schema 清单，并为资源索引、下载任务建立记录模型与 codec
- 资源索引与下载任务已开始通过独立数据库数据源接口接入 `AppDatabase`，为后续正式数据库实现缩小替换面
- 播放恢复态在轻存储中已统一为单快照格式
- 壳层与主播放面板已开始改用统一播放状态对象，旧散落字段暂时仅保留为兼容层
- 底部播放面板的队列列表、头部信息、当前歌曲封面和进度读取已优先改用 `PlaybackRuntimeState`，主播放界面对旧运行态字段的依赖继续缩小
- `PlayerController` 内部编排已优先读取统一播放状态对象，旧 `curPlaying* / curPlay* / lyrics*` 字段开始退为兼容镜像
- `AppController` 中旧运行态与歌词态兼容 getter 已移除，壳层统一开始通过播放状态对象读取当前播放信息
- `PlayerController` 中旧 `curPlaying* / curPlay* / lyrics*` 兼容字段已移除，控制器与页面层统一以播放状态对象作为当前播放信息的事实源
- 页面层对 `curPlayListName / curPlayListNameHeader / isPlayingLikedSongs` 的依赖已切到 `PlaybackSessionState`，会话态兼容字段开始退出壳层和控制器
- 设置页已移除对 `Hive Box` 的直接写入
- 评论组件已通过 `CommentRepository` 收口评论请求与交互
- 用户资料页已通过 `UserRepository` 收口请求拼装，退出登录状态写入已回收到设置控制器
- 云盘页已移除仅作中转的 `CloudController`
- 删除未使用的歌单专用请求组件
- 删除未承载职责的 `PlayListController` 和 `AlbumController`
- 探索页榜单歌曲改为直接通过 `PlaylistRepository` 获取
- `AppController` 已移除歌单查询、歌曲映射、喜欢状态等单点代理
- 漫游 / 心动模式与喜欢歌单播放逻辑已下沉到 `PlayerController`
- 已建立第一版领域层骨架：`Track`、`PlaylistEntity`、`AlbumEntity`、`ArtistEntity`、`PlaybackQueue`
- 已新增第一版 `NeteaseMusicSource`
- 已建立 `NeteaseMusicSource`、`LocalMusicSource` 与 `LibraryRepository` 骨架
- 播放歌词和在线播放地址已改由 `PlaybackRepository -> LibraryRepository -> NeteaseMusicSource / LocalMusicSource` 获取
- `feature repository -> 网易云 API` 直连已全部下沉到 `data/netease/**`，`features/**` 不再直接 import `NeteaseMusicApi`
- 专辑页、歌手页和部分用户歌曲链路已改为通过统一实体构建 `MediaItem`
- 歌单页路由参数已改为 `playlistId / playlistName / coverUrl / trackCount`，页面不再直接依赖网易云 `PlayList` bean
- 用户资料页与 `UserProfileController` 已改为消费 feature 自己的用户资料模型，不再直接依赖 `NeteaseUserDetail`
- 用户会话、推荐歌单、用户歌单和探索页歌单分类已改为消费 feature 自己的数据模型，壳层与页面已不再直接依赖 `NeteaseAccountInfoWrap / PlayList / PlaylistCatalogueItem`
- 播客列表、播客详情和对应 controller 已改为消费 `RadioSummaryData / RadioProgramData`，不再直接依赖 `DjRadio / DjProgram`
- 评论列表、楼中楼和评论弹层已改为消费 `CommentData`，不再直接依赖网易云评论 bean
- 云盘页与 `CloudPageController` 已改为直接消费 `MediaItem` 列表，不再直接依赖 `CloudSongItem`
- 底部播放面板的歌手跳转已改为消费应用侧作者字段，不再通过 `Artist.fromJson` 反解网易云作者 bean
- 认证轮询、评论发送/点赞、歌单订阅、喜欢歌曲和退出登录已改为返回应用侧结果对象，不再把网易云 `ServerStatusBean / CommentWrap / QrCodeLoginKey` 暴露给控制器和页面
- 云盘、FM 和播客节目列表的 `MediaItem` 拼装已归位到专用 mapper，feature repository 不再手写平台字段
- 已新增本地媒体库数据源协议，`LibraryRepository` 开始按“先本地、后远程、再回写”组织读取路径
- 已新增进程内本地媒体库占位实现，并进一步切到可持久化过渡实现
- 搜索面板中的单曲、歌单、专辑、歌手结果已接入统一媒体库入口
- 搜索仓库已开始按“本地优先、远程补齐并去重”返回统一结果
- 已新增 `LocalMusicSource` 骨架
- 已新增 `AppDatabase` 抽象与待接入实现，固定本地数据库启动入口
- 应用启动已统一注册 `LocalLibraryDataSource` 与 `LibraryRepository`
- 已新增 `LibraryPreferenceStore`，手动离线模式已接入设置页和媒体库读取策略
- 搜索面板在离线模式下已停止请求在线热搜
- 已新增 `AuthStateStore` 与 `PlaylistCacheStore`
- 播放地址解析已开始优先命中本地 `localPath`
- 歌单详情链路已开始把歌单元数据和歌曲明细同步写回本地媒体库
- 用户数据链路已开始把推荐歌单、用户歌单、日推、FM、心动模式和按 ID 拉取的歌曲明细写回本地媒体库
- 专辑和歌手详情链路已开始把专辑、歌手及其歌曲明细同步写回本地媒体库
- `LibraryRepository` 已补齐本地文件路径、下载状态和可用性写回入口，并新增 `LocalMediaRepository` 作为本地扫描导入骨架
- `Track -> MediaItem -> AudioServiceHandler` 已开始透传本地文件状态，本地导入和已缓存歌曲可以按本地文件路径优先播放
- 已新增 `DownloadRepository`，开始将排队、下载中、下载完成、下载失败等状态统一写回 `Track`
- 已新增 `LocalMediaScanRepository`，开始提供本地目录扫描、音频文件过滤和批量导入入口
- `Track -> MediaItem` 已开始优先透传本地封面路径和本地歌词路径，播放器可直接优先使用本地歌词文件
- 本地封面路径和本地歌词路径已从临时 metadata 收口为 `Track` 正式字段，下载和展示链路开始共享同一套资源字段
- 下载进度、失败原因和资源来源已开始从临时 metadata 收口为 `Track` 正式字段，下载链路和本地导入链路开始共享同一套状态模型
- 已新增 `DownloadTask` 过渡模型，下载过程态开始从 `Track` 最终状态中拆开存放
- `DownloadRepository` 已补齐下载任务查询与清理入口，为后续下载列表和任务恢复预留统一入口
- `DownloadRepository` 已补实际下载执行入口，开始负责音频、封面、歌词文件落盘与本地资源状态回写
- 当前播放歌曲的下载入口已接到 `PlayerController`，下载完成后会同步刷新当前播放 `MediaItem`
- 本地扫描已补同目录歌词与封面识别，导入后会同步写入本地资源索引
- 已新增独立本地资源索引入口，下载链路和本地导入链路开始统一记录音频、封面、歌词资源路径
- `LibraryRepository` 已开始汇总轨道实体和资源索引，搜索与播放链路会优先读取补全后的本地资源视图
- 应用入口层已开始从 `lib/` 根目录收口到 `lib/app/bootstrap` 和 `lib/app/routing`
- 播放底层已开始从 `lib/common` 收口到 `lib/core/playback`
- 遗留主控制器已开始迁移到 `lib/features/*/controller`，导入链路已切到新目录
- 轻量 feature 已开始从 `repository/` 子目录收口为模块根目录文件
- `common/common_widget.dart` 已删除，共享 UI 组件已开始迁入 `lib/widget` 或对应 feature
- 顶部搜索面板、用户资料页、云盘、播客列表、播客节目页、评论页已切到状态驱动数据流
- `SearchRepository`、`UserRepository`、`CloudRepository`、`RadioRepository`、`CommentRepository` 不再向 UI 暴露 `build*Request()` 入口

### 进行中

- Phase 1
- Phase 2
- Phase 3

### 未开始

- Phase 4 到 Phase 7

## 10. 分阶段计划

### Phase 1: 基础边界收口

目标：

- 停止页面继续直接承载业务流程
- 停止控制器继续直接承担所有数据访问
- 建立统一的 repository 和 mapper 落点

范围：

- [`lib/features/user/user_controller.dart`](../lib/features/user/user_controller.dart)
- [`lib/pages/playlist_page_view.dart`](../lib/pages/playlist_page_view.dart)
- [`lib/pages/cloud_drive_view.dart`](../lib/pages/cloud_drive_view.dart)
- [`lib/pages/login_page_view.dart`](../lib/pages/login_page_view.dart)
- [`lib/features/playback/player_controller.dart`](../lib/features/playback/player_controller.dart)

任务：

- 新建 repository 基础目录
- 新建统一的 `MediaItem` mapper
- 新增基础数据访问封装，禁止新增页面直调 `NeteaseMusicApi`
- 新增基础存储访问封装，禁止新增页面直连 `Hive`
- 将新改动中的模型转换统一收口
- 将通用请求组件中的直接网络访问收口到基础请求层

验收标准：

- 新增代码中，页面层不再直接访问 `NeteaseMusicApi`
- 新增代码中，页面层不再直接访问 `Hive Box`
- 至少一个业务链路完成 repository 化
- 至少一个 `MediaItem` 转换入口完成统一
- 通用请求组件不再直接依赖底层网络代理

风险：

- 旧代码与新结构会并存一段时间

### Phase 2: Shell 拆分

目标：

- 将壳层 UI 状态与业务入口解耦
- 缩小 `AppController` 的职责范围

范围：

- [`lib/features/shell/app_controller.dart`](../lib/features/shell/app_controller.dart)
- [`lib/pages/home/app_home_page_view.dart`](../lib/pages/home/app_home_page_view.dart)
- [`lib/pages/home/body/app_body_page_view.dart`](../lib/pages/home/body/app_body_page_view.dart)
- [`lib/pages/home/top_panel_view.dart`](../lib/pages/home/top_panel_view.dart)

任务：

- 拆出 Shell Controller
- 保留壳层状态在 Shell 范围内
- 将播放入口、歌单拉取入口、模式切换入口从 `AppController` 中迁出
- 明确壳层只负责 drawer、panel、home page、返回键和搜索壳层状态

验收标准：

- `AppController` 不再负责歌单拉取
- `AppController` 不再直接承载播放模式切换入口
- 首页壳层状态可由独立 controller 管理

风险：

- 首页联动复杂，拆分过程容易产生 UI 回归

进度：

- 已新增 `HomeShellController`
- `AppController` 先通过代理 getter 复用新壳层 controller，避免一次性改动页面依赖

### Phase 3: 统一领域模型

目标：

- 建立独立于网易云 API Bean 的统一领域实体
- 为网易云远程层、本地媒体能力与离线能力准备稳定的数据模型边界

范围：

- `Track`
- `PlaylistEntity`
- `AlbumEntity`
- `ArtistEntity`
- `PlaybackQueue`

任务：

- 定义统一领域实体
- 明确 `MediaItem` 只用于播放适配层
- 为远程源、本地扫描结果建立到统一实体的映射规则
- 停止新增页面和 controller 直接依赖网易云模型驱动核心业务

验收标准：

- 新增业务逻辑优先依赖统一实体而不是网易云 Bean
- 统一实体足以表达本地文件、远程歌曲、已下载内容
- 播放队列构建逻辑不再绑定单一远程源模型

风险：

- 统一实体设计过早固化会放大后续迁移成本

进度：

- 已新增统一实体目录 `lib/domain/entities`
- 已新增 `TrackLyrics`
- 已新增第一版网易云到 `Track` 的映射器
- 已新增 `lib/data/netease/netease_music_source.dart`
- `LibraryRepository` 已直接依赖网易云与本地 source，不再通过额外分发层中转
- 已新增 `LocalLibraryDataSource` 协议
- 已新增 `lib/data/local/local_music_source.dart`
- 已新增 `lib/features/playback/playback_state_store.dart`
- 已新增 `lib/core/database/app_database.dart` 与 `lib/core/database/pending_app_database.dart`

### Phase 4: 本地优先数据层

目标：

- 建立结构化本地数据库
- 让 UI 和大部分业务默认从本地媒体库读取数据

任务：

- 引入结构化本地数据库
- 建立本地媒体库接口
- 让远程同步写入本地库，而不是直接返回给页面
- 为下载状态、离线文件、本地扫描结果预留模型与关系
- 明确数据所有权
- 定义同步策略
- 定义统一 ID 规范
- 落地离线模式开关及对应的本地优先读取规则

验收标准：

- 列表页和详情页可以优先展示本地数据
- 远程请求结果能稳定写回本地库
- 本地媒体库可以承载歌曲、歌单、历史、离线状态等核心信息
- 正式 `LocalLibraryDataSource` 已接管当前本地媒体库读取入口

风险：

- 本地数据库接入会影响缓存策略和模型定义

### Phase 5: 播放链路重构

目标：

- 固定播放业务层的职责边界
- 将播放器彻底切换到统一实体和本地优先数据流

任务：

- 建立 `PlaybackService` 或等效服务层
- 让播放器优先消费本地文件或统一播放地址
- 将歌词、模式切换、队列切换进一步整理
- 让播放队列脱离网易云模型和临时 `MediaItem` 拼装逻辑
- 固定播放优先级：本地文件 > 离线缓存 > 远程地址
- 统一播放恢复逻辑：队列、当前项、进度、模式

验收标准：

- 播放器不再直接依赖单一远程源模型
- `PlayerController` 主要负责状态暴露与视图交互
- 播放模式与队列构建有明确服务层承接
- 播放核心链路不再直接依赖 `NeteaseMusicApi`

风险：

- 播放链路属于核心功能，任何拆分都要小步验证

进度：

- `PlayerController` 已通过统一仓库链路读取歌词
- `AudioServiceHandler` 已通过统一仓库链路解析在线播放地址

### Phase 6: 本地媒体与离线

目标：

- 固定网易云远程层与本地媒体能力的边界
- 支持本地文件、离线资源与网易云内容共同服务于同一播放器

任务：

- 继续固定 `NeteaseMusicSource` 与 `LocalMusicSource` 的职责边界
- 将网易云 API 归位到 `lib/data/netease`
- 新增本地媒体源
- 明确下载、离线缓存、无网络回退策略
- 建立下载任务与资源生命周期规则
- 区分缓存资源和明确下载保存的管理策略
- 让下载内容在正常内容流中保持可见并带状态标记

验收标准：

- 播放器可以统一消费网易云内容、本地文件与离线资源
- 本地扫描结果可进入统一媒体库
- 已缓存或本地文件在无网络时仍可播放
- `LocalMusicSource` 可完成本地扫描、入库、搜索与播放地址提供

风险：

- 网易云远程层和本地媒体能力的边界如果继续混杂，会重新把平台细节带回页面与 feature
- 离线状态和版权状态的表达需要提前设计

### Phase 7: 目录迁移与清理

目标：

- 按目标工程架构完成目录收口
- 清理遗留的职责交叉和重复逻辑

范围：

- `lib/common`
- 原 `lib/controllers`
- `lib/pages`
- `lib/widget`
- `lib/routes`

任务：

- 按 feature 和 data/domain/core 逐步迁移代码
- 清理遗留的过渡适配层
- 收敛通用组件与业务组件的边界
- 更新文档中的最终落点状态

验收标准：

- 主干目录基本符合目标结构
- 遗留总控逻辑明显减少
- 常见业务链路都已完成本地优先化
- 网易云平台接入不再侵入页面层

风险：

- 目录迁移过程中链接和导入较多

## 11. 高风险区

以下区域后续每次改动都需要小步验证：

- 播放链路：涉及播放恢复、模式切换、后台播放和队列持久化
- 本地数据库迁移：涉及 `Hive` 过渡、正式本地库接管和历史数据兼容
- 统一 ID 与缓存兼容：涉及历史纯数字网易云 ID 与新领域 ID 并存

## 12. 执行规则

- 任何新功能优先按目标结构落地
- 任何数据流设计优先考虑本地优先与离线可用
- 任何阶段开始前，先在本文档中标记为 `In Progress`
- 阶段结束后，更新为 `Done`
- 如果中途调整策略，必须同时更新技术架构文档和本计划文档

## 13. 文档更新边界

- 架构边界、目录职责、核心模型、资源规则、技术决策变化：更新 `technical-architecture.md`
- 阶段状态、完成项、风险、阻塞、下一步变化：更新 `refactor-plan.md`
- 新核心能力落地且同时影响架构边界与阶段进度时：两份文档都更新

## 14. 进度记录模板

#### YYYY-MM-DD

- 阶段：`Phase X`
- 状态：`In Progress` / `Done`
- 完成内容：
- 风险或阻塞：
- 下一步：

## 15. 更新记录

#### 2026-04-18

- 阶段：`Phase 0`
- 状态：`Done`
- 完成内容：固定技术架构、目标工程结构、分阶段重构计划，并建立正式文档
- 风险或阻塞：后续需要严格按文档执行，避免边改边漂移
- 下一步：启动 `Phase 1`，先建立 repository 和 mapper 的落点

#### 2026-04-18

- 阶段：`Phase 1`
- 状态：`In Progress`
- 完成内容：新增 cloud repository、统一 MediaItem mapper，并将云盘页面中的 MediaItem 拼装逻辑迁移到 controller/repository 方向；新增 playlist repository，将歌单详情页中的缓存和歌曲拉取逻辑迁移出页面，并开始承接 AppController 中的歌单获取逻辑；新增 auth repository 和 auth controller，将登录页中的二维码轮询、登录态落库和用户信息拉取迁移出页面；新增 album repository，将专辑详情页中的直接 API 调用迁移出页面；新增 artist repository，将歌手详情页中的详情、热门歌曲和专辑拉取迁移出页面；新增 explore repository，将探索页 controller 中的歌单目录和分类歌单请求迁移到 repository；新增 user repository，将 UserController 中的推荐歌单、用户歌单、日推、FM、心动模式、歌曲详情和退出登录迁移到 repository；新增 playback repository，将歌词请求迁移出 PlayerController；新增 search repository，将搜索面板中的请求定义迁移出 UI 文件；新增 radio repository，将电台页中的请求定义与节目映射迁移出页面
- 风险或阻塞：当前请求组件仍承担较多请求与分页职责，后续仍需继续收缩
- 下一步：继续抽离歌单、登录或搜索链路中的页面直调业务逻辑

#### 2026-04-19

- 阶段：`Phase 3`
- 状态：`In Progress`
- 完成内容：将 `AppDatabase` 与共享本地媒体库数据源正式串入应用启动依赖，统一注册 `LocalLibraryDataSource` 与 `LibraryRepository`；补充 `LibraryPreferenceStore` 并将手动离线模式接入设置页和媒体库读取策略；搜索面板在离线模式下改为展示本地搜索提示，不再主动请求在线热搜；新增 `AuthStateStore` 与 `PlaylistCacheStore`，继续把登录态和歌单缓存访问从 repository 业务逻辑中收回到独立存储入口；搜索仓库开始按“本地优先、远程补齐并去重”返回统一结果；新增持久化过渡版 `LocalLibraryDataSource`，开始替换共享内存实现并让本地媒体库具备跨重启保留能力；播放地址解析开始优先命中本地 `localPath`；歌单详情链路开始把歌单元数据和歌曲明细同步写回本地媒体库
- 完成内容：将 `AppDatabase` 与共享本地媒体库数据源正式串入应用启动依赖，统一注册 `LocalLibraryDataSource` 与 `LibraryRepository`；补充 `LibraryPreferenceStore` 并将手动离线模式接入设置页和媒体库读取策略；搜索面板在离线模式下改为展示本地搜索提示，不再主动请求在线热搜；新增 `AuthStateStore` 与 `PlaylistCacheStore`，继续把登录态和歌单缓存访问从 repository 业务逻辑中收回到独立存储入口；搜索仓库开始按“本地优先、远程补齐并去重”返回统一结果；新增持久化过渡版 `LocalLibraryDataSource`，开始替换共享内存实现并让本地媒体库具备跨重启保留能力；播放地址解析开始优先命中本地 `localPath`；歌单详情链路开始把歌单元数据和歌曲明细同步写回本地媒体库；用户数据链路开始把推荐歌单、用户歌单、日推、FM、心动模式和按 ID 拉取的歌曲明细写回本地媒体库；专辑和歌手详情链路开始把专辑、歌手及其歌曲明细同步写回本地媒体库；`LibraryRepository` 已补齐本地文件路径、下载状态和可用性写回入口，并新增 `LocalMediaRepository` 作为本地扫描导入骨架；`Track -> MediaItem -> AudioServiceHandler` 已开始透传本地文件状态，使本地导入和已缓存歌曲能够优先按本地文件路径播放；已新增 `DownloadRepository`，开始将排队、下载中、下载完成、下载失败等状态统一写回 `Track`；已新增 `LocalMediaScanRepository`，开始提供本地目录扫描、音频文件过滤和批量导入入口；`Track -> MediaItem` 已开始优先透传本地封面路径和本地歌词路径，播放器可直接优先使用本地歌词文件；本地封面路径和本地歌词路径已从临时 metadata 收口为 `Track` 正式字段，下载和展示链路开始共享同一套资源字段
- 风险或阻塞：当前持久化实现仍复用 `Hive Box` 作为过渡存储，正式数据库还未完全接管；下载与同步链路仍未完全纳入离线模式约束
- 下一步：继续把下载/播放可用性状态写回本地媒体库，并为 `Drift` 接入预留更稳定的数据迁移入口

#### 2026-04-19

- 阶段：`Phase 3`
- 状态：`In Progress`
- 完成内容：继续将资源状态从临时 metadata 收口为 `Track` 正式字段，新增 `resourceOrigin`、`downloadProgress`、`downloadFailureReason`，并将 `DownloadRepository`、`LocalMediaRepository`、`LibraryRepository`、`MediaItem` 映射和本地媒体库存储统一切到正式字段
- 风险或阻塞：资源状态虽然开始稳定化，但独立下载任务模型和资源索引模型仍未建立
- 下一步：继续收口下载与离线资源状态，减少对自由 metadata 的依赖，并为统一资源索引做准备

#### 2026-04-19

- 阶段：`Phase 3`
- 状态：`In Progress`
- 完成内容：新增 `DownloadTask` 过渡模型，开始把下载排队、下载中、下载完成、下载失败等过程态独立持久化；`DownloadRepository` 现在会同时写入下载任务记录和 `Track` 最终资源状态，为后续接真实下载器和任务列表打基础
- 风险或阻塞：当前下载任务仍是过渡存储实现，调度器、并发控制和任务恢复逻辑还未建立
- 下一步：继续补齐下载任务查询入口和资源索引落点，为后续下载列表与断点恢复做准备

#### 2026-04-19

- 阶段：`Phase 3`
- 状态：`In Progress`
- 完成内容：继续补齐 `DownloadRepository` 的任务查询、活动任务聚合和清理入口，后续下载列表、失败重试和恢复逻辑可以先通过统一仓库访问过渡任务存储
- 风险或阻塞：当前任务列表仍缺少真正的下载执行器驱动，展示层暂时还没有消费这些入口
- 下一步：继续把资源索引和下载任务查询入口接入更上层的业务链路

#### 2026-04-19

- 阶段：`Phase 3`
- 状态：`In Progress`
- 完成内容：新增 `LocalResourceEntry` 与 `LocalResourceIndexRepository`，开始为音频、封面、歌词三类本地资源建立独立索引；`DownloadRepository` 与 `LocalMediaRepository` 已接入资源索引写入，下载完成和本地导入会同步登记资源路径
- 风险或阻塞：当前资源索引仍是过渡存储实现，播放链路和展示链路尚未直接消费资源索引查询入口
- 下一步：继续让更上层链路消费资源索引，并逐步减少对单一 `Track` 字段的直接依赖

#### 2026-04-19

- 阶段：`Phase 3`
- 状态：`In Progress`
- 完成内容：`LibraryRepository` 已开始汇总本地轨道实体与资源索引，`getTrack`、本地搜索结果和播放地址解析会优先读取补全后的本地资源视图，为后续上层链路逐步摆脱对单一 `Track` 字段写入顺序的依赖做准备
- 风险或阻塞：当前远程搜索结果仍主要依赖轨道实体本身，资源索引的消费范围还在继续扩展
- 下一步：继续把更多展示和播放链路接到资源索引补全后的统一读取路径

#### 2026-04-19

- 阶段：`Phase 7`
- 状态：`In Progress`
- 完成内容：应用入口层已开始整理到 `lib/app`，新增 `app/bootstrap` 和 `app/routing`，将原本散落在 `main.dart`、`lib/` 根目录下的初始化与路由入口收口到应用级目录
- 风险或阻塞：当前只是入口层先收口，`pages / controllers / common / widget` 仍是更大的遗留整理范围
- 下一步：继续按“应用入口 -> 业务入口 -> 遗留页面/控制器”顺序做低风险目录收口

#### 2026-04-19

- 阶段：`Phase 7`
- 状态：`In Progress`
- 完成内容：播放底层文件已开始从 `lib/common` 收口到 `lib/core/playback`，`AudioServiceHandler` 和播放列表序列化辅助能力已归入播放基础设施目录，未使用的旧抽象接口已清理
- 风险或阻塞：虽然主控制器已迁到 `features/*/controller`，但页面层仍大量依赖旧壳层接口，后续目录收口还会牵动较多导入和兼容代码
- 下一步：继续按“控制器先归位、页面再跟进”的顺序整理遗留目录

#### 2026-04-19

- 阶段：`Phase 7`
- 状态：`In Progress`
- 完成内容：`AppController`、`PlayerController`、`UserController`、`SettingsController` 与 `ExplorePageController` 已迁入 `lib/features/*/controller`；应用入口、播放底层和迁移中的控制器已补充职责边界与兼容原因注释；旧页面和功能入口对控制器的导入已统一切到新目录
- 风险或阻塞：页面层仍通过 `AppController` 复用较多迁移期代理入口，后续继续拆壳层和播放入口时仍会触及较大范围调用点
- 下一步：继续缩减页面层对迁移期代理入口的依赖，并清理仍以旧控制器目录为中心的历史描述和兼容逻辑

#### 2026-04-20

- 阶段：`Phase 1`
- 状态：`In Progress`
- 完成内容：探索页榜单已从字符串下标字典收口为 `RankingPlaylistData`；评论列表响应解析已下沉到 `data/netease/mappers`，feature repository 不再直接解析评论 bean；云盘仓库已移除最后一个 `CloudSongItem` 显式类型；当前 `pages / features / core` 层已不再直接依赖网易云原始 bean，原始模型仅保留在 `data/netease/**`
- 风险或阻塞：feature repository 仍直接依赖网易云远程 API 调用入口，后续还要继续判断哪些调用应进一步下沉到 `data/netease`
- 下一步：继续清理 feature 层剩余的网易云 API 直连，并评估是否把评论、播客、云盘的远程访问进一步下沉到 `data/netease`

#### 2026-04-20

- 阶段：`Phase 1`
- 状态：`In Progress`
- 完成内容：新增 `netease_auth_remote_data_source`、`netease_explore_remote_data_source`、`netease_cloud_remote_data_source`、`netease_radio_remote_data_source`，将 `auth / explore / cloud / radio` 四条链路的网易云远程访问从 feature repository 下沉到 `data/netease`；对应 repository 现在只依赖数据源结果，不再直接 import `NeteaseMusicApi`
- 风险或阻塞：`album / artist / playlist / search / user / comment` 六条链路仍然直接依赖网易云 API，后续还要按同样方式继续下沉
- 下一步：继续清理剩余 feature repository 的网易云 API 直连，优先处理 album、artist、search 这三条较薄的链路

#### 2026-04-20

- 阶段：`Phase 1`
- 状态：`In Progress`
- 完成内容：新增 `netease_album_remote_data_source`、`netease_artist_remote_data_source`、`netease_search_remote_data_source`，将 `album / artist / search` 三条链路的网易云远程访问继续下沉到 `data/netease`；当前剩余直接依赖网易云 API 的 feature repository 已收缩到 `playlist / user / comment`
- 风险或阻塞：`playlist / user / comment` 三条链路更厚，拆分时会同时牵动缓存、操作结果和多段请求编排
- 下一步：继续按同样方式清理 `playlist / user / comment`

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：引入正式数据库主线，并开始将播放恢复态接入结构化本地库；应用启动已切到正式数据库实现，播放恢复态开始使用正式数据库入口
- 风险或阻塞：当前正式数据库只接入了恢复态，媒体库、资源索引、下载任务仍沿用原持久化实现；`build_runner` 仍需同时生成数据库 schema 与保留旧网易云 `bean.g.dart`
- 下一步：继续把资源索引和下载任务接到正式数据库实现，并清理剩余 feature repository 的网易云 API 直连

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：资源索引已通过 `trackId + kind` 唯一键接入正式数据库；正式数据库现在同时承接播放恢复态和本地资源索引两类实现
- 风险或阻塞：下载任务和媒体库本体仍沿用原持久化实现，正式数据库当前还没有接管下载任务和媒体库记录
- 下一步：继续把下载任务接到正式数据库实现，再评估媒体库本体的正式数据库落点

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：下载任务已按 `trackId` 唯一键接入正式数据库；正式数据库现在同时承接播放恢复态、本地资源索引和下载任务三类实现
- 风险或阻塞：媒体库本体仍沿用过渡持久化实现，正式数据库当前还没有接管 `Track / Playlist / Album / Artist / Lyrics`
- 下一步：开始把媒体库本体切到正式数据库实现，优先评估 `Track` 与歌词的落库方案

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：媒体库中的 `Track / Lyrics` 已接入正式数据库；正式数据库现在直接承接播放恢复态、资源索引、下载任务、轨道和歌词五类实现
- 风险或阻塞：歌单、专辑、歌手仍暂时委托旧持久化实现，媒体库本体当前还是混合实现，需要继续清理委托边界
- 下一步：继续把 `Playlist / Album / Artist` 切到正式数据库实现，并评估搜索是否需要补更明确的本地索引

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：`Playlist / Album / Artist` 已接入正式数据库，`LocalLibraryDataSource` 直接承接 `Track / Lyrics / Playlist / Album / Artist` 全量媒体库读写与搜索；正式数据库不再委托旧媒体库持久化实现
- 风险或阻塞：媒体库虽然已经切到正式数据库实现，但当前搜索仍采用全量读取后内存过滤，后续还需要评估是否补更明确的索引策略
- 下一步：开始回头收下载列表、任务恢复和失败重试，或者继续优化媒体库搜索与写入策略

#### 2026-04-20

- 阶段：`Phase 1`
- 状态：`In Progress`
- 完成内容：新增 `netease_playlist_remote_data_source`、`netease_user_remote_data_source`、`netease_comment_remote_data_source`，将 `playlist / user / comment` 三条链路的网易云远程访问继续下沉到 `data/netease`；当前 `lib/features/**` 已不再直接 import `NeteaseMusicApi` 或 `netease_api.dart`
- 风险或阻塞：虽然 feature 层已经切断对网易云 API 的直连，但 `data/netease` 内部仍保留一批原始 bean 和平台协议实现，后续还需要继续围绕数据库落地和本地优先策略做分层整理
- 下一步：继续把正式数据库扩到资源索引和下载任务，并逐步让更多 feature 走本地优先读取与回写

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：正式数据库最终选型已切换为 `Drift`；应用启动已切到 `DriftAppDatabase`；`PlaybackRestoreDataSource`、`LocalResourceIndexDataSource`、`DownloadTaskDataSource` 与 `LocalLibraryDataSource` 已全部改由 Drift 实现承接；旧数据库实体、数据源和依赖已移除，数据库主线现在固定为 `AppDatabase -> Drift DataSource -> Repository`
- 风险或阻塞：媒体库搜索当前仍主要依赖 `payloadJson` 落库与查询字段辅助，后续还需要继续补索引与更精确的查询策略；`build_runner` 仍会误删网易云 `bean.g.dart`，生成步骤需要继续显式恢复这些文件
- 下一步：优先优化媒体库搜索与查询策略，并把下载列表、任务恢复和失败重试接到已经稳定的 Drift 下载任务数据源

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：移除了 repository 和 source 内部悄悄退回 `in_memory_*` 的分支，正式数据库现在是唯一主线；应用启动已开始在首帧前清理中断下载任务，把遗留的 `queued / downloading` 状态统一收敛为失败态，并补充了显式重试入口
- 风险或阻塞：当前下载任务恢复策略仍是“失败后手动重试”，还没有真正的断点续传或自动续传能力
- 下一步：继续把下载列表和失败重试入口接到页面层，并评估是否要补下载调度和续传策略

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：`Track` 已改为结构化列落库，Drift 媒体库读取和搜索不再依赖 `payloadJson` 反序列化作为主路径；下载列表、刷新、重试、取消和清理动作已接到真实页面入口，设置页、当前播放面板和歌单列表都能直接触发下载管理与当前歌曲下载动作；下载主线开始按统一队列串行调度，避免多个任务并发写入同一路径时出现假状态；歌单、专辑等复用 `SongItem` 的音乐列表也已接到统一下载动作；歌单页和专辑页已补“下载全部”入口；下载任务页已直接监听 Drift 下载表，状态变化不再依赖手动刷新；Drift 已补媒体库搜索和下载查询所需的基础索引；下载任务现在会在入队时立即落 `queued` 状态，批量下载不会再出现“队列里看不到任务”的假状态；启动恢复策略已改成 `queued` 自动重新入队、`downloading` 收敛为中断失败；下载任务已持久化目标文件路径，取消和异常退出后的临时文件可以被统一清理
- 风险或阻塞：下载体系仍不支持断点续传，失败任务当前仍依赖完整重试
- 下一步：继续评估是否需要进一步补自动续传或并发下载策略，并根据真实使用情况细化下载文件清理规则

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：`Playlist / Album / Artist` 已继续改为结构化列落库，媒体库四类主实体现在都不再依赖 `payloadJson` 作为主读写格式；Drift 本地库开始更接近长期可维护的关系型落库方式
- 风险或阻塞：歌单轨道关系虽然已拆表，但当前读取仍按 playlistId 二次组装，后续如果歌单查询继续变复杂，仍需再评估是否补更多索引或 join 路径
- 下一步：继续优化歌单关系查询路径，或者先把下载任务 controller 接到真实页面入口

#### 2026-04-20

- 阶段：`Phase 4`
- 状态：`In Progress`
- 完成内容：歌单与歌曲关系已拆到独立 `playlist_track_refs` 表，`PlaylistEntity.trackRefs` 开始由关系表组装，媒体库主实体与主关系数据都已进入结构化落库
- 风险或阻塞：当前歌单搜索仍会在命中 playlist 后再单独读取一轮关系数据，后续还需要评估是否为高频歌单读取补更明确的聚合路径
- 下一步：继续优化歌单关系读取，或者把下载任务列表真正接到页面层
