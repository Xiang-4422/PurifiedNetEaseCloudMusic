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

## 3. 阶段总览

| 阶段 | 名称 | 目标 | 状态 |
| --- | --- | --- | --- |
| Phase 0 | 文档定案 | 固定技术架构、工程结构和执行计划 | Done |
| Phase 1 | 基础边界收口 | 停止新债继续扩散，建立 repository 和 mapper 落点 | In Progress |
| Phase 2 | Shell 拆分 | 将 `AppController` 中的壳层状态和业务入口拆开 | In Progress |
| Phase 3 | 内容数据线重构 | 登录、歌单、云盘、搜索的用例逻辑从页面移出 | Planned |
| Phase 4 | 播放链路重构 | 规范播放器状态、服务层与队列切换逻辑 | Planned |
| Phase 5 | 目录迁移与清理 | 按目标结构完成目录收口和遗留清理 | Planned |

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

### 进行中

- Phase 1
- Phase 2

### 未开始

- Phase 1 到 Phase 5

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

- 将页面中的用例逻辑迁出
- 建立按 feature 划分的内容数据访问结构

### 范围

重点覆盖：

- [`lib/pages/login/login_page_view.dart`](../lib/pages/login/login_page_view.dart)
- [`lib/pages/play_list/playlist_page_view.dart`](../lib/pages/play_list/playlist_page_view.dart)
- [`lib/pages/cloud/cloud_drive_view.dart`](../lib/pages/cloud/cloud_drive_view.dart)
- [`lib/pages/home/top_panel/top_panel_view.dart`](../lib/pages/home/top_panel/top_panel_view.dart)

### 任务

- 登录流程抽出 `AuthController/AuthRepository`
- 歌单详情流程抽出 `PlaylistDetailController/PlaylistRepository`
- 云盘歌曲列表访问收口
- 搜索数据访问从页面中剥离

### 验收标准

- 登录页不再负责登录轮询和状态落库策略
- 歌单页不再直接负责分批 song detail 拉取
- 云盘页不再在页面内拼装 `MediaItem`
- 搜索页不再在页面中直接拼接请求流程

### 风险

- 页面拆轻后，原有一些临时状态可能需要重新归位
- 通用请求组件后续职责可能需要进一步收缩

## 8. Phase 4: 播放链路重构

### 目标

- 固定播放业务层的职责边界
- 将控制器状态、播放服务、底层播放器彻底分层

### 范围

重点覆盖：

- [`lib/controllers/player_controller.dart`](../lib/controllers/player_controller.dart)
- [`lib/common/bujuan_audio_handler.dart`](../lib/common/bujuan_audio_handler.dart)

### 任务

- 建立 `PlaybackService` 或等效服务层
- 将歌词获取、模式切换、队列切换职责进一步整理
- 削减控制器对其他 controller 和基础设施的直接依赖
- 统一播放相关 mapper 和缓存入口

### 验收标准

- 播放器底层不再直接承担过多跨模块逻辑
- `PlayerController` 主要负责状态暴露与视图交互
- 播放模式切换和队列构建逻辑有明确服务层承接

### 风险

- 播放链路属于核心功能，任何拆分都要小步验证
- 歌词、封面、模式切换存在联动风险

## 9. Phase 5: 目录迁移与清理

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

- 按 feature 逐步迁移代码
- 清理遗留的过渡适配层
- 收敛通用组件与业务组件的边界
- 更新文档中的最终落点状态

### 验收标准

- 主干目录基本符合目标结构
- 遗留总控逻辑明显减少
- 常见业务链路都已完成 repository 化

### 风险

- 目录迁移过程中链接和导入较多
- 需要配合阶段性测试与人工验证

## 10. 执行规则

后续重构执行必须遵守：

- 任何新功能优先按目标结构落地
- 任何阶段开始前，先在本文档中标记为 `In Progress`
- 阶段结束后，更新为 `Done`
- 如果中途调整策略，必须更新技术架构文档和本计划文档

## 11. 进度更新模板

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
