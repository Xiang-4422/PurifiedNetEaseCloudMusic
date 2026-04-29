# 注释补齐过程问题记录

本文档记录补齐 public API 注释时顺手发现的工程问题。记录原则：

- 只记录，不在补注释批次中修复。
- 只记录可复现、可定位的问题，避免泛泛而谈。
- 后续集中治理时再按影响范围拆计划和提交。
- 如果同一问题在多个目录重复出现，只记录代表性位置和影响面。

## 记录格式

每条问题按以下格式记录：

- **位置**：文件或目录。
- **现象**：补注释时观察到的具体问题。
- **风险**：后续维护、架构边界或迁移上的影响。
- **建议**：后续集中处理方向。

## 已记录问题

### 1. app theme 常量仍有历史命名和职责混杂

- **位置**：`lib/app/theme/app_colors.dart`、`lib/app/theme/app_text_styles.dart`。
- **现象**：`AppColors` 与 `AppTheme` 同时承担基础色板和主题配置；部分颜色命名偏视觉结果，如 `min`、`middle`、`max`、`empty`，难以表达业务或 UI 语义。`app_text_styles.dart` 使用全局可变 `TextStyle` 顶层变量，而不是不可变常量或主题扩展。
- **风险**：后续 UI 调整时难以判断某个颜色或字体样式的真实用途，容易继续扩大“一处常量到处复用”的隐式耦合。
- **建议**：后续把主题 token、业务状态色、组件专用样式拆开；顶层样式优先改为 `const` 或集中进主题扩展。

### 2. presentation adapter 中仍暴露 GetX Rx 类型

- **位置**：`lib/app/presentation_adapters/shell_playback_port.dart`、`lib/app/presentation_adapters/shell_user_port.dart`。
- **现象**：Shell 端口为了兼容现有 GetX 展示层，仍把 `Rx` 类型作为端口返回值。
- **风险**：虽然该端口位于 presentation adapter 层，短期可接受，但未来迁 Riverpod 时 Shell 与 GetX 的绑定面仍偏大。
- **建议**：后续将 Shell 端口输出收敛为 immutable view state 或 `ValueListenable`/普通 getter，避免跨 adapter 传播 GetX 类型。

### 3. FeatureControllerFactory 仍直接组装部分 application service

- **位置**：`lib/app/bootstrap/feature_controller_factory.dart`。
- **现象**：`playlistPage()` 内部即时创建 `PlaylistDetailService`，而不是完全由 registrar 统一注册后注入。
- **风险**：组合根职责还不完全一致，同类 application service 有的在 registrar 注册，有的在 factory 内创建，后续排查依赖图时需要多看一个入口。
- **建议**：后续把页面级 application service 的创建策略统一：要么全部 registrar 注册，要么明确 factory 只负责页面生命周期型对象。

### 4. PresentationAdapterRegistrar 仍集中处理多类 UI adapter

- **位置**：`lib/app/bootstrap/registrars/presentation_adapter_registrar.dart`。
- **现象**：toast、播放主题、Shell port、设置页导航、评论内容构建都集中在同一个 registrar。
- **风险**：文件暂时不大，但职责横跨 playback、shell、settings、comment，后续新增 adapter 时容易重新变成展示层装配聚合点。
- **建议**：后续按 feature 或 adapter 类型拆成小 registrar，但继续保持 `AppBinding` 单一入口。

### 5. 路由观察者只有日志，缺少可替换端口

- **位置**：`lib/app/routing/app_router_observer.dart`。
- **现象**：路由切换日志直接写在 observer 中。
- **风险**：如果后续要接入埋点、调试开关或测试替身，当前 observer 会继续承担策略判断。
- **建议**：后续抽出轻量 navigation logging/analytics port，由 observer 只负责转发路由事件。

### 6. Drift 表定义集中在单个文件

- **位置**：`lib/core/database/drift_database.dart`。
- **现象**：所有 Drift table、数据库类、索引创建和 destructive reset 策略集中在同一个文件中。
- **风险**：schema 扩展时文件会继续膨胀，表归属、索引策略和数据库生命周期混在一起，后续定位某个 feature 的持久化结构成本较高。
- **建议**：后续按资源域拆表定义文件，例如 playback、library、user、download、cache，再由数据库入口统一组合。

### 7. 通用请求仓库仍直接依赖网易云 SDK 内部代理

- **位置**：`lib/core/network/request_repository.dart`。
- **现象**：`RequestRepository` 直接 import `data/netease/api/src/dio_ext.dart`，核心层仍知道网易云 SDK 内部实现。
- **风险**：`core` 到 `data/netease` 的依赖方向不理想，后续如果替换 SDK 或扩展其他数据源，核心网络入口会被迫跟着调整。
- **建议**：后续将请求代理抽象为 core port，由 data/netease 提供实现，或把该 repository 下沉到 netease data 层。

### 8. 图片主色缓存仍依赖 Hive 全局入口

- **位置**：`lib/core/storage/image_color_cache_store.dart`。
- **现象**：`ImageColorCacheStore` 直接读取 `CacheBox.instance`，而不是通过构造函数注入存储实例。
- **风险**：虽然这是轻量视觉缓存，仍会让测试替身和未来存储替换成本变高。
- **建议**：后续改为构造函数注入轻量 key-value store，`CacheBox` 只保留在 app binding 或 storage adapter 层。

### 9. 领域实体仍承担 JSON 编解码

- **位置**：`lib/domain/entities/playlist_summary_data.dart`、`lib/domain/entities/radio_data.dart`、`lib/domain/entities/user_profile_data.dart`、`lib/domain/entities/user_session_data.dart`、`lib/domain/entities/playback_queue_item.dart`、`lib/domain/entities/playback_restore_state.dart`。
- **现象**：部分 domain entity 内部直接包含 `fromJson`、`toJson`。
- **风险**：domain 层虽然仍是纯 Dart，但持久化和传输格式开始进入实体本身，后续数据格式变化会影响领域模型。
- **建议**：后续按风险逐步把 JSON 编解码迁到 data mapper 或 cache codec，domain entity 只保留业务字段和纯规则。

### 10. PlaybackQueueItem 仍保留播放适配层兼容字段

- **位置**：`lib/domain/entities/playback_queue_item.dart`。
- **现象**：`album`、`artist`、`artUri`、`extras` 更接近 audio service 或展示适配字段，而不是纯播放队列实体字段。
- **风险**：播放 adapter 的需求会继续影响 domain entity 形状，削弱 `MediaItem` 边界清理后的隔离效果。
- **建议**：后续将这些 getter 移到 playback adapter/mapper，domain 保留原始字段和最小派生规则。

### 11. 用户作用域本地数据源接口偏宽

- **位置**：`lib/data/local/user_scoped_data_source.dart`、`lib/data/local/dao/user_dao.dart`。
- **现象**：同一个数据源和 DAO 同时覆盖用户资料、用户曲目列表、用户歌单列表、歌单订阅状态、电台订阅、节目列表和同步标记。
- **风险**：后续新增用户相关缓存时容易继续堆到一个接口里，调用方也难以只依赖自己需要的最小能力。
- **建议**：后续按资料、曲目列表、歌单列表、电台、同步标记拆成更小 data source/DAO port，现有 facade 可保留组合职责。

### 12. 网易云远程访问入口存在能力重叠

- **位置**：`lib/data/netease/netease_music_source.dart`、`lib/data/netease/netease_*_remote_data_source.dart`。
- **现象**：`NeteaseMusicSource` 提供搜索、曲目、播放地址、歌词、歌单等通用能力；多个 feature remote data source 也直接封装 `NeteaseMusicApi`。
- **风险**：同一类远程访问可能在不同入口重复实现，后续 API 参数、错误处理、缓存策略调整时容易遗漏。
- **建议**：后续明确 `NeteaseMusicSource` 是通用 source 还是仅服务曲库聚合；feature remote data source 只保留页面/用例专属接口，通用曲目和搜索能力统一走一个入口。

### 13. 网易云 SDK DTO 文件体量过大

- **位置**：`lib/data/netease/api/src/api/*/bean.dart`。
- **现象**：单个接口 bean 文件同时包含大量响应包装、嵌套实体、字段转换和 JSON 序列化入口；补声明级注释时需要在一个文件内连续处理数百个 public 成员。
- **风险**：字段语义、接口归属和转换约束都堆在大文件中，后续人工 review 很难判断新增字段是否属于当前接口域，也容易在生成或手写维护之间产生冲突。
- **建议**：后续按接口域或响应类型拆小 DTO 文件；如果继续保留生成式 DTO，应明确生成流程如何保留人工注释，避免补齐的字段说明被覆盖。
