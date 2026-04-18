# 重构计划与进度

## 1. 文档目标

本文档用于固定本项目的阶段性重构计划、执行顺序、验收标准和进度更新方式。

后续每次重构完成后，都必须同步更新本文档中的：

- 阶段状态
- 已完成事项
- 进行中事项
- 风险与阻塞

## 2. 重构原则

- 优先解决职责边界问题
- 优先低风险、小步快跑
- 重构期间保证现有功能可运行
- 每阶段结束后都需要形成可验证成果
- 所有长期设计都以“本地优先、多源接入、离线可用”为目标

## 3. 阶段总览

| 阶段 | 名称 | 目标 | 状态 |
| --- | --- | --- | --- |
| Phase 0 | 文档定案 | 固定技术架构、工程结构和执行计划 | Done |
| Phase 1 | 基础边界收口 | 停止新债继续扩散，建立 repository 和 mapper 落点 | In Progress |
| Phase 2 | Shell 拆分 | 将 `AppController` 中的壳层状态和业务入口拆开 | In Progress |
| Phase 3 | 统一领域模型 | 建立 Track、PlaylistEntity 等统一实体，停止以网易云模型直接驱动业务 | In Progress |
| Phase 4 | 本地优先数据层 | 引入结构化本地数据库，建立本地媒体库和同步入口 | Planned |
| Phase 5 | 播放链路重构 | 规范播放器状态、服务层与队列切换逻辑，播放器只消费统一实体 | Planned |
| Phase 6 | 多源接入与离线 | 抽象 MusicSource，接入本地源与离线能力 | Planned |
| Phase 7 | 目录迁移与清理 | 按目标结构完成目录收口和遗留清理 | Planned |

## 4. 当前状态

### 已完成

- 架构分析完成
- 技术架构文档已建立
- 重构阶段计划已建立
- 通用请求组件已通过 `RequestRepository` 统一网络访问入口
- 设置页已移除对 `Hive Box` 的直接写入
- 评论组件已通过 `CommentRepository` 收口评论请求与交互
- 用户资料页已通过 `UserRepository` 收口请求拼装，退出登录状态写入已回收到设置控制器
- 云盘页已移除仅作中转的 `CloudController`，页面改为直接消费仓库层与统一映射
- 已删除未被使用的歌单专用请求组件，避免旧请求路径继续扩散
- 已删除未承载职责的 `PlayListController`，减少空壳控制器继续误导后续拆分
- 已删除未承载职责的 `AlbumController`，路由观察器不再维护无效页面级控制器
- 探索页榜单歌曲改为直接通过 `PlaylistRepository` 获取，`AppController` 已移除歌单查询入口
- 歌单卡片列表已改为直接通过 `PlaylistRepository` 取详情并触发播放，`AppController` 不再保留按歌单 ID 拉取并播放的辅助入口
- 已清理 `AppController` 中无引用的歌单操作与歌词计时辅助方法，持续收缩总控表面积
- 搜索面板歌曲结果已直接使用统一 `MediaItemMapper`，`AppController` 不再保留歌曲模型转换代理
- 已删除 `PlayerController` 中无引用的歌曲映射辅助，统一以共享 mapper 为准
- 用户资料页已直接调用 `UserController` 注销登录，`AppController` 继续移除单点代理方法
- 底部播放面板已直接调用 `UserController` 处理喜欢状态，`AppController` 继续削减纯转发方法
- 漫游/心动模式与喜欢歌单播放逻辑已下沉到 `PlayerController`，`AppController` 仅保留面板开合与通用播放协调
- 已建立第一版领域层骨架：`Track`、`PlaylistEntity`、`AlbumEntity`、`ArtistEntity`、`PlaybackQueue` 与 `MusicSource`
- 已新增第一版 `NeteaseMusicSource`，开始将网易云能力收口到统一音乐源协议下

### 进行中

- Phase 1
- Phase 2
- Phase 3

### 未开始

- Phase 3 到 Phase 7

## 5. Phase 1: 基础边界收口

### 目标

- 停止页面继续直接承载业务流程
- 停止控制器继续直接承担所有数据访问
- 建立统一的 repository 和 mapper 落点

### 范围

重点覆盖：

- [`lib/controllers/user_controller.dart`](../lib/controllers/user_controller.dart)
- [`lib/pages/play_list/playlist_page_view.dart`](../lib/pages/play_list/playlist_page_view.dart)
- [`lib/pages/cloud/cloud_drive_view.dart`](../lib/pages/cloud/cloud_drive_view.dart)
- [`lib/pages/login/login_page_view.dart`](../lib/pages/login/login_page_view.dart)
- [`lib/controllers/player_controller.dart`](../lib/controllers/player_controller.dart)

### 任务

- 新建 repository 基础目录
- 新建统一的 `MediaItem` mapper
- 新增基础数据访问封装，禁止新增页面直调 `NeteaseMusicApi`
- 新增基础存储访问封装，禁止新增页面直连 `Hive`
- 将新改动中的模型转换统一收口
- 将通用请求组件中的直接网络访问收口到基础请求层

### 验收标准

- 新增代码中，页面层不再直接访问 `NeteaseMusicApi`
- 新增代码中，页面层不再直接访问 `Hive Box`
- 至少一个业务链路完成 repository 化
- 至少一个 `MediaItem` 转换入口完成统一
- 通用请求组件不再直接依赖底层网络代理

### 风险

- 旧代码与新结构并存一段时间
- 命名和目录首次落地时需要谨慎，避免后续反复搬迁

## 6. Phase 2: Shell 拆分

### 目标

- 将壳层 UI 状态与业务入口解耦
- 缩小 `AppController` 的职责范围

### 范围

重点覆盖：

- [`lib/controllers/app_controller.dart`](../lib/controllers/app_controller.dart)
- [`lib/pages/home/app_home_page_view.dart`](../lib/pages/home/app_home_page_view.dart)
- [`lib/pages/home/body/app_body_page_view.dart`](../lib/pages/home/body/app_body_page_view.dart)
- [`lib/pages/home/top_panel/top_panel_view.dart`](../lib/pages/home/top_panel/top_panel_view.dart)

### 任务

- 拆出 Shell Controller
- 保留壳层状态在 Shell 范围内
- 将播放入口、歌单拉取入口、模式切换入口从 `AppController` 中迁出
- 明确壳层只负责 drawer、panel、home page、返回键和搜索壳层状态

### 验收标准

- `AppController` 不再负责歌单拉取
- `AppController` 不再直接承载播放模式切换入口
- 首页壳层状态可由独立 controller 管理

### 风险

- 首页联动复杂，拆分过程容易产生 UI 回归
- 上下 panel 和 PageView 联动需要逐步迁移

### 进度更新

- 已新增 `HomeShellController`，接管首页抽屉、顶部搜索面板和首页分页标题状态
- `AppController` 先通过代理 getter 复用新壳层 controller，避免一次性改动页面依赖

## 7. Phase 3: 内容数据线重构

### 目标

- 建立独立于网易云 API Bean 的统一领域实体
- 为多源与离线能力准备稳定的数据模型边界

### 范围

重点覆盖：

- `Track`
- `PlaylistEntity`
- `AlbumEntity`
- `ArtistEntity`
- `PlaybackQueue`

### 任务

- 定义统一领域实体
- 明确 `MediaItem` 只用于播放适配层
- 为远程源、本地扫描结果建立到统一实体的映射规则
- 停止新增页面和 controller 直接依赖网易云模型驱动核心业务

### 验收标准

- 新增业务逻辑优先依赖统一实体而不是网易云 Bean
- 统一实体足以表达本地文件、远程歌曲、已下载内容
- 播放队列构建逻辑不再绑定单一远程源模型

### 风险

- 统一实体设计过早固化会放大后续迁移成本
- 需要在“够用”与“不过度设计”之间平衡

### 进度更新

- 已新增统一实体目录 `lib/domain/entities`
- 已新增 `lib/domain/sources/music_source.dart`
- 已新增第一版网易云到 `Track` 的映射器，作为后续本地库落地前的过渡桥接
- 已新增 `lib/data/sources/netease/netease_music_source.dart`，覆盖搜索、单曲、歌词、播放地址和歌单等基础能力

## 8. Phase 4: 本地优先数据层

### 目标

- 建立结构化本地数据库
- 让 UI 和大部分业务默认从本地媒体库读取数据

### 范围

重点覆盖：

- `core/database`
- `data/local`
- `library repository`
- 同步入口与缓存迁移策略

### 任务

- 引入结构化本地数据库
- 建立本地媒体库接口
- 让远程同步写入本地库，而不是直接返回给页面
- 为下载状态、离线文件、本地扫描结果预留模型与关系

### 验收标准

- 列表页和详情页可以优先展示本地数据
- 远程请求结果能稳定写回本地库
- 本地媒体库可以承载歌曲、歌单、历史、离线状态等核心信息

### 风险

- 本地数据库接入会影响缓存策略和模型定义
- 迁移期间会有 Hive 与本地数据库并存的阶段

## 9. Phase 5: 播放链路重构

### 目标

- 固定播放业务层的职责边界
- 将播放器彻底切换到统一实体和本地优先数据流

### 范围

重点覆盖：

- [`lib/controllers/player_controller.dart`](../lib/controllers/player_controller.dart)
- [`lib/common/bujuan_audio_handler.dart`](../lib/common/bujuan_audio_handler.dart)
- `features/playback`
- `domain/entities/playback_queue`

### 任务

- 建立 `PlaybackService` 或等效服务层
- 让播放器优先消费本地文件或统一播放地址
- 将歌词、模式切换、队列切换进一步整理
- 让播放队列脱离网易云模型和临时 `MediaItem` 拼装逻辑

### 验收标准

- 播放器不再直接依赖单一远程源模型
- `PlayerController` 主要负责状态暴露与视图交互
- 播放模式与队列构建有明确服务层承接

### 风险

- 播放链路属于核心功能，任何拆分都要小步验证
- 本地文件、远程链接、下载状态三者的优先级策略需要提前定清楚

## 10. Phase 6: 多源接入与离线

### 目标

- 抽象统一 `MusicSource`
- 支持远程源、本地源、离线文件共同服务于同一播放器

### 范围

- `domain/sources`
- `data/sources`
- 下载与同步模块
- 本地扫描模块

### 任务

- 定义 `MusicSource` 或等效源协议
- 将网易云接入改造成第一个 source 实现
- 新增本地媒体源
- 明确下载、离线缓存、无网络回退策略

### 验收标准

- 播放器可以消费不同 source 的统一实体
- 本地扫描结果可进入统一媒体库
- 已缓存或本地文件在无网络时仍可播放

### 风险

- 多源能力差异较大，协议设计要允许能力缺失
- 离线状态和版权状态的表达需要提前设计

## 11. Phase 7: 目录迁移与清理

### 目标

- 按目标工程架构完成目录收口
- 清理遗留的职责交叉和重复逻辑

### 范围

覆盖：

- `lib/common`
- `lib/controllers`
- `lib/pages`
- `lib/widget`
- `lib/routes`

### 任务

- 按 feature 和 data/domain/core 逐步迁移代码
- 清理遗留的过渡适配层
- 收敛通用组件与业务组件的边界
- 更新文档中的最终落点状态

### 验收标准

- 主干目录基本符合目标结构
- 遗留总控逻辑明显减少
- 常见业务链路都已完成本地优先化
- 多源接入不再需要侵入页面层

### 风险

- 目录迁移过程中链接和导入较多
- 需要配合阶段性测试与人工验证

## 12. 执行规则

后续重构执行必须遵守：

- 任何新功能优先按目标结构落地
- 任何数据流设计优先考虑本地优先与离线可用
- 任何阶段开始前，先在本文档中标记为 `In Progress`
- 阶段结束后，更新为 `Done`
- 如果中途调整策略，必须更新技术架构文档和本计划文档

## 13. 进度更新模板

后续每次推进后，按以下格式更新：

### 更新记录

#### YYYY-MM-DD

- 阶段：`Phase X`
- 状态：`In Progress` / `Done`
- 完成内容：
- 风险或阻塞：
- 下一步：

## 12. 更新记录

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
