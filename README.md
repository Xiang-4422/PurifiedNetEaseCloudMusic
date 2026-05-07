# PurifiedNetEaseCloudMusic

README 是本项目文档入口。`docs/` 下文档按编号阅读：

1. [技术架构设计](./docs/01-technical-architecture.md)
2. [本地缓存与表结构设计](./docs/02-local-cache-architecture.md)
3. [重构计划与进度](./docs/03-refactor-plan.md)
4. [代码注释规范](./docs/04-comment-guidelines.md)

## 当前结论

项目当前采用“本地优先 + feature-first + 渐进瘦身”的工程方向，不做一次性重写，也不继续追加低价值分层。

- 普通页面默认走 `Page/View + Controller -> Repository`。
- 全局播放能力允许页面直接使用 `PlayerController`，不用再通过空壳 port/usecase 转发。
- 业务事实来源收敛为 `Drift` 本地数据库和网络刷新；自有业务 `snapshot` 持久化已经移除。
- `Hive` 只保留登录态、设置项和轻量视觉缓存。
- 继续保留 `Flutter`、`GetX`、`auto_route`、`Dio`、`Drift`、`Hive`、`just_audio + audio_service`。
- 硬边界仍然保留：`core/data/domain` 不依赖 Flutter/GetX，presentation 不直接访问 DAO、Drift data source 或网易云 remote data source。

## 文档使用规则

- 技术方案、目录方案、边界约束，以 [`docs/01-technical-architecture.md`](./docs/01-technical-architecture.md) 为准。
- 本地缓存、`Drift` 表结构、账号作用域和 ID 规则，以 [`docs/02-local-cache-architecture.md`](./docs/02-local-cache-architecture.md) 为准。
- 后续整理项、完成情况、阻塞项，以 [`docs/03-refactor-plan.md`](./docs/03-refactor-plan.md) 为准。
- 每次阶段性架构调整后，同步更新相关文档，避免文档继续描述已删除的结构。
