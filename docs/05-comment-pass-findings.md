# 注释补齐过程问题记录

本文档记录补齐 public API 注释时顺手发现的工程问题。部分历史问题已经在后续架构瘦身中处理，当前只保留仍有参考价值的事项。

## 仍需关注

### 1. Drift 表定义集中在单个文件

- **位置**：`lib/data/music_data/sources/local/drift_database.dart`
- **现象**：所有 Drift table、数据库类、索引创建和 destructive reset 策略集中在同一个文件中。
- **风险**：schema 扩展时文件会继续膨胀，表归属、索引策略和数据库生命周期混在一起。
- **建议**：后续按 playback、library、user、download、cache 拆表定义文件，再由数据库入口统一组合。

### 2. 通用请求仓库仍直接依赖网易云 SDK 内部代理

- **位置**：`lib/core/network/request_repository.dart`
- **现象**：`RequestRepository` 直接 import `data/music_data/sources/netease/api/src/dio_ext.dart`。
- **风险**：`core` 到 `data/music_data/sources/netease` 的依赖方向不理想，替换 SDK 或扩展其他数据源时会牵动核心网络入口。
- **建议**：将请求代理抽象为 core port，由 data/music_data/sources/netease 提供实现，或把该 repository 下沉到 netease data 层。

### 3. 图片主色缓存仍依赖 Hive 全局入口

- **位置**：`lib/data/app_storage/image_color_cache_store.dart`
- **现象**：`ImageColorCacheStore` 直接读取 `CacheBox.instance`。
- **风险**：测试替身和未来存储替换成本偏高。
- **建议**：改为构造函数注入轻量 key-value store，`CacheBox` 只保留在 app binding 或 storage adapter 层。

### 4. 领域实体仍承担 JSON 编解码

- **位置**：`lib/core/entities/*`
- **现象**：部分 domain entity 内部包含 `fromJson`、`toJson`。
- **风险**：持久化和传输格式进入领域模型，数据格式变化会影响 domain。
- **建议**：按风险逐步把 JSON 编解码迁到 data mapper 或 cache codec。

### 5. PlaybackQueueItem 仍保留播放适配字段

- **位置**：`lib/core/entities/playback_queue_item.dart`
- **现象**：`album`、`artist`、`artUri`、`extras` 更接近 audio service 或展示适配字段。
- **风险**：播放 adapter 需求会继续影响 domain entity 形状。
- **建议**：后续将这些 getter 移到 playback adapter/mapper，domain 保留原始字段和最小派生规则。

### 6. 用户作用域本地数据源接口偏宽

- **位置**：`lib/data/music_data/sources/local/user_scoped_data_source.dart`、`lib/data/music_data/sources/local/dao/user_dao.dart`
- **现象**：同一个数据源和 DAO 同时覆盖用户资料、用户曲目列表、用户歌单列表、歌单订阅状态、电台订阅、节目列表和同步标记。
- **风险**：后续新增用户相关缓存时容易继续堆到一个接口里。
- **建议**：按资料、曲目列表、歌单列表、电台、同步标记拆成更小 data source/DAO port，现有 facade 可保留组合职责。

### 7. 网易云远程访问入口存在能力重叠

- **位置**：`lib/data/music_data/sources/netease/netease_music_source.dart`、`lib/data/music_data/sources/netease/netease_*_remote_data_source.dart`
- **现象**：`NeteaseMusicSource` 和多个 feature remote data source 都封装了部分网易云访问能力。
- **风险**：参数、错误处理和缓存策略调整时容易遗漏。
- **建议**：明确 `NeteaseMusicSource` 是通用 source 还是仅服务曲库聚合；feature remote data source 只保留页面/用例专属接口。

### 8. 网易云 SDK DTO 文件体量过大

- **位置**：`lib/data/music_data/sources/netease/api/src/api/*/bean.dart`
- **现象**：单个接口 bean 文件包含大量响应包装、嵌套实体、字段转换和 JSON 序列化入口。
- **风险**：人工 review 难以判断新增字段归属，也容易在生成或手写维护之间产生冲突。
- **建议**：按接口域或响应类型拆小 DTO 文件；如果继续保留生成式 DTO，应明确生成流程如何保留人工注释。
